@description('Container apps environment name')
param environment_name string

@description('Container image name (registry/image:tag)')
param image_name string

@description('Private container registry login server')
param registry_login_server string

@description('Private container registry username')
param registry_username string

@secure()
@description('Private container registry password')
param registry_password string

@description('Provide a location for the Container Apps resources')
param location string = resourceGroup().location

@description('Provide a URL for the nodeapp new order endpoint')
param nodeapp_url string = ''

resource nodeapp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'pythonapp'
  location: location

  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environment_name)

    configuration: {

      dapr: {
        enabled: true
        appId: 'pythonapp'
      }
      
      secrets: [
        {
          name: 'registry-password'
          value: registry_password
        }
      ]

      registries: [
        {
          server: registry_login_server
          username: registry_username
          passwordSecretRef: 'registry-password'
        }
      ]
    }

    template: {
      containers: [
        {
          image: image_name
          name: 'pythonapp'
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                  path: '/health'
                  port: 8080
                  httpHeaders: [
                    {
                      name:'Custom-Header'
                      value: 'liveness probe'
                    }
                  ]
                }
                initialDelaySeconds: 7
                periodSeconds: 3
            }
            {
              type: 'Readiness'
              tcpSocket: {
                port: 8081
              }
              initialDelaySeconds: 10
              periodSeconds: 3
            }
            {
              type: 'Startup'
              httpGet: {
                path: '/startup'
                port: 8080
                httpHeaders: [
                  {
                    name:'Custom-Header'
                    value: 'startup probe'
                  }                
                ]
              }
              initialDelaySeconds: 3
              periodSeconds: 3
            }
          ]
          env: [
            {
              name: 'NODEAPP_URL'
              value: nodeapp_url
            }
          ]
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
