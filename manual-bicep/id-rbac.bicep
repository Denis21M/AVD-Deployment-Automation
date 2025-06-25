@description('The location where resources will be deployed.')
param location string = resourceGroup().location

@description('Name of the image to be created.')
param imageName string

@description('Subnet resource ID where Image Builder will run.')
param subnetId string

@description('Name of Shared Image Gallery.')
param galleryName string

@description('Shared Image Name.')
param sharedImageName string

// Extract VNet name from the subnetId
var vnetName = split(subnetId, '/')[8]

// Reference the existing virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
}

// Create the User Assigned Managed Identity (UAMI)
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'avdImageBuilderIdentity'
  location: location
}

// Assign Contributor role at the resource group level
resource contributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, 'contributor-role')
  scope: resourceGroup()
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalType: 'ServicePrincipal'
  }
}

// Assign Contributor role to the VNet
resource networkContributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uami.id, 'network-contributor-role')
  scope: vnet
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalType: 'ServicePrincipal'
  }
}

// Call the image builder template module (must exist in the same folder)
module imageTemplate 'image-temp.bicep' = {
  name: 'imageTemplateModule'
  params: {
    location: location
    imageName: imageName
    subnetId: subnetId
    identityId: uami.id
    galleryName: galleryName
    sharedImageName: sharedImageName
  }
}
