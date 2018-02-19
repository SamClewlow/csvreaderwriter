//
//  ReadMockData.swift
//  CSVReaderWriterTests
//
//  Created by Sam Clewlow on 22/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation
@testable import CSVReaderWriter

enum ReadMockData: String {
    case singleLineValid = "single_line_valid_c4_l1"
    case extraLargeValid = "xl_valid_csv_c18_l20000"
    case empty = "empty"
    case variableWidth = "variable_width"
    case blanks = "blanks_c3_l5"
    
    func expectedColumnWidth() -> Int {
        switch self {
        case .singleLineValid:
            return 4
        case .extraLargeValid:
            return 18
        case .empty:
            return 0
        case .variableWidth:
            return 0
        case .blanks:
            return 3
        }
    }
    
    func expectedNumberOfLines() -> Int {
        switch self {
        case .singleLineValid:
            return 1
        case .extraLargeValid:
            return 20000
        case .empty:
            return 0
        case .variableWidth:
            return 0
        case .blanks:
            return 5
        }
    }
    
    func containsHeaders() -> Bool {
        switch self {
        case .singleLineValid:
            return false
        case .extraLargeValid:
            return true
        case .empty:
            return false
        case .variableWidth:
            return false
        case .blanks:
            return false
        }
    }
    
    func expectedHeaders() -> [String] {
        switch self {
        case .singleLineValid:
            return ["field_1", "field_2", "field_3", "field_4"]
        case .extraLargeValid:
            return ["policyID",
                    "statecode",
                    "county",
                    "eq_site_limit",
                    "hu_site_limit",
                    "fl_site_limit",
                    "fr_site_limit",
                    "tiv_2011",
                    "tiv_2012",
                    "eq_site_deductible",
                    "hu_site_deductible",
                    "fl_site_deductible",
                    "fr_site_deductible",
                    "point_latitude",
                    "point_longitude",
                    "line",
                    "construction",
                    "point_granularity"]
        case .empty:
            return []
        case .variableWidth:
            return []
        case .blanks:
            return ["0", "1", "2", "3", "4"]
        }
    }
    
}
