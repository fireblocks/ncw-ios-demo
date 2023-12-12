//
//  ObjectiveCUtils.h
//  Trading
//
//  Created by Hed on 15/03/2019.
//  Copyright © 2019 Hed. All rights reserved.
//

#ifndef ObjectiveCUtils_h
#define ObjectiveCUtils_h
#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* ObjectiveCUtils_h */
