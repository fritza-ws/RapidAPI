    import XCTest
    @testable import RapidAPI

    typealias Agencies = RapidAPI.Agencies

    final class RapidAPITests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            //            XCTAssertEqual(RapidAPI().text, "Hello, World!")
        }
    }

    final class AgencyTests: XCTestCase {
        let uChicago: Agencies = .uchicago
        let cta     : Agencies = .cta
        let both    : Agencies = .all
        let neither : Agencies = .none

        let eachCase: [Agencies] = [.uchicago, .cta, .all, .none]

        func testAgencies() {
            for case1 in eachCase {
                for case2 in eachCase {
                    if case1.rawValue == case2.rawValue {
                        XCTAssertEqual(case1, case2,
                        "Should be same: \(case1.rawValue), \(case2.rawValue)")
                    }
                    else {
                        XCTAssertNotEqual(case1, case2,
                        "Should be different: \(case1.rawValue), \(case2.rawValue)")
                    }
                }
            }
        }

        func testRawValues() {
            for case1 in eachCase {
                XCTAssert((0...3).contains(case1.rawValue),
                          "\(case1.rawValue) should be 0 ≤ rawValue ≤ 3")
            }
            XCTAssertEqual(neither.rawValue, 0,
                           ".none should have rawValue == 0"
                           )
            XCTAssertEqual(cta.rawValue, 1,
                           ".cta should have rawValue == 1"
                           )
            XCTAssertEqual(uChicago.rawValue, 2,
                           ".uChicago should have rawValue == 2"
                           )
            XCTAssertEqual(both.rawValue, 3,
                           ".all should have rawValue == 3"
                           )
        }

        func testAlgebra() {
            XCTAssertEqual(
                Agencies.all,
                [Agencies.cta, Agencies.uchicago],
                ".all should equal the union of uchicago and cta")

            let empty = Agencies.none

            var testSum = empty
            testSum.insert(.cta)
            XCTAssertEqual(testSum.rawValue, Agencies.cta.rawValue,
                           "Inserting cta into empty")
            testSum.insert(.uchicago)
            XCTAssertEqual(testSum.rawValue, Agencies.all.rawValue,
                           "Inserting cta, then uchicago, into empty")

            testSum = empty
            testSum.formUnion([.uchicago, .cta])
            XCTAssertEqual(testSum.rawValue, Agencies.all.rawValue,
                           "Union of [cta, uchicago], with empty")

            testSum.formIntersection(.cta)
            XCTAssertEqual(testSum.rawValue, Agencies.cta.rawValue,
                           "Intersection of all and [cta]")

            testSum = .all
            testSum.formIntersection(.uchicago)
            XCTAssertEqual(testSum.rawValue, Agencies.uchicago.rawValue,
                           "Intersection of all and [uchicago]")

            testSum = .all
            testSum.formIntersection([.uchicago, .cta])
            XCTAssertEqual(testSum.rawValue, Agencies.all.rawValue,
                           "Intersection of all and all")

            testSum = .all
            testSum.formIntersection([])
            XCTAssertEqual(testSum.rawValue, Agencies.none.rawValue,
                           "Intersection of all and none")
        }

        func testInitialization() {
            let agencyAndValue = zip(eachCase, [2,1,3,0])
            for (agy, val) in agencyAndValue {
                let agyFromRaw = Agencies(rawValue: val)
                XCTAssertEqual(agyFromRaw, agy,
                               "Raw \(val) should yield \(agy.rawValue)")
            }
        }

        func testIsValid() {
            for i in (-1...5) {
                let fromRaw = Agencies(rawValue: i)
                if (0...(Agencies.all.rawValue)).contains(i) {
                    XCTAssert(fromRaw.isValid,
                              "Raw value of \(i) should produce a valid Agency")
                }
                else {
                    XCTAssertFalse(fromRaw.isValid,
                              "Raw value of \(i) should NOT produce a valid Agency")
                }
            }
        }
    }

