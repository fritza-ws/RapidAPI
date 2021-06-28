//
//  DecodableWrapper.swift
//  Placeholder-main
//
//  Created by Fritz Anderson on 6/24/21.
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
}


public struct SegmentID: DecodableWrapper {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}

public struct RouteType: DecodableWrapper {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
}

