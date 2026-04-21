//
//  QRCodeScanner.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation

public protocol QRCodeScannerDelegate: AnyObject {
  func codeScanned(code: String, boundingRect: CGRect)
  func scanFailure()
}

public class QRCodeScanner: Camera, @unchecked Sendable {
  public weak var delegate: QRCodeScannerDelegate?
  private let metadataOutput = AVCaptureMetadataOutput()
  private var deviceInput: AVCaptureDeviceInput?
  
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
    guard session.isRunning else { return }
    guard let scannedObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          scannedObject.type == AVMetadataObject.ObjectType.qr else {
      // Non-QR metadata or empty batch. Let the scanner keep running silently.
      return
    }
    guard let qrCode = scannedObject.stringValue else {
      // Detected a QR code, but the string payload could not be decoded.
      delegate?.scanFailure()
      return
    }
    guard let codeFrame = previewLayer.transformedMetadataObject(for: scannedObject)?.bounds else { return }
    delegate?.codeScanned(code: qrCode, boundingRect: codeFrame)
  }
}

// MARK: - Private Methods
private extension QRCodeScanner {
  /// Reconfigures the capture session. Runs on `sessionQueue` so topology
  /// mutation is serialized with `startSession()` / `stopSession()`.
  func configure() throws {
    try onSessionQueue {
      guard let device = device else { throw Camera.Error.unavailable }

      if device.isFocusModeSupported(.continuousAutoFocus) {
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        device.focusMode = .continuousAutoFocus
      }

      session.beginConfiguration()
      defer { session.commitConfiguration() }

      if let previousDeviceInput = self.deviceInput {
        session.removeInput(previousDeviceInput)
      }

      guard let deviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(deviceInput) else {
        throw Camera.Error.missingInput
      }
      self.deviceInput = deviceInput
      session.addInput(deviceInput)

      if !session.outputs.contains(metadataOutput) {
        guard session.canAddOutput(metadataOutput) else {
          throw Camera.Error.missingOutput
        }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
      }

      guard metadataOutput.availableMetadataObjectTypes.contains(.qr) else {
        throw Camera.Error.missingMetadata
      }
      metadataOutput.metadataObjectTypes = [.qr]
    }
  }
}
