# Latency Tab Implementation - Investigation Notes

**Date:** November 7, 2025
**Status:** In Progress - Reachability Instability Issue
**Component:** SundialDemoStream (Stream variant)

## Summary

Implemented a latency testing feature for the Sundial demo app that measures round-trip time (RTT) between iPhone and Apple Watch using WatchConnectivity. The implementation works correctly from a code perspective, but we're encountering WatchConnectivity reachability stability issues that prevent reliable operation.

## What Was Implemented

### 1. LatencyResponderService (NEW)

**File:** `Examples/Sundial/Sources/SundialDemoStream/Services/LatencyResponderService.swift`

**Purpose:** App-level service that automatically responds to latency test requests from the paired device.

**Key Features:**
- Actor-based for thread safety
- Listens to `typedMessageStream()` for incoming `LatencyTestRequest` messages
- Automatically replies with `LatencyTestReply` containing timing information
- Runs independently of UI tabs (initialized at app level)

**Architecture:**
```swift
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
public actor LatencyResponderService {
  private let connectivityObserver: ConnectivityObserver

  public init(connectivityObserver: ConnectivityObserver) {
    // Starts listening in background task
  }

  private func handleLatencyRequest(_ request: Sundial_Demo_LatencyTestRequest) async {
    // Auto-replies with LatencyTestReply
  }
}
```

**Integration:**
- Initialized in `SundialStreamAppMain.swift` at app startup
- Uses shared `ConnectivityObserver` instance to avoid WCSession delegate conflicts
- Listens for `Sundial_Demo_LatencyTestRequest` and `Sundial_Demo_LatencyTestReply` messages

### 2. StreamLatencyDashboardViewModel (MODIFIED)

**File:** `Examples/Sundial/Sources/SundialDemoStream/ViewModels/StreamLatencyDashboardViewModel.swift`

**Changes Made:**
1. **Removed duplicate ConnectivityObserver creation** - Now requires observer as constructor parameter
2. **Added reachability tracking:**
   - `var isReachable: Bool = false` - Tracks current reachability state
   - Subscribes to `reachabilityUpdates()` stream
   - Checks reachability before sending each ping
3. **Enhanced logging** for debugging:
   - Logs each ping sent with sequence number and transport method
   - Logs received replies
   - Logs reachability status

**Key Methods:**
- `sendLatencyPing()` - Sends a single latency test request (checks reachability first)
- `startLatencyTest()` - Starts automated testing (pings every 2 seconds)
- `consumeLatencyReplies()` - Listens for replies and records measurements

### 3. StreamLatencyDashboardView (MODIFIED)

**File:** `Examples/Sundial/Sources/SundialDemoStream/App/StreamLatencyDashboardView.swift`

**UI Enhancements:**
1. **Reachability warning banner** - Shows when devices are not reachable:
   ```
   ⚠️ Devices Not Reachable
   Ensure both apps are in foreground and Bluetooth is connected
   ```
2. **Disabled button state** - Start Test button becomes gray when not reachable
3. **Fixed ViewModel initialization** - Now passes shared ConnectivityObserver from environment

### 4. ConnectivityObserverEnvironment (MODIFIED)

**File:** `Examples/Sundial/Sources/SundialDemoStream/Environment/ConnectivityObserverEnvironment.swift`

**Changes:**
- Changed from optional to **non-optional** environment value
- Made all declarations `public` for cross-module access
- Provides proper default value with message decoders for latency types

### 5. SundialStreamAppMain (MODIFIED)

**File:** `Examples/Sundial/Apps/SundialStream/SundialStreamAppMain.swift`

**Changes:**
1. Added latency message types to `MessageDecoder`:
   - `Sundial_Demo_LatencyTestRequest.self`
   - `Sundial_Demo_LatencyTestReply.self`
2. Initialized `LatencyResponderService` at app level
3. Enhanced logging for initialization tracking

## Critical Bug Fix - Reachability State Not Initialized

### The Problem

`ConnectivityObserver.isReachable()` was always returning `false` even when the underlying `WCSession.isReachable` was `true`.

**Root Cause:**
- `sessionReachabilityDidChange` delegate method is **only called when reachability CHANGES**
- If devices are already reachable when session activates, delegate is never called
- `ConnectivityStateManager` state defaulted to `isReachable = false` and never got updated

### The Fix

