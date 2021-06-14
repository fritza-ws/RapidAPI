//
//  RapidAPI+Agencies.swift
//  UCMaps
//
//  Created by Fritz Anderson on 6/2/21.
//  Copyright © 2021 The University of Chicago. All rights reserved.
//

import Foundation

extension RapidAPI {
    /// An `OptionSet` selecting the transit agencies the application supports.
    ///
    /// These are hard-coded to UChicago (`.uchicago`) and CTA (`.cta`). There are allso `.all` and `.none` sets.
    public struct Agencies: OptionSet {
        // FIXME: Reconcile with the hand-initialization in APIAgencies.swift
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let cta = Agencies(rawValue: 1)
        public static let uchicago = Agencies(rawValue: 2)
        public static let all: Agencies  = [.cta, .uchicago]
        public static let none: Agencies = []

        public var onlyOneAgency: Bool {
            self.rawValue != Agencies.none.rawValue &&
                self.rawValue != Agencies.all.rawValue
        }
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

        public var ID: String? {
            preconditionOnlyOne()
            switch self {
            case .cta:      return "104"
            case .uchicago: return "100"
            default:        return nil
            }
        }

        public var IDs: [String] {
            var items: [String] = []
            for s: Agencies in [.cta, .uchicago] where self.contains(s) {
                items.append(s.ID!)
            }
            return items
        }

        public var name: String? {
            preconditionOnlyOne()
            switch self {
            case .cta:      return "CTA"
            case .uchicago: return "UChicago"
            default:        return nil
            }
        }

        public var names: [String] {
            var items: [String] = []
            for s: Agencies in [.cta, .uchicago] where self.contains(s) {
                items.append(s.name!)
            }
            return items
        }

        public var number: String {
            return IDs.joined(separator: ",")
        }

        public var fragment: String {
            "agencies=\(number)"
        }
    }
}
