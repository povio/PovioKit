# Camera

A UI component that simplifies handling with camera. `PhotoCamera` & `QRCodeScanner`.

## Usage

### PhotoCamera Example:
```swift
let camera = PhotoCamera()
func prepareCamera() {
  do {
    try await camera.prepare()
  } catch {
    // error handling
  }

  // add previewLayer to any view
  view.layer.addSublayer(camera.previewLayer)
  camera.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  camera.delegate = self
    
  // request authorization status
  let granted = await camera.requestAuthorizationStatus()
    
  switch granted {
  case true:
    self.camera.startSession()
  case false:
    // handle denied status
    break
  }
}
```
#### Photo Camera functions
`func takePhoto()`

We can also switch from front facing to back camera:

`func setCameraPosition(_ position: CameraPosition) throws`


#### Photo Camera delegate

`func photoCamera(_ photoCamera: PhotoCamera, didTakePhoto image: UIImage)`

`func photoCamera(_ photoCamera: PhotoCamera, didTriggerError error: Camera.Error)`

### QRCodeScanner Example:
```swift
let scanner = QRCodeScanner()
func prepareQRCodeSCanner() {
  do {
    try await camera.prepare()
  } catch {
    // error handling
  }

  // add previewLayer to any view
  view.layer.addSublayer(scanner.previewLayer)
  scanner.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  scanner.delegate = self
    
  // request authorization status
  let granted = await scanner.requestAuthorizationStatus()
    
  switch granted {
  case true:
    self.scanner.startSession()
  case false:
    // handle denied status
    break
  }
}
```

#### QRCodeScanner delegate
`func codeScanned(code: String, boundingRect: CGRect)`

`func scanFailure()`

## Source code
You can find source code here:
- [Camera](/Sources/Utilities/Camera/Camera.swift)
- [Camera+PovioKit](/Sources/Utilities/Camera/Camera+PovioKit.swift)
- [CameraService](/Sources/Utilities/Camera/CameraService.swift)
- [PhotoCamera](/Sources/Utilities/Camera/PhotoCamera.swift)
- [QRCodeScanner](/Sources/Utilities/Camera/QRCodeScanner.swift)
