//
//  ReScribeTests.swift
//  ReScribeTests
//
//  Created by Simon Andersen on 04/05/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import XCTest
@testable import ReScribe
import Firebase

class ReScribeTests: XCTestCase {
    
    func testCorrectUser(){
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let userID = "RfhAoFv8DEeqKYelgDdFZJyeBtr2"
        let selectedUser = db.collection("users").document(userID)
        selectedUser.getDocument { (checkForUser, error) in
            let userData = checkForUser?.data()
            let checkUserID = userData!["uid"] as! String
            
            XCTAssertEqual(userID, checkUserID)
        }
    }
    
    func testDownloadImageInBackground(){
        //Can only run if testCorrectUser has also been tested, because it needs the FirebaseApp.confire() call
        //to work properly
        let expectation = XCTestExpectation(description: "Download image in background")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let starsRef = storageRef.child("Images/" + "HBO"  + ".jpg")
        starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
              print("Error \(error)")
            } else {
                XCTAssertNotNil(data, "Didn't receive image")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDateCalculation(){
        let dateString = "5/12/20"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "MM/dd/yy"
        let date = dateFormatter.date(from: dateString)
        let calender = Calendar.current
        let nextPaymentDate = calender.date(byAdding: .day, value: 31, to: date!)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let checkDate = dateFormatter.string(from: nextPaymentDate!)
         
        XCTAssertEqual(checkDate, "6/12/20")
    }
}
