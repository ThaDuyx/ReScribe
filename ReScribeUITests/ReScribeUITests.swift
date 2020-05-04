//
//  ReScribeUITests.swift
//  ReScribeUITests
//
//  Created by Christoffer Detlef on 04/05/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import XCTest

class ReScribeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testValidLoginSuccess(){
        let validEmail = "testuser@test.com"
        let validPass = "testtest"
        var loginTest = 0
        
        let app = XCUIApplication()
        app.launch()
        
        while loginTest <= 1 {
            if loginTest == 0 {
                let app = XCUIApplication()
                app/*@START_MENU_TOKEN@*/.buttons["Log in"].staticTexts["Log in"]/*[[".buttons[\"Log in\"].staticTexts[\"Log in\"]",".staticTexts[\"Log in\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
                app.alerts["Error"].scrollViews.otherElements.buttons["Try again"].tap()
                loginTest += 1
            } else {
                let userName = app.textFields["Email"]
                userName.tap()
                userName.typeText(validEmail)
                
                let passwordSecureTextField = app.secureTextFields["Password"]
                passwordSecureTextField.tap()
                passwordSecureTextField.typeText(validPass)
                
                app.buttons["Log in"].tap()
                loginTest += 1
            }
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
