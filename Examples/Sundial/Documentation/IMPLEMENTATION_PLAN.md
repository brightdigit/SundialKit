# Sundial Demo - Implementation Plan

**Status**: Phase 1 Complete - Foundation Established
**Last Updated**: 2025-10-26
**Task Master**: Task 13 - Migrate Sundial demo application to SundialKit v2.0.0

## Project Overview

This demo showcases SundialKit v2.0.0 with focus on:
1. **Binary Protobuf Messaging** - Efficient binary encoding with BinaryMessagable
2. **Latency Measurement** - Round-trip time tracking across transport methods
3. **Transport Route Comparison** - sendMessage vs updateApplicationContext behavior

Two implementation variants:
- **SundialDemoCombine**: @MainActor + Combine publishers (v1 compatibility)
- **SundialDemoStream**: Actor-based + AsyncStream (modern async/await)

---

## ✅ Phase 1: Foundation (COMPLETED)

### Directory Structure
```
Examples/Sundial/
├── Protos/                          # Protocol Buffer schemas ✓
│   ├── color_message.proto          # Simple color (16 bytes) ✓
│   ├── complex_message.proto        # Complex nested (256+ bytes) ✓
│   └── latency_test.proto           # Ping/pong testing ✓
├── Sources/
│   ├── Shared/                      # Common code ✓
│   │   ├── Models/
│   │   │   ├── ProtoExtensions.swift      # BinaryMessagable conformance ✓
│   │   │   ├── LatencyTracker.swift       # Latency tracking ✓
│   │   │   └── TransportMethod.swift      # Transport enum ✓
│   │   ├── Utilities/
│   │   │   ├── Color+Components.swift     # Color helpers ✓
│   │   │   └── Date+Milliseconds.swift    # Date helpers ✓
│   │   └── Views/                   # (Next phase)
│   ├── SundialDemoCombine/          # (Next phase)
│   └── SundialDemoStream/           # (Next phase)
├── Scripts/
│   └── generate-protos.sh           # Protobuf generation script ✓
├── Package.swift                    # SPM configuration ✓
└── README.md                        # Documentation ✓
```

### Key Accomplishments

1. **Protobuf Schemas Defined** ✓
   - `ColorMessage`: Simple color data (red/green/blue/alpha + timestamp)
   - `ComplexMessage`: Nested message with sensors, device info, color history
   - `LatencyTestRequest/Reply`: Ping/pong with timestamps

2. **BinaryMessagable Direct Conformance** ✓
   - No wrapper pattern needed
   - Simple extensions on SwiftProtobuf types
   - Convenience helpers for SwiftUI Color conversion

3. **Shared Infrastructure** ✓
   - `TransportMethod` enum with metadata
   - `LatencyTracker` for performance measurement
   - Utility extensions for Date and Color

4. **Build Configuration** ✓
   - Package.swift with all dependencies
   - Script for protobuf code generation
   - Comprehensive README

---

## 📋 Phase 2: Shared UI Components (NEXT)

### Components to Create

#### 1. MetricCard.swift
Reusable card for displaying key-value metrics:
```swift
struct MetricCard: View {
  let title: String
  let value: String
  let subtitle: String?
  let icon: String
  let color: Color
}
```

Used for:
- RTT display
- Payload size
- Success rate
- Encode/decode times

#### 2. TransportBadge.swift
Visual indicator for transport method:
```swift
struct TransportBadge: View {
  let method: TransportMethod
  let isActive: Bool
}
```

Shows icon + name with color coding.

#### 3. LatencyGraph.swift
Line chart for latency history:
```swift
struct LatencyGraph: View {
  let measurements: [LatencyTracker.Measurement]
  let height: CGFloat = 150
}
```

Displays last 20 measurements with color coding by transport method.

#### 4. MessageHistoryRow.swift
Row item for message history list:
```swift
struct MessageHistoryRow: View {
  let timestamp: Date
  let method: TransportMethod
  let size: Int
  let rtt: TimeInterval?
  let success: Bool
}
```

#### 5. ConnectionStatusView.swift
Real-time connection health indicator:
```swift
struct ConnectionStatusView: View {
  let isReachable: Bool
  let activationState: ActivationState
  let lastUpdate: Date
}
```

Compact footer showing network + connectivity status.

#### 6. ColorPreview.swift
Color circle with metadata:
```swift
struct ColorPreview: View {
  let color: Color
  let timestamp: Date?
  let source: String?
  let size: CGFloat = 60
}
```

---

## 📋 Phase 3: Combine Variant Implementation

### 3.1 App Structure

