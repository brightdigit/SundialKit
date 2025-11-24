# ``SundialKitCore``

Core protocols and types for network monitoring and WatchConnectivity.

## Overview

SundialKitCore provides the protocol-based foundation for SundialKit's network monitoring and WatchConnectivity features. This package contains only protocols, type aliases, and errors—no concrete implementations.

> Important: SundialKitCore is not intended to be used directly. Instead, use it through the higher-level packages: ``SundialKitNetwork`` for network monitoring, ``SundialKitConnectivity`` for WatchConnectivity, and observation plugins (``SundialKitStream`` or ``SundialKitCombine``) for reactive patterns.

### Package Relationships

SundialKitCore serves as the foundation for:

- **SundialKitNetwork** - Implements network monitoring protocols using Apple's Network framework
- **SundialKitConnectivity** - Implements connectivity protocols using Apple's WatchConnectivity framework
- **SundialKitStream** - Provides AsyncStream-based observers for async/await projects
- **SundialKitCombine** - Provides Combine-based observers with @Published properties

## Topics

### Core Protocols

- ``NetworkMonitoring``
- ``ConnectivityManagement``
- ``Interfaceable``

### Network Status

- ``PathStatus``
- ``PathStatus/Interface``
- ``PathStatus/UnsatisfiedReason``

### Connectivity State

- ``ActivationState``

### Type Aliases

- ``ConnectivityMessage``

### Error Types

- ``NetworkError``
- ``ConnectivityError``
- ``SerializationError``
- ``SundialError``

### Utilities

- ``ObserverRegistry``
