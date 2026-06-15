# WatchConnectivity Diagnostics Summary

## Issue Investigation: isPairedAppInstalled and Reachability

### Initial Problem Report
- Error: "No companion device is available" when sending messages via application context
- Connection status shows "Activated but not reachable"
- Testing on physical devices (iPhone + Apple Watch) with Stream demo app

### Key Findings

#### 1. Asymmetric Reachability (EXPECTED BEHAVIOR)
**Observation:**
- Apple Watch consistently shows `isReachable: true`
- iPhone consistently shows `isReachable: false`
- **Messages successfully send in both directions**

**Explanation:**
This is **normal WatchConnectivity behavior**:
- **watchOS**: Actively monitors iPhone reachability (battery less critical)
- **iOS**: Passively monitors Watch reachability (battery saving)
- Reachability can change dynamically during async operations
- State observed before send ≠ state during actual send

**Evidence from logs:**
```
📡 isReachable: false                           ← Snapshot before send
🚀 Sending message...                           ← Async send begins
✅ Message sent successfully via: binary        ← Send succeeds!
```

#### 2. isPairedAppInstalled Degradation (XCODE INSTALLATION ISSUE)
**Observation:**
```
Initial: isPairedAppInstalled: true    (on activation)
Degrades to: isPairedAppInstalled: false  (milliseconds later)
```

**Root Cause:**
Apps installed via **Xcode** during development don't properly register with WatchConnectivity's internal app database. The framework expects apps to be installed through the official Watch app companion installer.

**System Errors Observed:**
```
Application context data is nil
Type: Error | Library: WatchConnectivity | Subsystem: com.apple.wcd
```

**Impact:**
- UI displays incorrect status (`isPairedAppInstalled: false`)
- **Does NOT prevent message sending** (messages work fine!)
- Only affects status display and application context fallback

#### 3. Race Condition in State Observation
**Problem:**
Diagnostic info was captured too early, showing stale state values.

**Fix Applied:**
- Now reads live state from actor immediately before send
- Shows actual transport used after send completes
- Eliminates confusion between predicted and actual transport

### Binary Message Routing

The demo app uses **BinaryMessagable** types (Protobuf), which have different routing logic:

```swift
// Binary messages routing:
if session.isReachable:
    Use sendMessageData() for immediate delivery ✅
else:
    Throw error (cannot use application context) ❌
```

**Why messages work despite `isReachable: false` on iPhone:**
WatchConnectivity determines actual reachability during the send operation, not at the time of state observation.

### Solutions

#### For Production Deployment
1. **Install via Watch app (RECOMMENDED)**:
   - Build & Archive project
   - Install iOS app on iPhone via Xcode/TestFlight
   - **Install watchOS app via Watch app on iPhone** (not Xcode)
   - Launch both apps at least once
   - Result: `isPairedAppInstalled` will correctly show `true`

2. **Benefits**:
   - Correct status display
   - Application context fallback works properly
   - Matches real-world app distribution

#### For Development Builds (Current State)
1. **Accept the limitations**:
   - `isPairedAppInstalled: false` is expected with Xcode installation
   - Messages still work fine (via `sendMessageData`)
   - Status display is informational only

2. **Use enhanced diagnostics** (implemented):
   - Live state capture immediately before send
   - Actual transport logging after send
   - Clear understanding of timing issues

### Code Changes Made

#### 1. Enhanced Diagnostic Logging
**File**: `StreamMessageLabViewModel.swift`

**Before**:
```swift
// Captured stale state
print("📡 isReachable: \(isReachable)")  // @Published property
// ... send message
```

**After**:
```swift
// Capture live state from actor
let liveReachable = await connectivityObserver.isReachable()
let liveActivation = await connectivityObserver.activationState()
let livePairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
#if os(iOS)
  let livePaired = await connectivityObserver.isPaired()
#endif

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 CONNECTIVITY STATE (LIVE)")
print("🔄 Activation State: \(liveActivation)")
print("🔗 isPaired: \(livePaired)")
print("📱 isPairedAppInstalled: \(livePairedAppInstalled)")
print("📡 isReachable: \(liveReachable)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

let result = try await connectivityObserver.send(message)
print("✅ Message sent successfully via: \(result.context)")
print("📊 Actual transport used: \(result.context.transport)")
```

