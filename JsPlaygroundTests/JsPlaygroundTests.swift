//
//  JsPlaygroundTests.swift
//  JsPlaygroundTests
//
//  Created by Marc Attinasi on 11/2/17.
//  Copyright © 2017 ServiceNow. All rights reserved.
//

import XCTest
@testable import JsPlayground

class JsPlaygroundTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSManager() {
        let jsm = JSManager.instance()
        XCTAssert((jsm.context != nil))
        
        XCTAssert(jsm.getTitle().contains("model script"))
        
        let titleFcn = jsm.context!.objectForKeyedSubscript("getTitle")
        let title = titleFcn?.call(withArguments: nil).toString()
        XCTAssert((title?.contains("model script"))!)
        
        // addObject / getObject
        let addFcn = jsm.context!.objectForKeyedSubscript("addObject")!
        let getFcn = jsm.context!.objectForKeyedSubscript("getObject")!
        
        addFcn.call(withArguments: ["foo", "bar"])
        addFcn.call(withArguments: ["bash", "baz"])
        
        XCTAssert(getFcn.call(withArguments: ["foo"]).toString() == "bar")
        XCTAssert(getFcn.call(withArguments: ["bash"]).toString() == "baz")
        
        XCTAssert(jsm.getModel().replacingOccurrences(of: " ", with: "").contains("\"foo\":\"bar\""))
        XCTAssert(jsm.getModel().replacingOccurrences(of: " ", with: "").contains("\"bash\":\"baz\""))
    }
    
    func testSession() {
        let jsm = JSManager.instance()

        let sessionId = jsm.addSession(owner: "Marc")
        XCTAssertEqual(UUID.init().description.lengthOfBytes(using: String.Encoding.utf8), sessionId?.lengthOfBytes(using: String.Encoding.utf8))
        
        let session = jsm.getSession(sessionId: sessionId!)
        XCTAssertNotNil(session)
        XCTAssertEqual(session?.id, sessionId)
        XCTAssertEqual(session?.owner, "Marc")
        XCTAssertEqual(0, session?.messages.count)
        
        let msg = "Q. Are we not men?"
        let result = jsm.addMessage(sessionId: sessionId!, message: msg)
        XCTAssertTrue(result)
        
        let session2 = jsm.getSession(sessionId: sessionId!)
        XCTAssertNotNil(session2)
        XCTAssertEqual(session2?.id, sessionId)
        XCTAssertEqual(session2?.owner, "Marc")
        XCTAssertEqual(1, session2?.messages.count)
        XCTAssertEqual(msg, session2?.messages[0].text)
        
        jsm.printModel()
    }
    
    func testSearch() {
        let jsm = JSManager.instance()

        let session1 = jsm.addSession(owner: "One")
        let session2 = jsm.addSession(owner: "Two")
        let session3 = jsm.addSession(owner: "Three")
        
        _ = jsm.addMessage(sessionId: session3!, message: "Message 3.1")

        _ = jsm.addMessage(sessionId: session1!, message: "Message 1.1")
        
        _ = jsm.addMessage(sessionId: session2!, message: "Message 2.1")
        _ = jsm.addMessage(sessionId: session2!, message: "Message 2.2")
        _ = jsm.addMessage(sessionId: session2!, message: "Message 2.3")

        let found2 = jsm.findSessionWithMessage(text: "2.2")
        XCTAssertEqual("Two", found2?.owner)
        
        let messageIndex = found2?.searchMessage(searchText: "2.2")
        XCTAssertEqual("Message 2.2", found2?.messages[messageIndex!].text)
        
        let unfound = jsm.findSessionWithMessage(text: "I smell a rat!")
        XCTAssertNil(unfound)
        
        // matches all three sessions - should return first match
        let found1 = jsm.findSessionWithMessage(text: ".1")
        XCTAssertEqual("One", found1?.owner)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
