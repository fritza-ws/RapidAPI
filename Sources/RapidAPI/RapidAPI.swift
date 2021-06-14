//
//  RapidAPI.swift
//  UCMaps
//
//  Created by Fritz Anderson on 5/21/20.
//  Copyright © 2020 The University of Chicago. All rights reserved.
//

import Foundation

public enum RapidAPI: String {
    case host = "transloc-api-1-2.p.rapidapi.com"
    case apiKey = "624c197464msh7f14d937c6272dbp1767b3jsnba315478bdc8"

    /// A URL to execute a query under the Transloc API.
    /// - Parameters:
    ///   - verb: The query operation, as specified in `public enum Verbs`
    ///   - agencies: The agencies to filter down to. These must not be `.none `.
    ///   - routes: The routes to filter down to. Defaults to  `nil`. Only `.segments` and `.vehicles` may specify routes.
    /// - Throws: `.mustSpecifyAgency` if `agencies` is `.none`; `.mustNotSpecifyRoutes` if the `verb` does not support route filtering; and `.badURL` if no URL could be built from the query information (this should be a fatal error).
    /// - Returns: A `URL` representing the desired query.
    static public func url(verb: Verbs,
                           agencies: Self.Agencies,
                    routes: [String]? = nil)
        throws -> URL
    {
        guard !agencies.isEmpty else { throw Self.Errors.mustSpecifyAgency(verb) }
        var fragments: [String] = [agencies.fragment]

        if let routeList = routes,
            !routeList.isEmpty{
            guard verb.isRouteQualifiable else { throw Self.Errors.mustNotSpecifyRoutes(verb) }
            let routeFragment = "routes=" + routeList.joined(separator: ",")
            fragments.append(routeFragment)
        }

        let parameterFragment = fragments.joined(separator: "&")

        let urlString = verb.baseURL + "?"
            + parameterFragment
        guard let retval =
            URL(string: urlString) else {
                throw Self.Errors.badURL(urlString)
        }
        return retval
    }

    static let headers = [
        "x-rapidapi-host": RapidAPI.host.rawValue,
        "x-rapidapi-key": RapidAPI.apiKey.rawValue
    ]
}
