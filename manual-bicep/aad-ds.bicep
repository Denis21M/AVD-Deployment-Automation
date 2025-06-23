@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the Virtual Network')
param vnetName string

@description('Name of the subnet for AD DS')
param subnetName string

@description('Domain name for Microsoft Entra Domain Services')
param domainName string

// 1. Create NSG with required inbound and outbound rules for AD DS deployment
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${vnetName}-${subnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      // Allow Outbound WinRM 5986
      {
        name: 'AllowOutboundWinRM5986'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5986'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // Allow Inbound WinRM 5986
      {
        name: 'AllowInboundWinRM5986'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '5986'
          sourceAddressPrefix: 'AzureActiveDirectoryDomainServices'
          destinationAddressPrefix: '*'
        }
      }
      // Allow Inbound RDP 3389 for testing (for prod use vpn or private connection)
      {
        name: 'AllowInboundRDP3389'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // Allow Inbound LDAP 389
      {
        name: 'AllowInboundLDAP389'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      // Allow Inbound LDAPS 636
      {
        name: 'AllowInboundLDAPS636'
        properties: {
          priority: 140
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '636'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// 2. Create or reference VNet with subnet
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// 3. Deploy Microsoft Entra Domain Services (Azure AD DS)
resource domainServices 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: domainName
  location: location
  properties: {
    domainName: domainName
    sku: 'Standard'
    replicaSets: [
      {
        location: location
        subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
      }
    ]
    ldapsSettings: {
      ldaps: 'Disabled'
      externalAccess: 'Disabled'
      pfxCertificate: ''
      pfxCertificatePassword: ''
    }
    domainSecuritySettings: {
      ntlmV1: 'Disabled'
      tlsV1: 'Disabled'
      syncKerberosPasswords: 'Enabled'
      syncNtlmPasswords: 'Disabled'
    }
    notificationSettings: {
      notifyGlobalAdmins: 'Enabled'
      notifyDcAdmins: 'Enabled'
      additionalRecipients: []
    }
  }
  dependsOn: [
    vnet
    nsg
  ]
}
