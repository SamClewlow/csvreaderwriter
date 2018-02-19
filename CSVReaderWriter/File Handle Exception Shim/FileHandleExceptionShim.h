//
//  FileHandleExceptionShim.h
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 21/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull const FileWriteError;
FOUNDATION_EXPORT NSString * _Nonnull const FileReadError;

/*
 This class exists to gaurd against NSExceptions raised in objective-c,
 Thanks can't be handled in Swift natively
 */

@interface FileHandleExceptionShim : NSObject

+ (nullable NSData *)safeReadDataOfLength:(NSUInteger)length
                           fromFileHandle:(nonnull NSFileHandle *)fileHandle
                                    error:(NSError * _Nullable * _Nullable)error;

@end
