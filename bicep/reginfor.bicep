@description('Host pool resource ID')
param hostPoolId string

@description('Registration token expiration time in ISO 8601 format (e.g. 2025-07-20T10:00:00Z)')
param expirationTime string

// Get host pool resource from resource ID (import existing)
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-02-10-preview' existing = {
  id: hostPoolId
}

// Registration Info (token) Resource — child of hostPool
resource registrationInfo 'Microsoft.DesktopVirtualization/hostPools/registrationInfo@2022-02-10-preview' = {
  name: 'registrationInfo'
  parent: hostPool
  properties: {
    expirationTime: expirationTime
  }
}

// Output registration token value to use for session host registration
output registrationToken string = registrationInfo.properties.token
