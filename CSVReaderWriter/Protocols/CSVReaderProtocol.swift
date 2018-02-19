//
//  CSVReaderProtocol.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation

enum CSVReadError: Error {
    case unableToOpenFile
    case unableToReadLineFromDisk
    case unableToReadLineFileCorruption
    case emptyFile
    case fileClosed
}

protocol CSVReader {
    
    
    /// Reads the next line from a CSV file
    ///
    /// - Returns: A tuple containing the read data as a dictionary, and a bool indicating if EOF has been reached
    /// - Throws: CSVReadError
    func readLine() throws -> (readLine: [String: String]?, endOfFileReached: Bool)
    
    
    /// Close the file for reading. The file cannot be read again after calling this method
    func close()
}
