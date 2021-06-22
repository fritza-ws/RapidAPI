//
//  RapidAPI+Verbs.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

extension RapidAPI {
    // MARK: - Verbs
    // TODO: Make core RapidAPI less dependent on Verbs
    //       By which I mean, this extension and RAPI
    //       could be added to a project without bringing
    //       in all the other parts of RAPI.

    /// The queries Transloc's OpenAPI 1.2 supports
    public enum Verbs: String, CaseIterable {
        case agencies, routes, segments, vehicles, stops
        case arrivalEstimates = "arrival-estimates"

        public var baseURL: String {
            let configValue = try! RapidAPI.host.configurationValue()
            return "https://\(configValue)/\(self.rawValue).json"
        }

        static let routeQualifiable: Set<Verbs> = [.segments, .vehicles]
        /// Whether this `Verb` request type can include route IDs
        public var isRouteQualifiable: Bool { Self.routeQualifiable.contains(self) }

        // MARK: URL/URLRequest
        /// A `URLRequest` for this `Verb`'s request type
        ///
        /// In addition to the URL, the request will set the caching policy to .`useProtocolCachePolicy`, and the timeout to 10 seconds.
        ///
        /// - precondition: `agencies` must not to be `.none`.
        /// - precondition: `routes` must be `nil` if `!self.isRouteQualifiable`.
        /// - Parameters:
        ///   - agencies: `OptionSet` for the `Agencies` to include in the query.
        ///   - routes: Optional list of route IDs to apply the query to. Default is `nil`.
        /// - Throws: `Errors.notConfigured` if the configuration plist has not been read, `Errors.mustSpecifyAgencies` (obvious) , and `Errors.mustNotSpecifyRoutes` if `routes` is passed for an ineligible `Verb`.
        /// - Returns: The `URLRequest` accordingly.
        public func request(agencies: Agencies,
                     routes: [String]? = nil)
            throws -> URLRequest {
                let url = try self.url(agencies: agencies, routes: routes)
                var retval = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy,  timeoutInterval: 10)
            retval.allHTTPHeaderFields = try RapidAPI.headers()
                return retval
        }

        /// A `URL` for this `Verb`'s request type
        ///
        /// - precondition: `agencies` must not to be `.none`.
        /// - precondition: `routes` must be `nil` if `!self.isRouteQualifiable`.
        /// - Parameters:
        ///   - agencies: `OptionSet` for the `Agencies` to include in the query.
        ///   - routes: Optional list of route IDs to apply the query to. Default is `nil`.
        /// - Throws: `Errors.notConfigured` if the configuration plist has not been read, `Errors.mustSpecifyAgencies` (obvious) , and `Errors.mustNotSpecifyRoutes` if `routes` is passed for an ineligible `Verb`.
        /// - Returns: The `URL` accordingly.
        public func url(agencies: Agencies, routes: [String]? = nil) throws -> URL {
            guard !agencies.isEmpty else { throw Errors.mustSpecifyAgency(self) }
            var fragments: [String] = [agencies.fragment]

            if let routeList = routes,
                !routeList.isEmpty{
                guard isRouteQualifiable else { throw Errors.mustNotSpecifyRoutes(self) }
                let routeFragment = "routes=" + routeList.joined(separator: ",")
                fragments.append(routeFragment)
            }

            let parameterFragment = fragments.joined(separator: "&")

            let urlString = baseURL + "?"
                + parameterFragment
            guard let retval =
                URL(string: urlString) else {
                    throw Errors.badURL(urlString)
            }
            return retval
        }
    }
}
