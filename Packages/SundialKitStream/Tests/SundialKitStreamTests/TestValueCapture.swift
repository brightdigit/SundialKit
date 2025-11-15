//
//  TestValueCapture.swift
//  SundialKitStream
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

@testable import SundialKitConnectivity
@testable import SundialKitCore
@testable import SundialKitStream

/// Actor for safely capturing values in concurrent test scenarios
///
/// Provides actor-isolated storage to prevent data races when capturing
/// values from AsyncStreams and Tasks in Swift 6.1+ strict concurrency mode.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
internal actor TestValueCapture {
  // MARK: - Connectivity State Values

  internal var activationState: ActivationState?
  internal var activationResult: Result<ActivationState, any Error>?
  internal var reachability: Bool?
  internal var pairedAppInstalled: Bool?
  internal var paired: Bool?

  // MARK: - Message Values

  internal var message: ConnectivityReceiveResult?
  internal var messages: [ConnectivityReceiveResult] = []
  internal var typedMessage: (any Messagable)?

  // MARK: - Network Values

  internal var pathStatus: PathStatus?
  internal var pathStatuses: [PathStatus] = []

  // MARK: - Generic Values

  internal var boolValue: Bool?
  internal var boolValues: [Bool] = []
  internal var stringValue: String?

  // MARK: - Initialization

  internal init() {}

  // MARK: - Setters

  internal func set(activationState: ActivationState) {
    self.activationState = activationState
  }

  internal func set(activationResult: Result<ActivationState, any Error>) {
    self.activationResult = activationResult
  }

  internal func set(reachability: Bool) {
    self.reachability = reachability
  }

  internal func set(pairedAppInstalled: Bool) {
    self.pairedAppInstalled = pairedAppInstalled
  }

  internal func set(paired: Bool) {
    self.paired = paired
  }

  internal func set(message: ConnectivityReceiveResult) {
    self.message = message
  }

  internal func append(message: ConnectivityReceiveResult) {
    self.messages.append(message)
  }

  internal func set(typedMessage: any Messagable) {
    self.typedMessage = typedMessage
  }

  internal func set(pathStatus: PathStatus) {
    self.pathStatus = pathStatus
  }

  internal func append(pathStatus: PathStatus) {
    self.pathStatuses.append(pathStatus)
  }

  internal func set(boolValue: Bool) {
    self.boolValue = boolValue
  }

  internal func append(boolValue: Bool) {
    self.boolValues.append(boolValue)
  }

  internal func set(stringValue: String) {
    self.stringValue = stringValue
  }

  // MARK: - Getters (for clarity, though direct property access works)

  internal func getActivationState() -> ActivationState? {
    activationState
  }

  internal func getActivationResult() -> Result<ActivationState, any Error>? {
    activationResult
  }

  internal func getReachability() -> Bool? {
    reachability
  }

  internal func getPairedAppInstalled() -> Bool? {
    pairedAppInstalled
  }

  internal func getPaired() -> Bool? {
    paired
  }

  internal func getMessage() -> ConnectivityReceiveResult? {
    message
  }

  internal func getMessages() -> [ConnectivityReceiveResult] {
    messages
  }

  internal func getTypedMessage() -> (any Messagable)? {
    typedMessage
  }

  internal func getPathStatus() -> PathStatus? {
    pathStatus
  }

  internal func getPathStatuses() -> [PathStatus] {
    pathStatuses
  }

  internal func getBoolValue() -> Bool? {
    boolValue
  }

  internal func getBoolValues() -> [Bool] {
    boolValues
  }

  internal func getStringValue() -> String? {
    stringValue
  }

  // MARK: - Reset

  internal func reset() {
    activationState = nil
    activationResult = nil
    reachability = nil
    pairedAppInstalled = nil
    paired = nil
    message = nil
    messages = []
    typedMessage = nil
    pathStatus = nil
    pathStatuses = []
    boolValue = nil
    boolValues = []
    stringValue = nil
  }
}
