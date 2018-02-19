//
//  CSVWriterProtocol.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation

enum CSVWriteError: Error {
    case unableToOpenFile
    case invalidNumberOfColumns
    case failedToEncodeInput
    case failedToWriteToFile
    case failedToCreateFile
    case fileClosed
}

protocol CSVWriter {
    
    /// Writes a single line of data to a CSV file
    ///
    /// - Parameter fields: The fields to write, in an ordered array
    /// - Throws: CSVWriteError
    func writeLine(fields: [String]) throws
    
    /// Close the file for reading. The file cannot be read again after calling this method
    func close()
}
