@allowed(['dev', 'prod'])
param environment string

param location string = resourceGroup().location
param workloadName string = 'bicepdemo'

var storageAccountName = 'st${workloadName}${environment}001'

var storageSku = environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

var tags = {
  environment: environment
  workload: workloadName
  managedBy: 'bicep'
  repo: 'bicep-azure-demo'
}

module storage './modules/storage/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    name: storageAccountName
    location: location
    sku: storageSku
    tags: tags
  }
}

output storageAccountId string = storage.outputs.id
output storageAccountName string = storage.outputs.name
output blobEndpoint string = storage.outputs.blobEndpoint
