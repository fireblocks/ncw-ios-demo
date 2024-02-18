//
//  DataFragmentingWrapper.h
//  Trading
//
//  Created by Lena Brusilovski on 30/11/2020.
//  Copyright © 2020 Fireblocks. All rights reserved.
//

#ifndef DataFragmentingWrapper_h
#define DataFragmentingWrapper_h
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, DataFragmentDecodingStatus){
    Finished,
    InProgress,
    Error
};

@interface DataFragmentingWrapper : NSObject
-(NSArray<NSData *> *)fragmentsForString:(NSString *)string preferredChunkSizeByteCount:(int) preferredChunkSize cycleCount:(int)cycleCount;
-(DataFragmentDecodingStatus)decodeFragment:(NSString *)input;
-(NSData *)reconstructedData;
@end
#endif /* DataFragmentingWrapper_h */
