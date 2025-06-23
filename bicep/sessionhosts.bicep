@description('Location of the VMs')
param location string

@description('Number of session host VMs to create')
param sessionHostCount int = 1

@description('Prefix for the session host VM names')
param sessionHostNamePrefix string = 'session-host'

@description('Image ID from Shared Image Gallery')
param imageId string

@description('Subnet ID to place VMs')
param subnetId string

@description('Admin username for the VMs')
param adminUsername string

@description('Admin password for the VMs')
@secure()
param adminPassword string

@description('Domain to join')
param domainToJoin string

@description('Username for domain join')
param domainJoinUsername string  // Assume this is secure and passed from GitHub secrets

@description('Password for domain join')
@secure()
param domainJoinPassword string  // Assume this is secure and passed from GitHub secrets

@description('User-assigned managed identity ID')
param identityId string

@description('Host pool to register session hosts to')
param hostPoolId string

@description('Registration token used for session host registration')
@secure()
param registrationInfoToken string

@description('Registration token for host pool')
param registrationToken string

// Network Interfaces
resource nicResources 'Microsoft.Network/networkInterfaces@2023-02-01' = [for i in range(1, sessionHostCount + 1): {
  name: '${sessionHostNamePrefix}${i}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

// Loop to create multiple session host VMs
resource sessionHosts 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(1, sessionHostCount + 1): {
  name: '${sessionHostNamePrefix}${i}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        id: imageId
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    osProfile: {
      computerName: '${sessionHostNamePrefix}${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
      secrets: []
      customData: ''
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicResources[i - 1].id
        }
      ]
    }
  }
  dependsOn: [
    nicResources[i - 1]
  ]
}]

// Domain Join Script Extension
resource vmExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for i in range(1, sessionHostCount + 1): {
  name: '${sessionHostNamePrefix}${i}/domainJoin'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainToJoin
      User: domainJoinUsername
      Password: domainJoinPassword
      Restart: 'true'
    }
  }
  dependsOn: [
    sessionHosts[i - 1]
  ]
}]

// AVD Host Pool Registration Extension
resource avdExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = [for i in range(1, sessionHostCount + 1): {
  name: '${sessionHostNamePrefix}${i}/avdRegistration'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.DesktopVirtualization'
    type: 'JsonADDomainExtension'  // Double-check this extension type for AVD registration; if wrong, replace accordingly
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      hostPoolId: hostPoolId
      registrationToken: registrationToken
    }
  }
  dependsOn: [
    sessionHosts[i - 1]
  ]
}]
