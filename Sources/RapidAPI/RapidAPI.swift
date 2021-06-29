//
//  RapidAPI.swift
//  UCMaps
//
//  Created by Fritz Anderson on 5/21/20.
//  Copyright © 2020 The University of Chicago. All rights reserved.
//

import Foundation

// MARK: - RapidAPI
public enum RapidAPI:  String {
    // Keys for the configuration dictionary
    case host             // = "host"
    case apiKey           // = "apiKey"


    // MARK: Request URL
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

    static func headers() throws -> [String:String] {
        guard !configuration.isEmpty else {
            throw Errors.notConfigured
        }
        return[
            "x-rapidapi-host": try RapidAPI.host.configurationValue(),
            "x-rapidapi-key": try RapidAPI.apiKey.configurationValue()
        ]
    }

//    static let headers = [
//        "x-rapidapi-host": RapidAPI.host.configurationValue,
//        "x-rapidapi-key":  RapidAPI.apiKey.configurationValue
//    ]
}


// MARK: - Configuration
extension RapidAPI {
    //    case host = "transloc-api-1-2.p.rapidapi.com"
    //    case apiKey = "624c197464msh7f14d937c6272dbp1767b3jsnba315478bdc8"
    //    case perClientKeyFile = "RapidAPIKeys.plist"

    static var configuration: [String:String] = [:]
    /// Whether the configuration file has been read.
    public static var isConfigured: Bool { !configuration.isEmpty }

    // MARK: from Dictionary
    /// Retain the configuration dictionary
    ///
    /// This may throw `Errors.incompleteConfiguration` in a future version if the function checks for missing keys.
    /// - Parameter dictionary: A `[String:String]` to assign to static `configuration`
    public static func configure(dictionary: [String:String])
    {
        // TODO: Verify the required keys are present
        Self.configuration = dictionary
    }

    // MARK: from Data
    /// Assign `Self.configuration` decoded from plist file data
    /// - Parameter data: Intended to be the `Data` content of the configuration plist file.
    /// - Throws: Decoding errors from `PropertyListDecoder`
    public static func configure(data: Data) throws {
        guard !data.isEmpty else { throw Errors.emptyDataFile }
        let dict = try PropertyListDecoder()
            .decode([String:String].self, from: data)
        Self.configure(dictionary: dict)
    }

    // MARK: from URL
    /// Assign `Self.configuration` decoded from a plist file at a given `URL`.
    /// - Parameter url: File URL for the property list containing the configuration settings.
    /// - Throws: `Errors.notAFileURL` if `url` is not a `file:///` url. Decoding errors from the upstream `Self.configure(data:)`
    /// - bug: Does not check for the existence of a file at `url`, only that the URL itself is of the `file:` scheme.
    public static func configure(url: URL) throws {
        guard url.isFileURL else { throw Errors.notAFileURL(url.absoluteString) }
        let data = try Data(contentsOf: url)
        try configure(data: data)
    }

    // MARK: from path
    /// Assign `Self.configuration` decoded from a plist file at a given path.
    /// - Parameter path: Path to a file containing property list data for the configuration settings.
    /// - Throws: `Errors.notAFileURL` the path can't derive a `file:` URL from `path`. Decoding errors from the upstream `Self.configure(data:)`
    /// - bug: Does not check for the existence of a valid file at `path`
    public static func configure(path: String) throws {
        let url = URL(fileURLWithPath: path)
        try configure(url: url)
    }

    // MARK: Configuration access
    /// The `String` value for the configuration setting keyed by `self.rawValue`
    /// - Throws: `Errors.notConfigured` if the configuration file has not been loaded. `Errors.incompleteConfiguration` if no value is present for the requested key.
    /// - Returns: The `String` value of the requested configuration item.
    public func configurationValue() throws -> String  {
        guard !Self.configuration.isEmpty else {
            throw Errors.notConfigured
        }
        guard let retval = Self.configuration[rawValue] else { throw Errors.incompleteConfiguration(rawValue) }

        return retval
    }

}
