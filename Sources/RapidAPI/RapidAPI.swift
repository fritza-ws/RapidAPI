//
//  RapidAPI.swift
//  UCMaps
//
//  Created by Fritz Anderson on 5/21/20.
//  Copyright © 2020 The University of Chicago. All rights reserved.
//

import Foundation

enum RapidAPI: String {
    case host = "transloc-api-1-2.p.rapidapi.com"
    case apiKey = "624c197464msh7f14d937c6272dbp1767b3jsnba315478bdc8"
    
    /// The queries TransLoc's OpenAPI 1.2 supports
    enum Verbs: String {
        case agencies, routes, segments, vehicles, stops
        case arrivalEstimates = "arrival-estimates"
        
        var baseURL: String {
            "https://\(RapidAPI.host.rawValue)/\(self.rawValue).json"
        }
        
        // FIXME: arrivalEstimates need list of agencu
        //        list of agencies OR list of routes OR list of stops
        static let routeQualifiable: Set<Verbs> = [.segments, .vehicles]
        //, .stops, .arrivalEstimates]
        var isRouteQualifiable: Bool { Self.routeQualifiable.contains(self) }
        
        func request(agencies: Agencies,
                     routes: [String]? = nil)
            throws -> URLRequest {
                let url = try self.url(agencies: agencies, routes: routes)
                var retval = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                retval.allHTTPHeaderFields = headers
                return retval
        }
        
        func url(agencies: Agencies, routes: [String]? = nil) throws -> URL {
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
    
    /// The transit agencies the application supports.
    ///
    /// These are hard-coded to UChicago (`.uchicago`) and CTA (`.cta`). There are allso `.all` and `.none` sets.
    struct Agencies: OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }
        
        static let cta = Agencies(rawValue: 1)
        static let uchicago = Agencies(rawValue: 2)
        static let all: Agencies  = [.cta, .uchicago]
        static let none: Agencies = []
        
        var number: String {
            var items: [String] = []
            if self.contains(.cta) {
                items.append("104")
            }
            if self.contains(.uchicago) {
                items.append("100")
            }
            return items.joined(separator: ",")
        }
        
        var fragment: String {
            "agencies=\(number)"
        }
    }
    
    /// Errors arising from the `RapidAPI` functions.
    ///
    /// - `badURL`: The `url(verb:agencies:routes:)` func could not form a valid URL
    /// - `mustSpecifyAgency`: `agencies` is `.none`.
    /// - `mustNotSpecifyRoutes`: `routes` were provided when the query does not support them.
    enum Errors: Error {
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
    static func url(verb: Verbs,
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
    
    private static let headers = [
        "x-rapidapi-host": RapidAPI.host.rawValue,
        "x-rapidapi-key": RapidAPI.apiKey.rawValue
    ]
    
    static let jsonDecoder: JSONDecoder = {
        let retval = JSONDecoder()
        retval.dateDecodingStrategy = .iso8601
        return retval
    }()
    
    
//
//    /// A `URLRequest` to execute a TransLoc OpenAPI 1.2 query.
//    /// - Parameters:
//    ///   - verb: The query operation, as specified in `enum Verbs`
//    ///   - agencies: The agencies to filter down to. These must not be `.none `.
//    ///   - routes: The routes to filter down to. Defaults to  `nil`. Only `.segments` and `.vehicles` may specify routes.
//    /// - Throws: `.mustSpecifyAgency` if `agencies` is `.none`; `.mustNotSpecifyRoutes` if the `verb` does not support route filtering; and `.badURL` if no URL could be built from the query information (this should be a fatal error).
//    /// - Returns: A `URLRequest` representing the desired query.
//    /// - note: The Alamofire `Request` API should largely supersede this.
//    static func request(verb: Verbs,
//                        agencies: Agencies,
//                        routes: [String]? = nil)
//        throws -> URLRequest {
//            let url = try Self.url(verb: verb,
//                                   agencies: agencies,
//                                   routes: routes)
//            var retval = URLRequest(url: url,
//                                    cachePolicy: .useProtocolCachePolicy,
//                                    timeoutInterval: 10)
//            retval.allHTTPHeaderFields = headers
//            return retval
//    }
}

/// The container JSON for the per-API response.
///
/// `JSONDecoder` for an API result should specify the payload type in the generic parameter:
///
///     let allRoutes =
///         try jsonDecoder.decode(TransLocWrapper<[String:[TranslocRoute]]>.self,
///                                from: routeData)
/// The payload structure willl then be in `allRoutes.data`.
struct TransLocWrapper<T:Decodable>: Decodable, CustomStringConvertible {
    let rate_limit: Int
    let expires_in: Double
    let api_latest_version: String
    let api_version: String
    let generated_on: Date
    let data: T
    
    var description: String {
        var retval = "TransLocWrapper:\n"
        print("\tgenerated:", generated_on, "expires in", expires_in,
              "sec  Rate limit:", rate_limit, to: &retval)
        print("\tAPI version:", api_version,
              "latest:", api_latest_version, to: &retval)
        return retval
    }
    
    var payload: T { self.data }
}
