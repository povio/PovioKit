//
//  QRCodeScanner.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import AVFoundation

public protocol QRCodeScannerDelegate: AnyObject {
  func codeScanned(code: String, boundingRect: CGRect)
  func scanFailure()
}

public class QRCodeScanner: Camera {
  public weak var delegate: QRCodeScannerDelegate?
  private let metadataOutput = AVCaptureMetadataOutput()
  
  public init(delegate: QRCodeScannerDelegate? = nil) {
    super.init()
    self.delegate = delegate
  }
}

// MARK: - Public Methods
public extension QRCodeScanner {
  func prepare() async throws {
    try self.configure()
  }
}

// MARK: - AVCapture Metadata Output Delegate
extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard session.isRunning,
      let scannedObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
      scannedObject.type == AVMetadataObject.ObjectType.qr, let qrCode = scannedObject.stringValue else {
        delegate?.scanFailure()
        return
    }
    
    guard let codeFrame = previewLayer.transformedMetadataObject(for: scannedObject)?.bounds else { return }
    delegate?.codeScanned(code: qrCode, boundingRect: codeFrame)
  }
}

// MARK: - Private Methods
private extension QRCodeScanner {
  func configure() throws {
    guard let device = device else { throw Camera.Error.unavailable }

    if device.isFocusModeSupported(.continuousAutoFocus) {
      try device.lockForConfiguration()
      device.focusMode = .continuousAutoFocus
      device.unlockForConfiguration()
    }

    session.beginConfiguration()
    
    // add input
    guard let deviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(deviceInput) else {
      throw Camera.Error.missingInput
    }
    session.addInput(deviceInput)
    
    // prepare output
    guard session.canAddOutput(metadataOutput) else {
      throw Camera.Error.missingOutput
    }
    session.addOutput(metadataOutput)
    metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
    
    guard metadataOutput.availableMetadataObjectTypes.contains(.qr) else {
      throw Camera.Error.missingMetadata
    }
    metadataOutput.metadataObjectTypes = [.qr]
    
    session.commitConfiguration()
  }
}
