param location string = resourceGroup().location
param imageName string
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = resourceGroup().name
param galleryName string
param sharedImageName string
param subnetId string // Full resource ID
param identityId string // Full resource ID
param vmSize string = 'Standard_D2s_v3' // Default to supported size

var galleryImageId = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Compute/galleries/${galleryName}/images/${sharedImageName}'

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: imageName
  location: location
  tags: {
    environment: 'dev'
    project: 'avd-image-builder'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: any({
      '${identityId}': {}
    })
  }
  properties: {
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'windows-11'
      sku: 'win11-22h2-avd'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'InstallChromeAndVSCode'
        scriptUri: 'https://raw.githubusercontent.com/Denis21M/AVD-Deployment-Automation/refs/heads/main/app-scripts/install-apps.ps1'
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        runOutputName: 'myRunOutput'
        galleryImageId: galleryImageId
        replicationRegions: [
          location
        ]
      }
    ]
    vmProfile: {
      osDiskSizeGB: 127
      vmSize: vmSize
      vnetConfig: {
        subnetId: subnetId
      }
    }
  }
}
