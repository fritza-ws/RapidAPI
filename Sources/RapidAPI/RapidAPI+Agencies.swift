//
//  RapidAPI+Agencies.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation



// TODO: Take it out of the struct; the module name is enough to isolate it.
/// An `OptionSet` selecting the transit agencies the application supports.
///
/// These are hard-coded to UChicago (`.uchicago`) and CTA (`.cta`). There are allso `.all` and `.none` sets.
/// - warning: `Agencies` is not an `enum`. Initializing
///            from an out-of-bounds raw value will
///            produce a non-nil result. Check `isValid`
///            instead.
public struct Agencies: OptionSet, Hashable {
    static let countOfAgencies = 2

    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init?(agencyRawValue: Int) {
        guard (1...Self.countOfAgencies)
                .contains(agencyRawValue) else { return nil }
        self.init(rawValue: agencyRawValue)
    }

    // MARK: - Cases
    /// Raw: UChicago bus lines
    public static let uchicago = Agencies(rawValue: 1)
    /// Raw: CTA bus lines
    public static let cta = Agencies(rawValue: 2)

    /// Compound: CTA and UChicago bus lines both
    public static let all: Agencies  = [.uchicago, .cta]
    /// Compound: No agency
    public static let none: Agencies = []

    /// Array of the individual agencies. Do not confuse with `.all`.
    public static let eachSingle: [Agencies] = [.uchicago, .cta]

    // MARK: - Validation
    /// Whether this instance contains only single- all- or no- `rawValue`s
    public var isValid: Bool {
        var lhs = self
        lhs.subtract(Self.all)
        return lhs.isEmpty
    }

    /// Whether this instance refers to one and only one `Agency`
    public var onlyOneAgency: Bool {
        self.rawValue == Self.uchicago.rawValue
            || self.rawValue == Self.cta.rawValue
    }

    /// If this instance does not refer to exactly one agency, format and trigger a precondition failure.
    public func preconditionOnlyOne(
        file: String = #file,
        line: Int = #line,
        function: String = #function) {
        precondition(onlyOneAgency,
                     """
\(file):\(line) - \(function)\n\tID (\(rawValue)) isn't a single agency
"""
        )
    }

    // MARK: - API agency identifiers
    /// The API agency identifier (`100`, `104`) as an `Int`
    public var idAsInt: Int {
        preconditionOnlyOne()
        switch self {
        case .uchicago: return 100
        case .cta:      return 104
        default:        preconditionFailure()
        }
    }

    /// Initialize an `Agency` from the API ID (`104`, `100`) as an `Int`
    public init?(translocAgencyID: Int) {
        switch translocAgencyID {
        case 104:   self = .cta
        case 100:   self = .uchicago
        default:    preconditionFailure("\(#function) - Attempt to initialize Agency with unknown transloc ID \(translocAgencyID)")
        }
    }

    /// The API Agency ID (`104`, `100`) as a `String`
    public var ID: String? {
        preconditionOnlyOne()
        switch self {
        case .cta:      return "104"
        case .uchicago: return "100"
        default:        return nil
        }
    }

    /// A `[String]` of all API Agency IDs (`104`, `100`) this instance represents
    public var IDs: [String] {
        var items: [String] = []
        for s: Agencies in [.cta, .uchicago] where self.contains(s) {
            items.append(s.ID!)
        }
        return items
    }

    /// A comma-separated `String` of all API `Agency` IDs represented by this instance.
    public var number: String {
        return IDs.joined(separator: ",")
    }

    /// An argument fragment for "`agencies=str`," where `str` is a comma-separated `String` of all API `Agency` IDs represented by this instance.
    ///
    /// Intended as an argument to restrict API queries to either or both `Agencies`.
    public var fragment: String {
        "agencies=\(number)"
    }

    // MARK: - Ordinal index
    /// The place of the represented instance in the collection `[.uchicago, .cta]`, or `nil` if more than one agency.
    public var index: Int? {
        switch self {
        case .uchicago: return 0
        case .cta     : return 1
        default       : return nil
        }
    }

    /// Represent an `Agency` based on its index in `[.uchicago, .cta]`
    ///
    /// Intended to correspond to a `section` index in data source methods.
    /// - parameter index: The index of the desired agency
    /// - prerequisite: The index is in-bounds for the single agencies.
    /// - todo: Index out-of-bounds is a logical error. Change this to a
    public init(fromIndex index: Int) {
        switch index {
        case 0:     self.init(rawValue: Self.uchicago.rawValue)
        case 1:     self.init(rawValue: Self.cta.rawValue     )
        default:    preconditionFailure("\(#function): Attempt to create an indexed agency with out of bounds \(index)")
        }
    }

    // MARK: - Human-readable names
    /// The human-readable name (UChicago, CTA) this instance represents
    ///
    /// - returns: The name of the `Agency`; `nil` if this instance represents other than one `Agency`.
    public var name: String? {
        preconditionOnlyOne()
        switch self {
        case .cta:      return "CTA"
        case .uchicago: return "UChicago"
        default:        return nil
        }
    }

    /// A `[String]` of the human-readable names of all agencies represented by this instance.
    public var names: [String] {
        var items: [String] = []
        for s: Agencies in [.cta, .uchicago] where self.contains(s) {
            items.append(s.name!)
        }
        return items
    }


    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

