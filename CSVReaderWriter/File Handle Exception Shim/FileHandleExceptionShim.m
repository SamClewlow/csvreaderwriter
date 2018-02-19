//
//  FileHandleExceptionShim.m
//  CSVReaderWriter
//
//  Created by Sam Clewlow on 21/01/2018.
//  Copyright © 2018 Pdex Tech Ltd. All rights reserved.
//

#import "FileHandleExceptionShim.h"

NSString *const FileWriteError = @"FileWriteError";
NSString *const FileReadError = @"FileReadError";

@implementation FileHandleExceptionShim

+ (nullable NSData *)safeReadDataOfLength:(NSUInteger)length
                           fromFileHandle:(nonnull NSFileHandle *)fileHandle
                                    error:( NSError * _Nonnull * _Nullable) error {
    
    @try {
        NSData *data = [fileHandle readDataOfLength:length];
        return data;
    }
    @catch (NSException *exception) {
        *error = [NSError errorWithDomain:FileReadError
                                     code:0
                                 userInfo:nil];
    }
    @finally {
        
    }
    
    return nil;
}

@end
