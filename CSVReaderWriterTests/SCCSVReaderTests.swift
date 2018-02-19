//
//  SCCSVReaderTests.swift
//  CSVReaderWriterTests
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import XCTest
@testable import CSVReaderWriter


class SCCSVReaderTests: XCTestCase {

        
    func testSingleLineCSV() {
        
        let mockData: ReadMockData = .singleLineValid
        guard let fileHandle = getFileHandleFor(mockDataFile: mockData) else {
            return
        }
        
        let optionalReader = try? SCCSVReader(containsHeader: false,
                                                     separator: .comma,
                                                     fileHandle: fileHandle)

        guard let reader = optionalReader else {
            XCTFail("Failed to init reader for \(mockData)")
            return
        }
        
        do {
            let readLine = try reader.readLine()
            XCTAssertTrue(readLine.endOfFileReached, "Expected EOF to be true")
            
            guard  let dictionary = readLine.readLine else {
                XCTFail("Expected the read line as dictionary, but recieved nil.")
                return
            }
            
            XCTAssertEqual(dictionary.keys.count, mockData.expectedColumnWidth(), "Expected \(mockData.expectedColumnWidth()) fields, but got \(dictionary.count)")
            
            
        } catch let error {
            XCTFail("Expected to read a single line, but instead error \(error) was thrown")
            return
        }
    }
    
    func testLargeCSV() {
        
        runCSVValidationTestFor(mockData: .extraLargeValid)
    }
    
    func testCSVWithBlanks() {
        runCSVValidationTestFor(mockData: .blanks)
    }
    
    func testEmptyCSV() {
        let mockData: ReadMockData = .empty
        guard let fileHandle = getFileHandleFor(mockDataFile: mockData) else {
            XCTFail("Failed to load filehandle for \(mockData)")
            return
        }
        
        XCTAssertThrowsError(try SCCSVReader(containsHeader: false,
                                                    separator: .comma,
                                                    fileHandle: fileHandle)) { (error) -> Void in
                                                        XCTAssertEqual(error as? CSVReadError, CSVReadError.emptyFile)
        }
    }
    
    func testVariableColumnWidthCSV() {
        let mockData: ReadMockData = .variableWidth
        guard let fileHandle = getFileHandleFor(mockDataFile: mockData) else {
            XCTFail("Failed to load filehandle for \(mockData)")
            return
        }
        
        let optionalReader = try? SCCSVReader(containsHeader: true,
                                                     separator: .comma,
                                                     fileHandle: fileHandle)
        
        guard let reader = optionalReader else {
            XCTFail("Failed to init reader for \(mockData)")
            return
        }
        
        XCTAssertThrowsError(try reader.readLine()) { (error) -> Void in
                                                        XCTAssertEqual(error as? CSVReadError, CSVReadError.unableToReadLineFileCorruption)
        }
    }

    func runCSVValidationTestFor(mockData: ReadMockData) {
        
        guard let fileHandle = getFileHandleFor(mockDataFile: mockData) else {
            XCTFail("Failed to load filehandle for \(mockData)")
            return
        }
        
        let optionalReader = try? SCCSVReader(containsHeader: mockData.containsHeaders(),
                                                     separator: .comma,
                                                     fileHandle: fileHandle)
        
        guard let reader = optionalReader else {
            XCTFail("Failed to init reader for \(mockData)")
            return
        }
        
        var lineCount = 0
        
        // loop over the expected number of lines and ensure each one is read correctly
        while lineCount < mockData.expectedNumberOfLines() {
            autoreleasepool {
                do {
                    let readLine = try reader.readLine()
                    
                    // Validate we get an EOF when we expect it
                    // NB, this test is fragile, add additional new lines in the csv files will break here
                    if lineCount == mockData.expectedNumberOfLines() - 1 {
                        XCTAssertTrue(readLine.endOfFileReached, "Expected EOF to be true")
                    } else {
                        XCTAssertFalse(readLine.endOfFileReached, "Expected EOF to be false")
                    }
                    
                    guard  let dictionary = readLine.readLine else {
                        XCTFail("Expected the read line as dictionary, but recieved nil for csv line \(lineCount).")
                        return
                    }
                    
                    if dictionary.keys.count != mockData.expectedColumnWidth() {
                        XCTFail("Expected \(mockData.expectedColumnWidth()) fields, but got \(dictionary.count) for csv line \(lineCount)")
                        return
                    }
                    
                    checkHeadersFor(readLine: dictionary, mockDataFile: mockData)
                    
                } catch let error {
                    XCTFail("Expected to read line \(lineCount), but instead error \(error) was thrown")
                    
                }
                print("lineCount \(lineCount)")
                lineCount += 1
            }
        }
    }
}


extension SCCSVReaderTests {
    
    func getFileHandleFor(mockDataFile: ReadMockData) -> FileHandle? {
        
        let bundle = Bundle(for: type(of: self))
        
        guard let filePath = bundle.path(forResource: mockDataFile.rawValue,
                                         ofType: "csv") else {
                                            XCTFail("Failed to find path for mock data \(mockDataFile.rawValue)")
                                            return nil
        }
        
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            XCTFail("Failed to load file handle for path \(filePath)")
            return nil
        }
        
        return fileHandle
    }
    
    func checkHeadersFor(readLine: [String: String], mockDataFile: ReadMockData) {
        
        let expectedHeaders = mockDataFile.expectedHeaders()
        
        for headerName in readLine.keys {
            if !expectedHeaders.contains(headerName) {
                XCTFail("Header: \(headerName) not found in expected headers for \(mockDataFile)")
            }
        }
    }
}
