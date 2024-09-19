# AppleMapsKit

🗺️ Integrate the [Apple Maps Server API](https://developer.apple.com/documentation/applemapsserverapi) into Swift server applications

## Overview

Use this web-based service to streamline your app’s API by moving georelated searches for places, points of interest, geocoding, directions, possible autocompletions for searches, and estimated time of arrival (ETA) calculations from inside your app to your server.

### Getting Started

Use the SPM string to easily include the dependendency in your `Package.swift` file

```swift
.package(url: "https://github.com/fpseverino/apple-maps-kit.git", from: "0.1.0")
```

and add it to your target's dependencies:

```swift
.product(name: "AppleMapsKit", package: "apple-maps-kit")
```

### Geocode an address

Returns the latitude and longitude of the address you specify.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let places = try await client.geocode(address: "1 Apple Park, Cupertino, CA")
```

### Reverse geocode a location

Returns an array of addresses present at the coordinates you provide.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let places = try await client.reverseGeocode(latitude: 37.33182, longitude: -122.03118)
```

### Search for places that match specific criteria

Find places by name or by specific search criteria.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let searchResponse = try await client.search(for: "eiffel tower")
```

### Search for places that meet specific criteria to autocomplete a place search

Find results that you can use to autocomplete searches.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let results = try await client.searchAutoComplete(for: "eiffel")
```

### Search for directions and estimated travel time between locations

Find directions by specific criteria.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let directions = try await client.directions(
    origin: "37.7857,-122.4011",
    destination: "San Francisco City Hall, CA"
)
```

### Determine estimated arrival times and distances to one or more destinations

Returns the estimated time of arrival (ETA) and distance between starting and ending locations.

```swift
import AppleMapsKit
import AsyncHTTPClient

let client = try await AppleMapsClient(
    httpClient: HTTPClient(...),
    teamID: "DEF123GHIJ",
    keyID: "ABC123DEFG",
    key: """
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
    """
)

let coordinateEtas = try await client.eta(
    from: (latitude: 37.331423, longitude: -122.030503),
    to: [
        (latitude: 37.32556561130194, longitude: -121.94635203581443),
        (latitude: 37.44176585512703, longitude: -122.17259315798667)
    ]
)

let addressEtas = try await client.etaBetweenAddresses(
    from: "San Francisco City Hall, CA",
    to: ["Golden Gate Park, San Francisco"],
)
```
