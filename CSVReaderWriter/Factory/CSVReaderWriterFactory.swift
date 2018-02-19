//
//  CSVReaderWriterFactory.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import UIKit

enum FactoryError: Error {
    case unableToOpenFileAtPath
}

// This class mainly exists to support dependancy injection, not
// really a production pattern but as we are missing a wider context
// it does the job
class CSVReaderWriterFactory: NSObject {
    
    class func createCSVReaderWith(filePath: String,
                                   containsHeader: Bool,
                                   separator: SeparatorType) throws -> CSVReader {
        
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            throw FactoryError.unableToOpenFileAtPath
        }
        
        return try SCCSVReader(containsHeader: containsHeader,
                                      separator: separator,
                                      fileHandle: fileHandle)
    }
    
    class func createCSVWriterWith(filePath: String,
                                   separator: SeparatorType,
                                   newLine: NewLineType) throws -> CSVWriter {
        
        if !CSVReaderWriterFactory.createFileAt(path: filePath) {
            throw CSVWriteError.failedToCreateFile
        }

        guard let fileHandle = FileHandle(forWritingAtPath: filePath) else {
            throw FactoryError.unableToOpenFileAtPath
        }
        
        return try SCCSVWriter(separator: separator,
                                      newLine: newLine,
                                      fileHandle: fileHandle)
    }
    
    class func fileExistsAt(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }

    class func createFileAt(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }
}
