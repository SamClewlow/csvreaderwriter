//
//  SCCSVWriterTests.swift
//  CSVReaderWriterTests
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import XCTest
@testable import CSVReaderWriter


class SCCSVWriterTests: XCTestCase {
    
    func testClose() {
        let mockFileHandle = MockFileHandle()
        let mockData = WriteMockData.commaSeparated
        
        // Try using the same wrtier to write vaiable widths
        do {
            
            let writer = try SCCSVWriter(separator: mockData.separator(),
                                                newLine: mockData.newLine(),
                                                fileHandle: mockFileHandle)
            
            // Write the first line - this should succeed
            do {
                try writer.writeLine(fields: mockData.inputArray())
            } catch let writeError {
                XCTFail("Failed to write line \(mockData.inputArray()), recieved error \(writeError)")
            }
            
            XCTAssertTrue(mockFileHandle.writeWasCalled, "Expected a call to FileHandle write(_ data:Data) method")
            
            // Close the file writer session
            writer.close()
            
            // Write another line after closing - this should fail
            XCTAssertThrowsError(try writer.writeLine(fields: mockData.inputArray())) { (error) -> Void in
                XCTAssertEqual(error as? CSVWriteError, CSVWriteError.fileClosed)
            }
            
        } catch let error {
            XCTFail("Failed to create instance of SCCSVWriter, recieved error \(error)")
        }
    }
    
    func testWritingTabSeparated() {
        runTestValidInputFor(mockData: .tabSeparated)
        
    }
    
    func testWritingCommaSeparated() {
        runTestValidInputFor(mockData: .commaSeparated)
    }
    
    func testWritingBlanks() {
        runTestValidInputFor(mockData: .blanks)
    }
    
    func testMultipleWrites() {
        let mockFileHandle = MockFileHandle()
        let mockData = WriteMockData.commaSeparated
        
        // Validate on write
        mockFileHandle.writeValidation = { data in
            
            guard let string = String(data: data, encoding: .utf8) else {
                XCTFail("Failed to convert data to utf8 string")
                return
            }
            
            XCTAssertEqual(string,
                           mockData.expectedString(),
                           "Expcted to be able to read data as \(mockData.expectedString()), but got string")
        }
        
        
        
        do {
            
            let writer = try SCCSVWriter(separator: mockData.separator(),
                                                newLine: mockData.newLine(),
                                                fileHandle: mockFileHandle)
            
            // Try to write the same line multiple times
            for i in 0...1000 {
                
                // Reset the flag
                mockFileHandle.writeWasCalled = false
                
                do {
                    try writer.writeLine(fields: mockData.inputArray())
                } catch let writeError {
                    XCTFail("Failed to write line \(mockData.inputArray()) on iteration \(i), recieved error \(writeError)")
                }
                
                XCTAssertTrue(mockFileHandle.writeWasCalled, "Expected a call to FileHandle write(_ data:Data) method")
            }
        } catch let error {
            XCTFail("Failed to create instance of SCCSVWriter, recieved error \(error)")
        }
    }
    
    func testWritingVariableColumnWidths() {
        // Test both inputs are individually valid
        runTestValidInputFor(mockData: .width3)
        runTestValidInputFor(mockData: .width5)
        
        let mockFileHandle = MockFileHandle()
        let width3 = WriteMockData.width3
        let width5 = WriteMockData.width5
        
        
        // Try using the same wrtier to write vaiable widths
        do {
            
            let writer = try SCCSVWriter(separator: width3.separator(),
                                                newLine: width3.newLine(),
                                                fileHandle: mockFileHandle)
            
            // Write the first line - this should succeed
            do {
                try writer.writeLine(fields: width3.inputArray())
            } catch let writeError {
                XCTFail("Failed to write line \(width3.inputArray()), recieved error \(writeError)")
            }
            
            XCTAssertTrue(mockFileHandle.writeWasCalled, "Expected a call to FileHandle write(_ data:Data) method")
            
            // Write the second line with a different column width - this should fail
            XCTAssertThrowsError(try writer.writeLine(fields: width5.inputArray())) { (error) -> Void in
                XCTAssertEqual(error as? CSVWriteError, CSVWriteError.invalidNumberOfColumns)
            }
            
        } catch let error {
            XCTFail("Failed to create instance of SCCSVWriter, recieved error \(error)")
        }
    }
    
    func runTestValidInputFor(mockData: WriteMockData) {
        
        let mockFileHandle = MockFileHandle()
        
        // Validate on write
        mockFileHandle.writeValidation = { data in
            
            guard let string = String(data: data, encoding: .utf8) else {
                XCTFail("Failed to convert data to utf8 string")
                return
            }
            
            XCTAssertEqual(string,
                           mockData.expectedString(),
                           "Expcted to be able to read data as \(mockData.expectedString()), but got string")
        }
        
        do {
            
            let writer = try SCCSVWriter(separator: mockData.separator(),
                                                newLine: mockData.newLine(),
                                                fileHandle: mockFileHandle)
            do {
                try writer.writeLine(fields: mockData.inputArray())
            } catch let writeError {
                XCTFail("Failed to write line \(mockData.inputArray()), recieved error \(writeError)")
            }
            
            XCTAssertTrue(mockFileHandle.writeWasCalled, "Expected a call to FileHandle write(_ data:Data) method")
            
        } catch let error {
            XCTFail("Failed to create instance of SCCSVWriter, recieved error \(error)")
        }
    }
}

class MockFileHandle: FileHandle {
    
    var writeValidation: ((Data) -> ())?
    var writeWasCalled = false
    var closeWasCalled = false
    
    override func write(_ data: Data) {
        writeWasCalled = true
        writeValidation?(data)
    }
    
    override func closeFile() {
        closeWasCalled = true
    }
}
