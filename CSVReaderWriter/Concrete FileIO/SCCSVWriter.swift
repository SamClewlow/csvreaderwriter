//
//  SCCSVWriter.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import UIKit

class SCCSVWriter: NSObject, CSVWriter {
    
    
    //MARK:- Properties
    
    private let fileHandle: FileHandle
    private let separator: SeparatorType
    private let newLine: NewLineType

    // Try to protect against inconsistent column widths
    // defined by the first write
    private var _columnWidth: Int?
    
    // Try to protect against users trying to write to
    // a closed filehandle
    private var isClosed = false
    
    
    //MARK:- Init
    
    init(separator: SeparatorType,
         newLine: NewLineType,
         fileHandle: FileHandle) throws {
        
        self.fileHandle = fileHandle
        self.separator = separator
        self.newLine = newLine
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    
    //MARK:- CSVWriter
    
    func writeLine(fields: [String]) throws {
        
        // Don't allow further wrties after the file has been closed
        if isClosed {
            throw CSVWriteError.fileClosed
        }
        
        // Basic input validation
        if !validateFields(fields: fields) {
            throw CSVWriteError.invalidNumberOfColumns
        }
        
        let line = prepareLineToWrite(fields: fields)
        guard let data = line.data(using: .utf8) else {
            throw CSVWriteError.failedToEncodeInput
        }
        
        fileHandle.write(data)
    }

    func close() {
        fileHandle.closeFile()
        isClosed = true
    }
    
    
    //MARK:- Internal
    
    private func validateFields(fields: [String]) -> Bool {
        
        // We don's support writing blank lines
        if fields.count == 0 {
            return false
        }
        
        // We should get the column width from the first
        // line the user tries to write. This is protecting
        // the user from writing inconsistent data to the file
        // that can't be re-read meaningfully
        if let columnWidth = _columnWidth {
            return fields.count == columnWidth
        } else {
            _columnWidth = fields.count
            return true
        }
    }
    
    private func prepareLineToWrite(fields: [String]) -> String {
        
        return fields.reduce(""){ $0 + separator.rawValue + $1}.dropFirst() + newLine.rawValue
    }
}
