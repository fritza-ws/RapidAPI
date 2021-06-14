//
//  RapidAPI.swift
//  UCMaps
//
//  Created by Fritz Anderson on 5/21/20.
//  Copyright © 2020 The University of Chicago. All rights reserved.
//

import Foundation

public 
enum RapidAPI: String {
    case host = "transloc-api-1-2.p.rapidapi.com"
    case apiKey = "624c197464msh7f14d937c6272dbp1767b3jsnba315478bdc8"
    
    /// The transit agencies the application supports.
    ///
    /// These are hard-coded to UChicago (`.uchicago`) and CTA (`.cta`). There are allso `.all` and `.none` sets.
    public struct Agencies: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        static let cta = Agencies(rawValue: 1)
        static let uchicago = Agencies(rawValue: 2)
        static let all: Agencies  = [.cta, .uchicago]
        static let none: Agencies = []
        
        public var number: String {
            var items: [String] = []
            if self.contains(.cta) {
                items.append("104")
            }
            if self.contains(.uchicago) {
                items.append("100")
            }
            return items.joined(separator: ",")
        }
        
        public var fragment: String {
            "agencies=\(number)"
        }
    }
    
    /// Errors arising from the `RapidAPI` functions.
    ///
    /// - `badURL`: The `url(verb:agencies:routes:)` func could not form a valid URL
    /// - `mustSpecifyAgency`: `agencies` is `.none`.
    /// - `mustNotSpecifyRoutes`: `routes` were provided when the query does not support them.
    public enum Errors: Error {
        case badURL(String)
        case mustSpecifyAgency(Verbs)
        case mustNotSpecifyRoutes(Verbs)
        case queryFailed(URL)
        
        case reentrantUnitChain
        case startingEmptyChain
        case noManagedObjectContext(String)
        case taskInsertionWhileExecuting(String)
        
        var localizedDescription: String {
            switch self {
            case .badURL(let url):
                return "Generated URL is bad: \(url)"
            case .mustSpecifyAgency(let verb):
                return "Agency must be specified for \(verb.rawValue)"
            case .mustNotSpecifyRoutes(let verb):
                return "\(verb.rawValue) must not specify routes."
            case .queryFailed(let url):
                return "Could not get a response to “\(url.absoluteString)”"
                
            case .reentrantUnitChain:
                return "Attempt to re-enter the initial unit chain"
            case .startingEmptyChain:
                return "Attempt to start an empty unit chain"
            case .noManagedObjectContext(let name):
                return "Attempt to execute \(name) without the optional NSManagedObjectContext"
            case .taskInsertionWhileExecuting(let name):
                return "Attempt to add \(name) while units are executing"


            }

        }
    }
    
    /// A URL to execute a query under the TransLoc API.
    /// - Parameters:
    ///   - verb: The query operation, as specified in `enum Verbs`
    ///   - agencies: The agencies to filter down to. These must not be `.none `.
    ///   - routes: The routes to filter down to. Defaults to  `nil`. Only `.segments` and `.vehicles` may specify routes.
    /// - Throws: `.mustSpecifyAgency` if `agencies` is `.none`; `.mustNotSpecifyRoutes` if the `verb` does not support route filtering; and `.badURL` if no URL could be built from the query information (this should be a fatal error).
    /// - Returns: A `URL` representing the desired query.
    public static func url(verb: Verbs,
                    agencies: Agencies,
                    routes: [String]? = nil)
        throws -> URL
    {
        guard !agencies.isEmpty else { throw Errors.mustSpecifyAgency(verb) }
        var fragments: [String] = [agencies.fragment]
        
        if let routeList = routes,
            !routeList.isEmpty{
            guard verb.isRouteQualifiable else { throw Errors.mustNotSpecifyRoutes(verb) }
            let routeFragment = "routes=" + routeList.joined(separator: ",")
            fragments.append(routeFragment)
        }
        
        let parameterFragment = fragments.joined(separator: "&")
        
        let urlString = verb.baseURL + "?"
            + parameterFragment
        guard let retval =
            URL(string: urlString) else {
                throw Errors.badURL(urlString)
        }
        return retval
    }
    
    internal static let headers = [
        "x-rapidapi-host": RapidAPI.host.rawValue,
        "x-rapidapi-key": RapidAPI.apiKey.rawValue
    ]
    
    static let jsonDecoder: JSONDecoder = {
        let retval = JSONDecoder()
        retval.dateDecodingStrategy = .iso8601
        return retval
    }()
}
