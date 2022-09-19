@secure()
@description('Container apps environment name')
param environment_name string

@description('Custom message for the app')
param custom_message string = 'nodeapp'


//@description('Container image name (registry/image:tag)')
//param image_name string

@secure()
@description('Private container registry login server')
param registry_login_server string

@secure()
@description('Private container registry username')
param registry_username string

@secure()
@description('Private container registry password')
param registry_password string

@description('Provide a location for the Container Apps resources')
param location string

resource nodeapp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'nodeapp'
  location: location

  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environment_name)

    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }

      activeRevisionsMode: 'multiple'

      dapr: {
        enabled: true
        appId: 'nodeapp'
        appProtocol: 'http'
        appPort: 3000
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
      revisionSuffix: 'rev1'
      containers: [
        {
          image: '${registry_login_server}/hello-aca-node:v1'
          name: 'nodeapp'
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
          ]
          env: [
            {
              name: 'MESSAGE'
              value: custom_message
            }
            {
              name: 'PERSIST_ORDERS'
              value: 'true'
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
