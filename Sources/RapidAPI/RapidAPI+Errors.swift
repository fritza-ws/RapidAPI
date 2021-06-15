//
//  RapidAPI+Errors.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

extension RapidAPI {
    // MARK: - Errors
    /// Errors arising from the `RapidAPI` functions.
    ///
    /// - `badURL`: The `url(verb:agencies:routes:)` public func could not form a valid URL
    /// - `mustSpecifyAgency`: `agencies` is `.none`.
    /// - `mustNotSpecifyRoutes`: `routes` were provided when the query does not support them.
    public enum Errors: Error {
        // MARK: Configuration
        case notConfigured
        case noConfigurationFile(String)
        case incompleteConfiguration(String)
        case notAFileURL(String)

        // MARK: Transaction
        case badURL(String)
        case mustSpecifyAgency(Verbs)
        case mustNotSpecifyRoutes(Verbs)
        case queryFailed(URL)

        // MARK: Should be fatal
        case reentrantUnitChain
        case startingEmptyChain
        case noManagedObjectContext(String)
        case taskInsertionWhileExecuting(String)

        // MARK: Description
        public var localizedDescription: String {
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
                return "Attempt to re-enter the public initial unit chain"
            case .startingEmptyChain:
                return "Attempt to start an empty unit chain"
            case .noManagedObjectContext(let name):
                return "Attempt to execute \(name) without the optional NSManagedObjectContext"
            case .taskInsertionWhileExecuting(let name):
                return "Attempt to add \(name) while units are executing"


            case .incompleteConfiguration(let missingTag):
                return "Configuration is missing tag \(missingTag)"
            case .noConfigurationFile(let path):
                return "No configuration plist at \(path)"
            case .notConfigured:
                return "RapidAPI.configuration not yet loaded."
            case .notAFileURL(let url):
                return "Not a file URL (\(url))"
            }

        }
    }
}
