# ``SundialKit/NetworkObserver``

## Topics

### Start Listening

- ``init()``
- ``start(queue:)``
- ``cancel()``
`
### Getting Network Status

- ``pathStatusPublisher``
- ``PathStatus``
- ``PathStatus/Interface``
- ``PathStatus/UnsatisfiedReason``
- ``isExpensivePublisher``
- ``isConstrainedPublisher``

### Using a Network Ping to Test Connectivity

Rather than relying on only your `PathMonitor`, you can setup a periodic ping to the network.

- ``init(ping:)``
- ``pingStatusPublisher``
- ``NetworkPing``
- ``NeverPing``

### Custom Path Monitors

Typically you'll want to use `NWPathMonitor` most of the time. However if you want to build your own, that's available:

- ``init(monitor:)``
- ``init(monitor:ping:)``
- ``PathMonitor``
- ``NetworkPath``
