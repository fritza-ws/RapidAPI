//
//  RapidAPI+Verbs.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

extension RapidAPI {
    // TODO: Make core RapidAPI less dependent on Verbs
    //       By which I mean, this extension and RAPI
    //       could be added to a project without bringing
    //       in all the other parts of RAPI.

    /// The queries Transloc's OpenAPI 1.2 supports
    public enum Verbs: String, CaseIterable {
        case agencies, routes, segments, vehicles, stops
        case arrivalEstimates = "arrival-estimates"

        public var baseURL: String {
            "https://\(RapidAPI.host.rawValue)/\(self.rawValue).json"
        }

        static let routeQualifiable: Set<Verbs> = [.segments, .vehicles]
        public var isRouteQualifiable: Bool { Self.routeQualifiable.contains(self) }

        public func request(agencies: Agencies,
                     routes: [String]? = nil)
            throws -> URLRequest {
                let url = try self.url(agencies: agencies, routes: routes)
                var retval = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                retval.allHTTPHeaderFields = headers
                return retval
        }

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
