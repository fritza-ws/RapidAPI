//
//  DecodableWrapperTests.swift
//  
//
//  Created by Fritz Anderson on 7/6/21.
//

import Foundation

import XCTest
@testable import RapidAPI

struct ShouldBeCodable: DecodableWrapper {
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }
}

final class CodableOwner: Decodable, Encodable, CustomStringConvertible {
    internal init(identifier: String, sbCodable: ShouldBeCodable) {
        self.identifier = identifier
        self.sbCodable = sbCodable
    }

    let identifier: String
    let sbCodable: ShouldBeCodable
    var description: String {
        "CodableOwner(id: \(identifier), embedding: \(sbCodable.rawValue)"
    }
}


final class DecodableWrapperTests: XCTestCase {
    func makeAnOwner(identifier: String,
                     file: String = #file,
                     line: UInt = #line)
    -> CodableOwner {

        let identifierString = "file and line: \(file):\(line)"
        let sbdString = identifier
        let sbD = ShouldBeCodable(rawValue: sbdString)
        let newCOwner = CodableOwner(
            identifier: identifierString,
            sbCodable: sbD)
        return newCOwner
    }

    func testCreation() {
        let sbdString = "sbCodable in testCreation"
        let newCOwner = makeAnOwner(identifier: sbdString)

        let desc = newCOwner.description as NSString
        XCTAssert(desc.hasPrefix("CodableOwner(id: "))
        XCTAssert(desc.contains("file and line: "))
        XCTAssert(desc.hasSuffix(sbdString))
    }

    func encodedOwner(identifier: String,
                      file: String = #file,
                      line: UInt = #line)
    -> Data?
    {
        let owner = makeAnOwner(identifier: identifier,
                                file: file,
                                line: line)

        let encoder = JSONEncoder()
        var encoded: Data?

        do {
            encoded = try encoder.encode(owner)
        }
        catch {
            XCTFail("encoding failed: \(error) at \(file):\(line)")
        }
        XCTAssertNotNil(encoded,
                        "encoded data at \(file):\(line)")
        guard let data = encoded,
              let string = String(data: data, encoding: .utf8) else {
            print("nil or unstringifiable returned data")
            return nil
        }
        print(#function, "Returning", string)
        return encoded
    }
    //identifier: "from testEncoding"

    func testEncoding() {
        _ = encodedOwner(identifier: "to test encoding")
    }

    func testDecoding() {
        let purpose = "to test decoding"
        guard let encodedData = encodedOwner(identifier: purpose) else {
            print("Didn't even encode")
            return
        }

        let decoder = JSONDecoder()
        let owner: CodableOwner
        do {
            owner = try decoder.decode(CodableOwner.self, from: encodedData)
        }
        catch {
            XCTFail("encoding failed: \(error) at \(#file):\(#line)")
            return
        }

        let desc = owner.description
        XCTAssert(desc.hasPrefix("CodableOwner(id: "))
        XCTAssert(desc.contains(purpose))
    }
}
