//
//  TransportControlView.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
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

import SundialDemoShared
import SwiftUI

/// Transport Control section for selecting transport methods and sending messages
@available(iOS 16.0, watchOS 9.0, *)
public struct TransportControlView: View {
  @Binding public var selectedTransportMethod: TransportMethod?
  public let effectiveTransportMethod: TransportMethod
  public let automaticTransportMethod: TransportMethod
  public let isSending: Bool
  public let isReachable: Bool
  public let onSend: () async -> Void

  public init(
    selectedTransportMethod: Binding<TransportMethod?>,
    effectiveTransportMethod: TransportMethod,
    automaticTransportMethod: TransportMethod,
    isSending: Bool,
    isReachable: Bool,
    onSend: @escaping () async -> Void
  ) {
    self._selectedTransportMethod = selectedTransportMethod
    self.effectiveTransportMethod = effectiveTransportMethod
    self.automaticTransportMethod = automaticTransportMethod
    self.isSending = isSending
    self.isReachable = isReachable
    self.onSend = onSend
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Transport Control")
        .font(.headline)

      // Transport method selector
      VStack(spacing: 8) {
        HStack {
          Text("Transport Method")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Spacer()

          if selectedTransportMethod == nil {
            Text("Auto")
              .font(.caption)
              .foregroundColor(.blue)
          }
        }

        HStack(spacing: 8) {
          TransportBadge(
            method: .sendMessage,
            isActive: effectiveTransportMethod == .sendMessage
          )
          .onTapGesture {
            selectedTransportMethod =
              selectedTransportMethod == .sendMessage ? nil : .sendMessage
          }

          TransportBadge(
            method: .sendMessageData,
            isActive: effectiveTransportMethod == .sendMessageData
          )
          .onTapGesture {
            selectedTransportMethod =
              selectedTransportMethod == .sendMessageData ? nil : .sendMessageData
          }

          TransportBadge(
            method: .updateApplicationContext,
            isActive: effectiveTransportMethod == .updateApplicationContext
          )
          .onTapGesture {
            selectedTransportMethod =
              selectedTransportMethod == .updateApplicationContext
                ? nil : .updateApplicationContext
          }
        }

        if selectedTransportMethod == nil {
          Text("Automatic: \(automaticTransportMethod.displayName)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.grayBackgroundColor)
      )

      // Send button
      Button(action: { Task { await onSend() } }) {
        HStack {
          if isSending {
            ProgressView()
              .progressViewStyle(.circular)
          } else {
            Image(systemName: "paperplane.fill")
          }

          Text(isSending ? "Sending..." : "Send Message")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isReachable ? Color.blue : Color.orange)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(isSending)
    }
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct TransportControlView_Previews: PreviewProvider {
    static var previews: some View {
      TransportControlView(
        selectedTransportMethod: .constant(nil),
        effectiveTransportMethod: .sendMessage,
        automaticTransportMethod: .sendMessage,
        isSending: false,
        isReachable: true,
        onSend: {}
      )
      .padding()
    }
  }
#endif
