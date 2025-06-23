@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Virtual Network')
param vnetName string = 'avd-vnet'

@description('Name of the subnet for AD DS')
param subnetName string = 'ad-ds-subnet'

@description('Domain name for Azure AD DS')
param domainName string = 'corp.local'

// 1. Create VNet with subnet and empty DNS servers (will update DNS later)
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [] // Initially empty; will update after AD DS IPs available
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// 2. Deploy Azure AD Domain Services in the subnet
resource domainServices 'Microsoft.AAD/domainServices@2021-05-01' = {
  name: domainName
  location: location
  properties: {
    domainName: domainName
    sku: 'Standard'
    subnetId: vnet.properties.subnets[0].id
    ldapsSettings: {
      ldaps: 'Enabled'
      pfxCertificate: ''
      pfxCertificatePassword: ''
    }
    domainSecuritySettings: {
      syncKerberosPasswords: true
      syncNtlmPasswords: true
      syncOnPremPasswords: true
    }
    notificationSettings: {
      notifyGlobalAdmins: true
      notifyDcAdmins: true
      additionalRecipients: []
    }
  }
  dependsOn: [
    vnet
  ]
}
