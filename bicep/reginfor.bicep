@description('Resource ID of the existing AVD host pool')
param hostPoolId string

@description('Registration token expiration time in ISO 8601 format (e.g. 2025-07-26T12:00:00Z)')
param expirationTime string

// Reference existing host pool
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-02-10-preview' existing = {
  name: last(split(hostPoolId, '/'))
}

// Registration Info
resource registrationInfo 'Microsoft.DesktopVirtualization/hostPools/registrationInfo@2022-02-10-preview' = {
  name: 'registrationInfo'
  parent: hostPool
  properties: {
    expirationTime: expirationTime
  }
}

output registrationToken string = registrationInfo.properties.token
