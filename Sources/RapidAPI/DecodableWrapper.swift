//
//  DecodableWrapper.swift
//  Placeholder-main
//
//  Created by Fritz Anderson on 7/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation


public protocol DecodableWrapper: RawRepresentable & Decodable & Hashable
where RawValue: Decodable & Hashable { }
extension DecodableWrapper {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(RawValue.self)
        self.init(rawValue: value)!
        // FIXME: Will we ever want a failable init(rawValue:)?
    }
}

public struct RouteID: RawRepresentable & Decodable & Hashable
{
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    /// Decode from incoming data.
    public init(from decoder: Decoder) throws {
        let oneString = try decoder.singleValueContainer()
        rawValue = try oneString.decode(String.self)
    }
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