**SundialApp.swift**
```swift
@main
struct SundialApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

**ContentView.swift**
```swift
struct ContentView: View {
  var body: some View {
    TabView {
      MessageLabView()
        .tabItem { Label("Transport", systemImage: "arrow.left.arrow.right") }

      LatencyDashboardView()
        .tabItem { Label("Latency", systemImage: "clock") }

      ProtocolComparisonView()
        .tabItem { Label("Protocol", systemImage: "chart.bar") }

      DiagnosticsView()
        .tabItem { Label("Diagnostics", systemImage: "wrench") }
    }
  }
}
```

### 3.2 ViewModels

Each tab needs a ViewModel with ConnectivityObserver and/or NetworkObserver:

**MessageLabViewModel.swift**
- Manages message payload builder
- Handles transport method selection
- Sends/receives ColorMessage and ComplexMessage
- Tracks send status

**LatencyViewModel.swift**
- Uses LatencyTracker
- Sends LatencyTestRequest messages
- Processes LatencyTestReply
- Generates statistics

**ProtocolViewModel.swift**
- Compares Dictionary vs Protobuf encoding
- Measures encoding/decoding times
- Calculates size savings
- Runs interactive tests

**DiagnosticsViewModel.swift**
- Monitors connection health
- Displays error log
- Shows performance counters
- Provides raw state dump

### 3.3 Views

#### Tab 1: MessageLabView.swift
Sections:
1. Payload Builder (complexity slider)
2. Transport Method Control (auto/manual override)
3. Send Button
4. Sent/Received Display

#### Tab 2: LatencyDashboardView.swift
Sections:
1. Live RTT Metrics (large display)
2. Statistics Cards (avg/min/max/stddev)
3. Latency Breakdown (encode/network/decode)
4. History Graph
5. Test Runner

#### Tab 3: ProtocolComparisonView.swift
Sections:
1. Encoding Comparison (side-by-side)
2. Complexity Scaling Table
3. Interactive Test
4. Protocol Schema Display

#### Tab 4: DiagnosticsView.swift
Sections:
1. Connection Health (reachability + session state)
2. Message Queue Status
3. Transport History (ScrollView)
4. Error Log
5. Performance Counters

---

## 📋 Phase 4: Stream Variant Implementation

Port all Combine ViewModels to Stream equivalents:
- Replace @Published with AsyncStream
- Replace Combine publishers with actor methods
- Use async/await throughout
- Maintain identical UI

---

## 📋 Phase 5: Testing & Polish

### Integration Tests
- Protobuf encoding/decoding
- Transport method selection logic
- Latency measurement accuracy
- UI state updates

### UI Tests
- Tab navigation
- Message sending flow
- Error handling
- Connection state transitions

### Polish
- Animations
- Error messages
- Loading states
- Accessibility

---

## Implementation Notes

### Protobuf Code Generation

Before building, generate Swift code from .proto files:

```bash
cd Examples/Sundial
./Scripts/generate-protos.sh
```

This creates `Sources/Shared/Generated/*.pb.swift` files.

### Direct BinaryMessagable Conformance

Key insight: No wrapper pattern needed!

```swift
extension Sundial_Demo_ColorMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)  // SwiftProtobuf already has this!
  }

  public func encode() throws -> Data {
    try serializedData()  // SwiftProtobuf already has this!
  }
}
```

### Transport Method Selection Logic

```swift
func selectTransportMethod(isReachable: Bool, override: TransportMethod?) -> TransportMethod {
  if let override = override {
    // Manual override for testing
    guard !override.requiresReachability || isReachable else {
      throw TransportError.notReachable
    }
    return override
  }

  // Automatic selection
  return isReachable ? .sendMessage : .updateApplicationContext
}
```

### Latency Measurement Pattern

```swift
// 1. Start timer
let sendTime = Date()

// 2. Encode
let encodeStart = Date()
let data = try message.encode()
let encodeTime = Date().timeIntervalSince(encodeStart)

// 3. Send and await reply
let reply = try await connectivityObserver.sendMessage(data)

// 4. Decode
let decodeStart = Date()
let replyMsg = try LatencyTestReply(from: reply)
let decodeTime = Date().timeIntervalSince(decodeStart)

// 5. Record measurement
let receiveTime = Date()
latencyTracker.recordMeasurement(
  .init(
    sequenceNumber: sequence,
    sendTime: sendTime,
    receiveTime: receiveTime,
    transportMethod: .sendMessage,
    payloadSize: data.count,
    encodeTime: encodeTime,
    decodeTime: decodeTime
  )
)
```

---

## Success Criteria

- ✅ Protobuf messages show 75%+ size reduction vs dictionary
- ✅ Latency measurements accurate within 5ms
- ✅ Transport method selection correct based on reachability
- ✅ All routes work (sendMessage, updateApplicationContext, sendMessageData)
- ✅ Complex messages encode/decode correctly
- ✅ Connection transitions handled gracefully
- ✅ UI clearly explains behavior
- ✅ Both variants behave identically

---

## Next Session Tasks

1. **Generate Protobuf Code**
   ```bash
   cd Examples/Sundial
   mkdir -p Sources/Shared/Generated
   ./Scripts/generate-protos.sh
   ```

2. **Create Shared UI Components**
   - Start with MetricCard (most reusable)
   - Then TransportBadge
   - Then ColorPreview
   - Test with SwiftUI previews

3. **Implement First Tab (Combine Variant)**
   - MessageLabViewModel
   - MessageLabView
   - Wire up ConnectivityObserver
   - Test message sending

4. **Continue with remaining tabs**

---

## References

- **Task Master**: Task 13, Subtask 13.2 (v1.0.0 validation baseline)
- **CLAUDE.md**: Main project documentation
- **Package.swift**: Dependencies and target configuration
- **Protos/**: Protocol Buffer schema definitions
- **Sources/Shared/Models/ProtoExtensions.swift**: BinaryMessagable conformance examples

---

**Resume Point**: Phase 2 - Create shared UI components starting with MetricCard.swift
