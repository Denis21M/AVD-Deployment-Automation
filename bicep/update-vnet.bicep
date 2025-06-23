@description('Location for VNet')
param location string = resourceGroup().location

@description('Name of the Virtual Network')
param vnetName string

@description('Subnet name (needed for existing VNet ref)')
param subnetName string

@description('AD DS IP addresses to update DNS servers with')
param adDsIpAddresses array

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
}

resource updateVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: vnet.properties.addressSpace
    dhcpOptions: {
      dnsServers: adDsIpAddresses
    }
    subnets: vnet.properties.subnets
  }
  dependsOn: [
    vnet
  ]
}
