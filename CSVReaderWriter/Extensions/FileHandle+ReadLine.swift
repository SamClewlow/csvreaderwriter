//
//  FileHandle+ReadLine.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 21/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation

enum FileIOError: Error {
    case failedToReadFile
}

extension FileHandle {
    
    // Kind of crude way of checking is
    // position is at EOF, FileHandle
    // does not provide this
    var isEndOfFile: Bool {
        get {
            let currentOffset = offsetInFile
            
            seekToEndOfFile()
            let eofOffset = offsetInFile
            
            seek(toFileOffset: currentOffset)
            
            return currentOffset == eofOffset
        }
    }
    
    func readLine(ignoreInitialNewline: Bool = true) throws -> (line: String, endOfFile:Bool) {
        
        // Set the buffer and input size. Hard to know best buffer size
        // as it depends on file structure. 64 seems like a good compromise
        let bufferSize: UInt = 64
        let position = self.offsetInFile
        
        
        var data: Data?
        
        do {
            // Fill the buffer with data
            data = try FileHandleExceptionShim.safeReadData(ofLength: bufferSize, from: self)
        } catch {
            throw FileIOError.failedToReadFile
        }
        
        // Validate we got some good data
        guard let
            readData = data,
            let readString = String(data: readData, encoding:.utf8)
            else {
                return (line: "", endOfFile: self.isEndOfFile)
        }
        
        // Scanner class does not handle scanning up to a char if
        // that char is the first member of the string. We need to
        // handle that manually
        if let firstChar = readString.first?.unicodeScalars.first,
            CharacterSet.newlines.contains(firstChar) {
            
            // If the first char is a new line, just push the pointer
            // on one byte to ignore it
            self.seek(toFileOffset: position + 1)
            if ignoreInitialNewline {
                return try self.readLine()
            } else {
                return (line: "", endOfFile: self.isEndOfFile)
            }
        }
        
        // Check if we have a newline char in the buffer
        if readString.rangeOfCharacter(from: CharacterSet.newlines) != nil {
            
            guard let stringToNewline = scanStringToFirstNewline(string: readString) else {
                return (line: "", endOfFile: self.isEndOfFile)
            }
            
            // How long was the string in the buffer up to the newline? manually
            // scan to that point so we can re-read data after the new line
            let nextLineOffset = position + getByteOffset(string: stringToNewline as String) + 1
            self.seek(toFileOffset: nextLineOffset)
            
            return (line: stringToNewline, endOfFile: self.isEndOfFile)
            
        } else {
            
            // If the data we've read is smaller than the buffer size,
            // we can assume that we've read up to EOF
            if readData.count < bufferSize {
                return (line: readString, endOfFile: true)
                
            } else {
                // We haven't found a newline, recurse and perform
                // another read until we have a full line
                let restOfLineResult = try self.readLine(ignoreInitialNewline: false)
                let line = readString + restOfLineResult.line
                
                return (line: line, endOfFile: restOfLineResult.endOfFile)
            }
        }
    }
    
    private func scanStringToFirstNewline(string: String) -> String? {
        
        let scanner = Scanner(string: string)
        var scanned: NSString?
        if scanner.scanUpToCharacters(from: CharacterSet.newlines,
                                      into: &scanned) {
            
            if scanned?.length == 0 {
                return nil
            } else {
                return scanned as String?
            }
            
        } else {
            return nil
        }
    }
    
    private func getByteOffset(string: String) -> UInt64 {
        
        let a = UInt64(string.utf8.count)
        return a
    }
}
