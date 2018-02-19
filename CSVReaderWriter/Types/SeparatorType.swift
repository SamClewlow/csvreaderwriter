//
//  SeparatorType.swift
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 18/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

import Foundation

enum SeparatorType: String {
    case tab = "\t"
    case comma = ","
}

// Currently only support for single char newlines
// Support for multiline chars in future (eg CRLF)
enum NewLineType: String {
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
