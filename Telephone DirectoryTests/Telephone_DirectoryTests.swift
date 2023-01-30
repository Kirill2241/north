//
//  Telephone_DirectoryTests.swift
//  Telephone DirectoryTests
//
//  Created by Diana Princess on 30.11.2022.
//

import XCTest
@testable import Telephone_Directory

final class Telephone_DirectoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            let network = NetworkService()
            for i in 0...20{
                network.requestImage(urlString: "https://upload.wikimedia.org/wikipedia/commons/e/e3/Obuchovhospital.jpg", index: i){ result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }

}
