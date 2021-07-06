//
//  DecodableWrapper.swift
//  Placeholder-main
//
//  Created by Fritz Anderson on 7/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

/**
 Adopters restrict generic identifiers (e.g. `String`) to intended uses.

 # Example
 Suppose an API returns reports IDs for `Shoes` and `Socks` alike as `String`s. It is easy to lose track: The compiler would allow any `String` to refer to either, correctly or not:

        struct Shoes: Decodable {
            let catalogID: String
            static var lookup: [String:Shoes] = [:]
        }
        struct Socks: Decodable { ... }

        let identifier: String ...
        // Compiles, works as indended:
        let currentShoes = Shoes.lookup[identifier]
        // Compiles, SERIOUS logical error:
        let badSocks     = Socks.lookup[identifier]

 If, however, the identifiers are wrapped in distinct types…

        public struct ShoesID: DecodableWrapper {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
        }
        public struct SocksID: DecodableWrapper { ... }

… then the compiler enforces correct usage:

        struct Shoes: Decodable {
            let catalogID: ShoesID
            static var lookup: [ShoesID:Shoes]   = [:]
        }
        struct Socks: Decodable { ... }

        let currentShoes = Shoes .lookup[identifier]   // Error: Not indexed by String

        let shoesID      = ShoesID(rawValue: surrentShoes)
        let badSocks     = Socks.lookup[shoesID]       // Error: Not indexed by ShoesID
        let currentShoes = Shoes.lookup[shoesID]       // Correct

 # Default implementations
 By way of `RawRepresentable`, `DecodableWrapper` provides default implementations for

 * `init(from:)`
 * `description`
 * `operator ==`
 * `operator !=`
 * `hash(into:)`
 * `hashValue`
 */
public protocol DecodableWrapper: RawRepresentable // & Decodable & Hashable
where RawValue: Decodable & Hashable { }

extension DecodableWrapper {
//    init(rawValue: RawValue) { self.init(rawValue) }
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let value = try container.decode(RawValue.self)
//        self.init(rawValue: value)!
//        // FIXME: Will we ever want a failable init(rawValue:)?
//    }
}

public struct RouteID: RawRepresentable & Decodable & Hashable
{
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    /// Decode from incoming data.
//    public init(from decoder: Decoder) throws {
//        let oneString = try decoder.singleValueContainer()
//        rawValue = try oneString.decode(String.self)
//    }
//    public static func == (lhs: RouteID, rhs: RouteID) -> Bool { lhs.rawValue == rhs.rawValue }
//    public func hash(into hasher: inout Hasher) { hasher.combine(rawValue) }
}

extension RouteID: CustomStringConvertible {
    public var description: String { "RouteID(\(rawValue))" }
}


public struct SegmentID: DecodableWrapper {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}

public struct RouteType: DecodableWrapper {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}

public struct StopID: DecodableWrapper {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}

