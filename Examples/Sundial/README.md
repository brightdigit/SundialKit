# Sundial Demo Application

A comprehensive iOS/watchOS demonstration of SundialKit v2.0.0-alpha.1 capabilities, with focus on:
- **Binary protobuf messaging** with `BinaryMessagable`
- **Latency measurement** across different transport methods
- **Transport route comparison** (sendMessage vs updateApplicationContext)

## Project Structure

```
Examples/Sundial/
├── Protos/                          # Protocol Buffer schemas
│   ├── color_message.proto          # Simple color message (16 bytes)
│   ├── complex_message.proto        # Complex nested message (256+ bytes)
│   └── latency_test.proto           # Ping/pong latency testing
├── Sources/
│   ├── Shared/                      # Common code for both variants
│   │   ├── Models/
│   │   │   ├── ProtoExtensions.swift      # BinaryMessagable conformance
│   │   │   ├── LatencyTracker.swift       # Latency measurement tracking
│   │   │   └── TransportMethod.swift      # Transport method enumeration
│   │   ├── Views/                   # Reusable SwiftUI components
│   │   └── Utilities/               # Helper extensions
│   ├── SundialDemoCombine/          # Combine variant (@MainActor + Publishers)
│   │   ├── App/
│   │   ├── ViewModels/
│   │   └── Views/
│   └── SundialDemoStream/           # Stream variant (Actors + AsyncStream)
│       ├── App/
│       ├── ViewModels/
│       └── Views/
├── Tests/                           # Integration and unit tests
└── Package.swift                    # SPM configuration
```

## Features

### Tab 1: Message Transport Lab 🚀
- Build messages with variable complexity (Simple/Medium/Complex)
- Compare protobuf size vs dictionary encoding
- Manual transport method override for testing
- Real-time send/receive status tracking

### Tab 2: Latency Dashboard 📊
- Live round-trip time measurement
- Latency breakdown (encode/network/decode)
- Statistical analysis (avg/min/max/stddev)
- History graphing for last 20 messages

### Tab 3: Protocol Comparison 🔬
- Side-by-side Dictionary vs Protobuf comparison
- Encoding performance metrics
- Size savings visualization
- Interactive test runner

### Tab 4: Live Diagnostics 🔧
- Connection health monitoring
- Message queue status
- Transport method history
- Error logging and performance counters

## Protocol Buffers

### Generating Swift Code

The protobuf schemas need to be compiled to Swift before building:

```bash
# Install protoc if needed
brew install protobuf swift-protobuf

# Generate Swift code from .proto files
cd Examples/Sundial
protoc \
  --swift_out=Sources/Shared/Generated \
  --proto_path=Protos \
  Protos/*.proto
```

This generates:
- `color_message.pb.swift`
- `complex_message.proto.swift`
- `latency_test.pb.swift`

### BinaryMessagable Conformance

SwiftProtobuf types conform to `BinaryMessagable` via simple extensions:

```swift
extension Sundial_Demo_ColorMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)  // SwiftProtobuf method
  }

  public func encode() throws -> Data {
    try serializedData()  // SwiftProtobuf method
  }
}
```

No wrappers needed - direct conformance!

## Building and Running

### Requirements
- Xcode 16.0+
- Swift 6.1+
- iOS 16.0+ Simulator or Device
- watchOS 9.0+ Simulator or Device
- Protocol Buffer Compiler (protoc)

### Build Steps

1. **Generate protobuf Swift code**:
   ```bash
   cd Examples/Sundial
   mkdir -p Sources/Shared/Generated
   protoc --swift_out=Sources/Shared/Generated --proto_path=Protos Protos/*.proto
   ```

2. **Build with Swift Package Manager**:
   ```bash
   swift build
   ```

3. **Run Combine variant**:
   ```bash
   swift run SundialDemoCombine
   ```

4. **Run Stream variant**:
   ```bash
   swift run SundialDemoStream
   ```

## Testing Scenarios

### Scenario 1: Binary Encoding Efficiency
1. Navigate to Tab 3 (Protocol Comparison)
2. Send a Complex Message
3. Observe size savings (typically 75-80%)
4. Compare encoding/decoding times

### Scenario 2: Latency Measurement
1. Navigate to Tab 2 (Latency Dashboard)
2. Run "Latency Test" (sends 10 messages)
3. Observe RTT breakdown (encode/network/decode)
4. Check statistics and history graph

### Scenario 3: Transport Method Selection
1. Navigate to Tab 1 (Message Transport Lab)
2. Toggle reachability by backgrounding iPhone app
3. Observe automatic switch to updateApplicationContext
4. See queued message delivery when reachability restored

### Scenario 4: Large Payload Performance
1. Build Complex Message with 100 color_history entries
2. Send via binary encoding
3. Measure transmission time and size
4. Compare to dictionary equivalent

## Architecture Notes

### Direct Protobuf Conformance
Unlike typical wrapper patterns, we use direct conformance:

**Traditional (Wrapper Pattern)**:
```swift
struct ColorWrapper: BinaryMessagable {
  private var proto: ColorMessage
  // Boilerplate wrapper code...
}
```

**SundialKit (Direct Conformance)**:
```swift
extension ColorMessage: BinaryMessagable {
  // Thin adapter - no extra layer!
}
```

This eliminates unnecessary wrapper objects and simplifies the API.

### Concurrency Models

**Combine Variant**:
- `@MainActor` isolation
- `@Published` properties
- Combine publishers
- Best for: SwiftUI integration

**Stream Variant**:
- Actor-based isolation
- `AsyncStream` APIs
- Modern async/await
- Best for: Performance-critical apps

Both variants share the same UI components and protobuf models.

## Performance Benchmarks

Expected results (actual values vary by device/network):

| Metric | Dictionary | Protobuf | Savings |
|--------|-----------|----------|---------|
| Simple Color | 95 bytes | 16 bytes | 83% |
| + Metadata | 187 bytes | 42 bytes | 77% |
| Complex | 1.2 KB | 256 bytes | 79% |
| Encode Time | 2.3ms | 0.4ms | 83% |
| Decode Time | 1.8ms | 0.3ms | 83% |

## References

- [SundialKit Documentation](../../README.md)
- [SwiftProtobuf](https://github.com/apple/swift-protobuf)
- [Protocol Buffers](https://protobuf.dev/)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)

## License

Same license as SundialKit (MIT).