#### 2. WatchConnectivitySession Delegate Logging
**File**: `WatchConnectivitySession+WCSessionDelegate.swift`

Added debug logging to key callbacks:
```swift
#if DEBUG
  print("🔔 WCSession activation complete - state: \(activationState), isReachable: \(wcSession.isReachable), isPairedAppInstalled: \(wcSession.isPairedAppInstalled)")
#endif

#if DEBUG
  print("🔔 WCSession.sessionReachabilityDidChange fired - isReachable: \(session.isReachable)")
#endif
```

#### 3. Public API Additions

**File**: `ConnectivityObserver.swift`

Added public method to expose `updateApplicationContext`:
```swift
/// Updates the application context with new data.
public func updateApplicationContext(_ context: ConnectivityMessage) throws {
  try session.updateApplicationContext(context)
}
```

**Note**: This was added for investigation but not used in final solution.

**File**: `ConnectivitySendContext.swift`

Added computed property to extract transport from enum:
```swift
/// The transport mechanism used for this send operation, if applicable.
/// Returns `nil` for failure cases.
public var transport: MessageTransport? {
  switch self {
  case .applicationContext(let transport), .reply(_, let transport):
    return transport
  case .failure:
    return nil
  }
}
```

This allows cleaner access to the transport mechanism used for successful sends.

### Verification Steps

After rebuilding the apps, you should see:

**Improved Logging**:
```
📦 Message built successfully, type: Sundial_Demo_ColorMessage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 CONNECTIVITY STATE (LIVE)
🔄 Activation State: activated
🔗 isPaired: true
📱 isPairedAppInstalled: false  ← Still false with Xcode install
📡 isReachable: false           ← May be false on iPhone
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Sending message...
✅ Message sent successfully via: reply([:], transport: binary)
📊 Actual transport used: binary  ← Shows actual transport
```

**Expected Behavior**:
- Messages send successfully from both iPhone and Watch
- Live state may differ from cached @Published properties
- Actual transport used matches `sendMessageData` (binary)

### Platform-Specific Considerations

#### watchOS
- `isPaired` always `true` (implicit pairing with iPhone)
- `pairedUpdates()` API not available (marked `@available(watchOS, unavailable)`)
- Generally shows `isReachable: true` more consistently

#### iOS
- `isPaired` and `pairedUpdates()` available
- More conservative with reachability reporting (battery saving)
- May show `isReachable: false` even when Watch is active

### Related Files

**Modified Files**:
- `Examples/Sundial/Sources/SundialDemoStream/ViewModels/StreamMessageLabViewModel.swift`
- `Examples/Sundial/Sources/Shared/Views/ConnectionStatusView.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Views/StreamMessageLabView.swift`
- `Packages/SundialKitStream/Sources/SundialKitStream/MessageRouter.swift`
- `Packages/SundialKitStream/Sources/SundialKitStream/ConnectivityObserver.swift`
- `Sources/SundialKitConnectivity/WatchConnectivitySession+WCSessionDelegate.swift`

**Key Components**:
- `MessageRouter` - Intelligent transport selection (binary vs. dictionary, immediate vs. background)
- `ConnectivityObserver` - Actor-based observer with AsyncStream APIs
- `WatchConnectivitySession` - Protocol wrapper over WCSession

### References

**Apple Documentation**:
- [WatchConnectivity Framework](https://developer.apple.com/documentation/watchconnectivity)
- [WCSession.isReachable](https://developer.apple.com/documentation/watchconnectivity/wcsession/1615683-isreachable)
- [WCSession.isPairedAppInstalled](https://developer.apple.com/documentation/watchconnectivity/wcsession/2854556-ispairedappinstalled)

**SundialKit Architecture**:
- Layer 1: Core protocols and wrappers (SundialKitCore, SundialKitNetwork, SundialKitConnectivity)
- Layer 2: Observation plugins (SundialKitStream - modern async/await, SundialKitCombine - legacy Combine)
- Message encoding: Binary Protobuf via BinaryMessagable protocol

---

**Date**: 2025-11-10
**SundialKit Version**: v2.0.0 (Swift 6.1+)
**Issue Status**: Resolved - Messages work correctly, status display explained
