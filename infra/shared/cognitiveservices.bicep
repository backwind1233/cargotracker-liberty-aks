metadata description = 'Creates an Azure Cognitive Services instance.'

@description('Required. Name of your Azure OpenAI service account. ')
param accountName string

@description('')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The custom subdomain name used to access the API. Defaults to the value of the name parameter.')
param customSubDomainName string = accountName

@description('Required. The principal ID of the MI for the chate agent application. ')
param appPrincipalId string

@description('Optional. The role definition ID for the Cognitive Services OpenAI role. Default: User role')
// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user
param roleDefinitionId string = '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'

param disableLocalAuth bool = false
param deployments array = []
param kind string = 'OpenAI'

@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'
param sku object = {
  name: 'S0'
}

param allowedIpRules array = []
param networkAcls object = empty(allowedIpRules) ? {
  defaultAction: 'Allow'
} : {
  ipRules: allowedIpRules
  defaultAction: 'Deny'
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  tags: tags
  kind: kind
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    disableLocalAuth: disableLocalAuth
  }
  sku: sku
}

module roleAssignment 'openaiRoleAssignment.bicep' = {
  name: 'openai-role-assignment-${accountName}'
  params: {
    accountName: account.name
    appPrincipalId: appPrincipalId
    roleDefinitionId: roleDefinitionId
  }
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  properties: {
   model: {
      format: 'OpenAI'
      name: deployment.model.name
      version: deployment.model.version
     }
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

output endpoint string = account.properties.endpoint
output endpoints object = account.properties.endpoints
output id string = account.id
output name string = account.name
