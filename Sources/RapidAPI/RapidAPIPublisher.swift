//
//  RapidAPIPublisher.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation
import Combine


// TODO: a combination request-builder and decoder?
//       Actually, not a good idea. Why weld this
//       publisher inside the verb process?

// Maybe _someday_ create an object that wraps both,
// takes verb + parameters, then fetches. Doesn't actually
// sound more useful than the trouble.

// TODO: For testing, have a way to inject JSON data responding to
//       each verb


/// A Combine `Publisher` with `Output` being a generic `Payload` value.
///
/// Implemented in terms of `RapidAPIWrapper` and `URLSession.DataTaskPublisher`.
///
/// # Errors
///
/// * `TLPublisherErrors.badStatusCode(status)` if the HTTP status is outside of `200..<400`
/// * `TLPublisherErrors.fatalMissingResponse` if the server returned no content.
/// * Whatever might come out of the data task publisher.

public
final class RapidAPIPublisher<Payload>
where Payload: Decodable
// : Publisher
{
    /// The request used to fetch the `RapidAPIWrapper<Payload>`.
    let request: URLRequest
    /// (convenience) the JSON -> `RapidAPIWrapper<Payload>` decoder
    let decoder: JSONDecoder = {
        let retval = JSONDecoder()
        return retval
    }()

    /// The usual holding point for cancellables.
    /// So far, this object doesn't produce anything cancellable.
    private var cancellables: Set<AnyCancellable> = []

    public enum TLPublisherErrors: Error {
        case badStatusCode(Int)
        case fatalMissingResponse
    }

    public lazy var publisher: AnyPublisher<Payload, Error> = {
        let session = URLSession.shared
        let retval  = session.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TLPublisherErrors.fatalMissingResponse
                }

                let contents = String(data: data, encoding: .utf8)
                    ?? "Can't decode contents, data length \(data.count)"
                print(response.url?.absoluteURL ?? "NO URL", contents)

                let statusCode = httpResponse.statusCode
                guard (200..<400).contains(statusCode) else {
                    throw TLPublisherErrors.badStatusCode(statusCode) }
                return data
            }
            // This is where you'd inject JSON data for testing.
            .decode(type: RapidAPIWrapper<Payload>.self, decoder: self.decoder)
            .map { wrapped in return wrapped.payload }
            .eraseToAnyPublisher()
        return retval
    }()
    // Attaching a sink to publisher should initiate the request.
    // Why am I not using a Subject. At all. Usually I go there by instinct.

    public init(request: URLRequest) {
        self.request = request
    }
}
