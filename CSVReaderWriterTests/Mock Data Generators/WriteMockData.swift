//
//  WriteMockData.swift
//  CSVReaderWriterTests
//
//  Created by Sam Clewlow on 22/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation
@testable import CSVReaderWriter

enum WriteMockData {
    case tabSeparated
    case commaSeparated
    case blanks
    case width3
    case width5
    
    func expectedString() -> String {
        switch self {
        case .tabSeparated:
            return "this\tis\ttest\tdata\r"
        case .commaSeparated:
            return "this,is,test,data\n"
        case .blanks:
            return "this\t\ttest\t\n"
        case .width3:
            return "this,is,test\r"
        case .width5:
            return "this,is,test,data,data\r"
        }
    }
    
    func inputArray() -> [String] {
        switch self {
        case .tabSeparated:
            return ["this", "is", "test", "data"]
        case .commaSeparated:
            return ["this", "is", "test", "data"]
        case .blanks:
            return ["this", "", "test", ""]
        case .width3:
            return ["this", "is", "test"]
        case .width5:
            return  ["this", "is", "test", "data", "data"]
        }
    }
    
    func separator() -> SeparatorType {
        switch self {
        case .tabSeparated:
            return .tab
        case .commaSeparated:
            return .comma
        case .blanks:
            return .tab
        case .width3:
            return .comma
        case .width5:
            return .comma
        }
    }
    
    func newLine() -> NewLineType {
        switch self {
        case .tabSeparated:
            return .carriageReturn
        case .commaSeparated:
            return .lineFeed
        case .blanks:
            return .lineFeed
        case .width3:
            return .carriageReturn
        case .width5:
            return .carriageReturn
        }
    }
}