**Modified Files:**
1. `Packages/SundialKitStream/Sources/SundialKitStream/StateHandling+MessageHandling.swift`
2. `Packages/SundialKitStream/Sources/SundialKitStream/StateHandling.swift`
3. `Packages/SundialKitStream/Sources/SundialKitStream/ConnectivityStateManager.swift`

**Changes:**
- Pass `session` parameter to `handleActivation()` method
- Read initial state from session when activation completes:
  ```swift
  internal func handleActivation(_ activationState: ActivationState, error: (any Error)?, session: any ConnectivitySession) async {
    // Read the current state from the session since sessionReachabilityDidChange
    // is only called when reachability CHANGES, not on initial activation
    let currentReachability = session.isReachable
    let currentIsPairedAppInstalled = session.isPairedAppInstalled
    let currentIsPaired = session.isPaired

    // Update state with actual values from session
    state = ConnectivityState(
      activationState: activationState,
      activationError: error,
      isReachable: currentReachability,  // ← Was: state.isReachable (always false)
      isPairedAppInstalled: currentIsPairedAppInstalled,
      isPaired: currentIsPaired
    )
  }
  ```

## Current Issue - WatchConnectivity Reachability Instability

### Symptoms

Reachability flickers between `true` and `false` rapidly during the first few seconds after session activation:

**Watch Logs:**
```
📡 StateManager: Reachability changed: false → true
📡 StateManager: Reachability changed: true → false
📡 StateManager: Reachability changed: false → true
```

**iPhone Logs:**
```
📡 StateManager: Reachability changed: true → false
📡 StateManager: Reachability changed: false → true
```

By the time user navigates to Latency tab, reachability has often settled back to `false`.

### Why This Happens

WatchConnectivity `isReachable` behavior:
1. Requires **both apps in foreground** (not just running)
2. Requires active Bluetooth connection
3. Connection takes time to stabilize after activation
4. Can drop if either app is backgrounded (even briefly)
5. May require active communication to remain stable

### What Works vs What Doesn't

**✅ Works:**
- Sending ColorMessages via binary transport (successfully transmitted in logs)
- LatencyResponderService receives messages and auto-replies
- State synchronization after bug fix
- UI correctly reflects reachability state

**❌ Doesn't Work Reliably:**
- Maintaining stable `isReachable = true` state
- Latency measurements (requires stable reachability for binary messages)

### Evidence from Logs

Both devices DO achieve reachability briefly, but it's unstable:

```
iPhone:
📡 StateManager: Activation complete - reading initial state from session
   - isReachable: true  ← STARTS TRUE
📡 StateManager: Reachability changed: true → false  ← DROPS
📡 StateManager: Reachability changed: false → true  ← RECOVERS

Watch:
📡 StateManager: Activation complete - reading initial state from session
   - isReachable: false  ← STARTS FALSE
📡 StateManager: Reachability changed: false → true  ← BECOMES TRUE
📡 StateManager: Reachability changed: true → false  ← DROPS
📡 StateManager: Reachability changed: false → true  ← RECOVERS

[User navigates to Latency tab]
📡 Latency Dashboard: Initial reachability: false  ← DROPPED AGAIN
```

## Potential Solutions (Not Yet Implemented)

### 1. Keep-Alive Mechanism
Send lightweight messages periodically to maintain connection stability:
```swift
// Ping every 5 seconds to keep connection alive
Timer.publish(every: 5, on: .main, in: .common)
  .sink { _ in
    Task {
      try? await connectivityObserver.send(KeepAliveMessage())
    }
  }
```

### 2. Reachability Debouncing
Wait for reachability to stabilize before enabling UI:
```swift
// Only consider reachable after 3 consecutive "true" readings
// Or stable "true" for 2 seconds
```

### 3. Fallback to Dictionary Transport
For latency testing, could fall back to dictionary messages when binary unavailable:
- Still measure RTT
- Slightly less efficient but more reliable
- Works via application context when not reachable

### 4. User Guidance
Add explicit instructions:
- "Keep both devices unlocked and apps visible"
- Show connection quality indicator
- Suggest re-establishing connection steps

### 5. Background Reachability (Investigate)
Research if there's a way to maintain reachability while backgrounded (likely not possible with WatchConnectivity design).

## Next Steps

### Immediate Investigation Needed

