param location string = resourceGroup().location
param galleryName string
param sharedImageName string
param imageDescription string = 'Shared image for AVD or custom VM builds'

resource sig 'Microsoft.Compute/galleries@2023-07-03' = {
  name: galleryName
  location: location
  properties: {
    description: 'Shared Image Gallery for managing custom VM images'
  }
}

resource imageDef 'Microsoft.Compute/galleries/images@2023-07-03' = {
  name: sharedImageName
  parent: sig
  location: location
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    hyperVGeneration: 'V2'
    identifier: {
      publisher: 'myPublisher'
      offer: 'myOffer'
      sku: 'mySKU'
    }
    description: imageDescription
  }
}
