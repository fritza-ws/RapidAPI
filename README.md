# Transloc Data Retrieval

This package wraps access to the Transloc API into a generics-based class that formats, checks, transmits, and interprets API usage.

It was originally created for the “UCMaps” subproject to fetch routes, stops, bus locations, and other sub-structures.

The API provider is RapidAPI, for which UChicago Web Services is a (free, key-based) licensee. It may be that other RapidAPI services return similar structures; if so, the generic `TranslocWrapper` can be used with little modification.  (`RapidAPI+Transloc+Wrapper.swift`) 

`RapidAPI.Verbs` is an example of how to generate and check URL requests, specialized for the query types supported by the service API.

## API Payloads

The API data structures are `Decodable` with a `JSONDecoder`. `Codable` requires a `struct` or `class` to define and receive the payload objects into Swift types.

`TranslocWrapper` interprets the JSON properties common to all responses. Its `data` field consists of the data specific to the type returned, such as routes or stops.

The payload `struct`s (the names begin with `Transloc`) are generic parameters to `TranslocWrapper`. The resolved struct uses that type for the `data` property, making it a complete decoding format for the API return.  


## Warnings

The separation of concerns and data types between the RapidAPI side and the application-specific code is far from complete, as witness the generic reply structure being named `TranslocWrapper`.
