//
//  CosignerWrapper.h
//  Trading
//
//  Created by Hed on 01/11/2018.
//  Copyright © 2018 Hed. All rights reserved.
//

#ifndef CosignerWrapper_h
#define CosignerWrapper_h

#import <Foundation/Foundation.h>

@interface CosignerWrapper : NSObject

+ (CosignerWrapper*)shared;
- (void)generateKeyWith:(void (^)(BOOL success, uint8_t *publicKey, uint32_t publicKeySize, uint8_t *privateKey, uint32_t privateKeySize))completion;
- (void)signPaylod:(uint8_t*)key :(uint32_t)keySize :(uint8_t*)payload :(uint32_t)payloadSize :(void (^)(BOOL success, uint8_t *signature, uint32_t signatureSize))completion;
@end

#endif /* CosignerWrapper_h */