**Test if tab switching causes reachability loss:**
1. Launch both apps
2. Navigate to Latency tab on both devices
3. Check logs - is reachability `true`?
4. Switch to different tab on one device
5. Check logs - does reachability drop to `false`?
6. Switch back to Latency tab
7. Check logs - does reachability recover?

### Potential Implementations

1. **Keep-alive mechanism** - Most promising for maintaining stable connection
2. **Connection diagnostics view** - Help users understand why connection isn't stable
3. **Automatic retry logic** - If reachability drops during test, pause and resume when recovered
4. **Alternative transport fallback** - Use dictionary messages if binary unavailable

## Files Modified

### SundialKit Core (Packages)
- `Packages/SundialKitStream/Sources/SundialKitStream/StateHandling+MessageHandling.swift`
- `Packages/SundialKitStream/Sources/SundialKitStream/StateHandling.swift`
- `Packages/SundialKitStream/Sources/SundialKitStream/ConnectivityStateManager.swift`

### Demo App
- `Examples/Sundial/Apps/SundialStream/SundialStreamAppMain.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Services/LatencyResponderService.swift` (NEW)
- `Examples/Sundial/Sources/SundialDemoStream/ViewModels/StreamLatencyDashboardViewModel.swift`
- `Examples/Sundial/Sources/SundialDemoStream/App/StreamLatencyDashboardView.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Environment/ConnectivityObserverEnvironment.swift`

## Technical Learnings

### WatchConnectivity Behavior
1. **`isReachable` is very strict** - Requires both apps actively in foreground
2. **Connection takes time to stabilize** - Can flicker for several seconds after activation
3. **Binary messages require reachability** - Cannot use application context as fallback
4. **Delegate methods only fire on CHANGES** - Must read initial state from session
5. **Active communication helps** - Sending messages seems to maintain connection better

### Actor-Based Architecture
1. **Multiple stream consumers work correctly** - Both LatencyResponderService and LatencyDashboardViewModel can consume same `typedMessageStream()`
2. **StreamContinuationManager broadcasts to all** - Messages are delivered to all registered continuations
3. **Actor isolation prevents races** - Thread-safe message handling

### SwiftUI Environment Values
1. **Non-optional environment values** - Better than optional when value is always available
2. **Cross-module access** - Requires `public` declarations
3. **Default value initialization** - Can provide proper defaults with dependencies

## Testing Notes

**Hardware Tested:**
- Real iPhone (model unknown from logs)
- Real Apple Watch (model unknown from logs)
- Both running iOS/watchOS with SundialStream app

**Test Scenarios:**
1. ✅ App launches successfully on both devices
2. ✅ LatencyResponderService initializes
3. ✅ ConnectivityObserver activates
4. ✅ UI shows reachability warning when not connected
5. ❌ Reachability remains stable
6. ❌ Latency measurements complete successfully

## Outstanding Questions

1. **Why does ColorMessage transport work reliably but latency doesn't?**
   - ColorMessages may be sent at times when reachability happens to be stable
   - Or they may benefit from some timing/buffering behavior

2. **Does tab switching on either device cause reachability loss?**
   - Need to test explicitly with logging

3. **Is there a WatchConnectivity best practice for maintaining reachability?**
   - Research Apple's documentation and sample code
   - Look for similar issues in WatchConnectivity GitHub discussions

4. **Should we implement fallback to dictionary transport for latency testing?**
   - Would be less efficient but more reliable
   - Could measure RTT even when not "reachable" via application context

## References

- **WatchConnectivity Framework:** https://developer.apple.com/documentation/watchconnectivity
- **WCSession.isReachable:** https://developer.apple.com/documentation/watchconnectivity/wcsession/1615683-isreachable
- **Binary vs Dictionary Messages:** https://developer.apple.com/documentation/watchconnectivity/wcsession/1615687-sendmessagedata

## Commit Message (When Ready)

```
feat(demo): implement latency testing with reachability tracking

- Add LatencyResponderService for auto-replying to latency requests
- Fix ConnectivityObserver reachability state initialization bug
- Add reachability UI indicators and warnings
- Enhance logging for reachability debugging

Known Issue: WatchConnectivity reachability unstable during first
few seconds after activation. Both devices briefly achieve reachable
state but connection flickers. Investigating keep-alive mechanisms.

Component: SundialDemoStream
Issue: Reachability instability prevents reliable latency measurements
```
