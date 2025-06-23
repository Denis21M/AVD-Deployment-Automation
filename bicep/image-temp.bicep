param location string = resourceGroup().location
param imageName string
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = resourceGroup().name
param galleryName string
param sharedImageName string
param subnetId string
param identityId string

var galleryImageId = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Compute/galleries/${galleryName}/images/${sharedImageName}'

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: imageName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'office-365'
      sku: 'win10-22h2-avd'
      version: 'latest'
    }
    customize: [
  {
    type: 'PowerShell'
    name: 'InstallChrome'
    scriptUri: 'https://raw.githubusercontent.com/Azure/azvmimagebuilder/main/quickquickstarts/scripts/inst_chrome.ps1'
  }
  {
    type: 'PowerShell'
    name: 'Install7Zip'
    scriptUri: 'https://raw.githubusercontent.com/Azure/azvmimagebuilder/main/quickquickstarts/scripts/inst_7zip.ps1'
  }
]
    destination: {
      type: 'SharedImage'
      galleryImageId: galleryImageId
      replicationRegions: [
        location
      ]
    }
    vmProfile: {
      osDiskSizeGB: 127
      vnetConfig: {
        subnetId: subnetId
      }
    }
  }
}
