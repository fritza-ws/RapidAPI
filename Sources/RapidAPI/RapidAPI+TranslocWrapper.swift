//
//  RapidAPI+TranslocWrapper.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

private let dateFormatter = ISO8601DateFormatter()

/// The container JSON for the per-API response.
///
/// `JSONDecoder` for an API result should specify the payload type in the generic parameter:
///
///     let allRoutes =
///         try jsonDecoder.decode(TranslocWrapper<[String:[TranslocRoute]]>.self,
///                                from: routeData)
/// The payload public structure willl then be in `allRoutes.data`.
public struct TranslocWrapper<T:Decodable>: Decodable, CustomStringConvertible {
    let rate_limit: Int
    let expires_in: Double
    let api_latest_version: String
    let api_version: String
    let generated_on: String
    public var generatedOn: Date {
        dateFormatter.date(from: generated_on)
            ?? Date.distantPast
    }

    public let data: T

    public var description: String {
        var retval = "TranslocWrapper:\n"
        print("\tgenerated:", generated_on, "expires in", expires_in,
              "sec  Rate limit:", rate_limit, to: &retval)
        print("\tAPI version:", api_version,
              "latest:", api_latest_version, to: &retval)
        return retval
    }

    public var payload: T { self.data }
}
