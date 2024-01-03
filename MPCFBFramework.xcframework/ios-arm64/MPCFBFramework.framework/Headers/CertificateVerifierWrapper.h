//
//  CertificateVerifierWrapper.h
//  Trading
//
//  Created by Hed I on 04/09/2019.
//  Copyright © 2019 Hed. All rights reserved.
//

#ifndef CertificateVerifierWrapper_h
#define CertificateVerifierWrapper_h

#import <Foundation/Foundation.h>

@interface CertificateVerifierWrapper : NSObject
typedef void (^logSwiftBridge)(int level, NSString* msg);

-(id)initWithRootCa:(NSString*)rootCa :(logSwiftBridge) logFunc;
-(BOOL)verifyCa:(NSString*)pem;
+(NSString*)getCn:(NSString*)pem;
+(NSString*)getPublicKeyString:(NSString*)pem convertToDER: (BOOL)convertToDer;
+(NSString*)getNotAfter:(NSString*)pem;

@end

#endif /* CertificateVerifierWrapper_h */
