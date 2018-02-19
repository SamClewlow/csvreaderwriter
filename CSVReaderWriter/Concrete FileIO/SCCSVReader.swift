//
//  SCCSVReader.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import UIKit

class SCCSVReader: NSObject, CSVReader {
    
    // MARK:- Properties
    
    // These properties are force unwrapped as we ensure they
    // are set in the convenience initialiser
    
    // The expected number of columns, this is determined
    // by number recieved when reading the first line
    private var numberOfColumns: Int!
    
    // Column headers used for the dictionary keys when returning the data
    private var headers: [String]!
    private var isClosed = false
    
    private let separator: SeparatorType
    private let fileHandle: FileHandle
    
    
    // MARK: - Init
    
    convenience init(containsHeader: Bool,
                     separator: SeparatorType,
                     fileHandle: FileHandle) throws {

        self.init(separator: separator,
                  fileHandle: fileHandle)

        // Try to retreive the headers - we can't proceed without them
        headers = try getHeaders(containsHeader: containsHeader)
        
        // This won't support initial empty lines in the CSV, something that could be added later
        if headers.count == 0 {
            throw CSVReadError.emptyFile
        } else {
            numberOfColumns = headers.count
        }
    }
    
    private init(separator: SeparatorType,
                 fileHandle: FileHandle) {

        self.separator = separator
        self.fileHandle = fileHandle
    }

    
    deinit {
        fileHandle.closeFile()
    }
    
    
    // MARK:- CSVReader
    
    func readLine() throws -> (readLine: [String: String]?, endOfFileReached: Bool) {
        
        // Don't allow further writes if the file is closed
        if isClosed {
            throw CSVReadError.fileClosed
        }
        
        do {
            let lineResult = try fileHandle.readLine()

            let components = lineResult.line.components(separatedBy: separator.rawValue)
            
            if validate(components: components) {
                let dictionary = buildDictionaryFrom(components: components)
                return (readLine: dictionary, endOfFileReached: lineResult.endOfFile)
            } else {
                throw CSVReadError.unableToReadLineFileCorruption
            }
            
        } catch let error {
            // Make sure we throw the right error, as several nested types possible
            switch error {
            case CSVReadError.unableToReadLineFileCorruption:
                throw CSVReadError.unableToReadLineFileCorruption
            default:
                throw CSVReadError.unableToReadLineFromDisk
            }
        }
    }
    
    func close() {
        fileHandle.closeFile()
        isClosed = true
    }
    
    
    // MARK:- Internal
    
    private func getHeaders(containsHeader: Bool) throws -> [String] {
        
        let line = try fileHandle.readLine().line
        guard line.count != 0 else {
            throw CSVReadError.emptyFile
        }
        
        let components = line.components(separatedBy: separator.rawValue)

        
        // Read the pre-defined headers, and verify they are unique
        // if not, we'll ignore them and fall back to custom headers
        if containsHeader
        &&  headersAreUnique(headers: components) {

            return components
            
        } else {
            
            // Loop over a create a set of headers
            var generatedHeaders: [String] = []
            for (index, _) in components.enumerated() {
                generatedHeaders.append("\(index)")
            }
            
            // Rewind the file offset so we don't miss the first line
            // when the user requests to read it, if headers weren't provided
            if !containsHeader {
                fileHandle.seek(toFileOffset: 0)
            }
            return generatedHeaders
        }
    }
    
    private func validate(components: [String]) -> Bool {
        return components.count == numberOfColumns
    }
    
    private func buildDictionaryFrom(components: [String]) -> [String:String] {
        return Dictionary(uniqueKeysWithValues: zip(headers, components))
    }
    
    private func headersAreUnique(headers: [String]) -> Bool {
        return Set(headers).count == headers.count
    }
}
