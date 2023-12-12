//
//  wrapper.h
//  Trading
//
//  Created by Hed on 18/02/2019.
//  Copyright © 2019 Hed. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NSData* (^loadDataSwiftBridge)(NSString* namespaceString, NSString* key);
typedef BOOL (^storeDataSwiftBridge)(NSString* namespaceString, NSString* key, NSData* data);
typedef BOOL (^deleteDataSwiftBridge)(NSString* namespaceString, NSString* key);
typedef BOOL (^keyExistsSwiftBridge)(NSString* namespaceString, NSString* key);
typedef void (^logSwiftBridge)(int level, NSString* msg);

typedef NSData* (^loadKeySwiftBridge)(NSString* keyId);

typedef NSString* (^getPrivateKeySwiftBridge)();
typedef NSString* (^getPublicKeySwiftBridge)(uint64_t playerId);

@interface MPCWrapper : NSObject

- (id)initWithPlayerId:(uint64_t)playerId :(NSString*)tenantId :(loadDataSwiftBridge)swiftLoadData :(storeDataSwiftBridge)swiftStoreData :(deleteDataSwiftBridge)swiftDeleteData :(keyExistsSwiftBridge)swiftKeyExists :(getPrivateKeySwiftBridge)swiftGetPrivateKey :(getPublicKeySwiftBridge)swiftGetPublicKey :(logSwiftBridge)swiftLog :(loadKeySwiftBridge)loadKeySwift;
- (NSDictionary*)generate_share_commitments:(NSString*)keyId :(NSString*)tenantId :(NSArray*)playerIds :(int)t :(int64_t)ttl :(int)algorithm;


- (NSDictionary*)generate_setup_commitments:(NSString*)keyId :(NSString*)tenantId :(int)algorithm :(NSArray*)playerIds :(int)t :(int64_t)ttl;
- (NSDictionary*)store_setup_commitments:(NSString*)keyId :(NSArray*)playerIds :(NSDictionary*)commitments;
- (NSDictionary*)generate_setup_proofs:(NSString*)keyId :(NSArray*)playerIds :(NSDictionary*)decommitments;
- (NSDictionary*)verify_setup_proofs:(NSString*)keyId :(NSArray*)playerIds :(NSDictionary*)proofs;

- (NSDictionary*)start_eddsa_signature_preprocessing:(NSString*)tenantId: (NSString*)keyId :(NSString*)requestId :(NSArray*)playerIds :(int64_t)startIndex :(int32_t)count :(int32_t)totalCount;
- (NSDictionary*)start_ecdsa_signature_preprocessing:(NSString*) tenantId :(NSString*)keyId :(NSString*)requestId :(NSArray*)playerIds :(int64_t)startIndex :(int32_t) count :(int32_t) totalCount;
- (NSDictionary*)eddsa_preprocessing_decommit:(NSString*)requestId :(NSArray*)playerIds :(NSDictionary*)commitments;
- (NSDictionary*)r_preprocessing:(NSString*)requestId :(NSArray*)playerIds :(NSDictionary*)Rs;
- (NSDictionary*)mta_response:(NSString*)requestId :(NSArray*)playerIds :(int)version :(NSDictionary*)req;
- (NSDictionary*)mta_verify:(NSString*)requestId :(NSArray*)playerIds :(NSDictionary*)req;
- (NSDictionary*)store_ecdsa_presigning_data:(NSString*)requestId :(NSArray*)playerIds :(NSDictionary*)req;
- (NSDictionary*)cmp_add_user:(NSString*)tenantId :(NSString*)keyId :(NSDictionary*)payload :(int)algorithm;
- (void)cancel_preprocessing:(NSString*)requestId;

- (NSDictionary*)refresh_key_request_fast:(NSString*)tenantId :(NSString*)keyId :(NSString*)requestId :(NSArray*)playerIds;
- (NSDictionary*)refresh_key_fast:(NSString*)requestId :(NSArray*)playerIds :(NSDictionary*)seeds;
- (void)refresh_key_ack_fast:(NSString*)requestId :(NSString*)keyId;

- (NSString*)store_share_commitments:(NSString*)sessionContext :(NSString*)keyId :(NSArray*)commitments;
- (NSDictionary*)generate_shares:(NSString*)sessionContext :(NSString*)keyId :(NSDictionary*)acks;
- (NSDictionary*)create_secret:(NSString*)sessionContext :(NSString*)keyId :(NSDictionary*) share;
- (NSDictionary*)create_cmp_secret:(NSString*)keyId :(NSDictionary*) share;
- (BOOL)cancel_key_creation:(NSString*)sessionContext :(NSString*)keyId;
- (NSDictionary*)generate_signature_commitment:(NSString*)sessionContext :(NSString*)keyId :(NSString*)txId :(NSString*)metaDataString :(NSDictionary*)metaData :(NSArray*)playerIds :(BOOL)eddsa :(BOOL)cmpOnline :(int64_t)start_index;
-(NSDictionary*)store_eddsa_signature_commitments:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)commitments :(int)version;
-(NSDictionary*)on_r_broadcast:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)decommitments;
-(NSDictionary*)on_s_broadcast:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)sis;
-(NSDictionary*)store_signature_commitments:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)commitments :(int)version;
-(NSDictionary*)on_mta_message:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)mta_messages;
-(NSDictionary*)on_gamma_broadcast:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)messages;
-(NSDictionary*)add_user_request:(NSString*)keyId :(NSString*)newKeyId :(NSString*)tenantId :(NSArray*)playerIds :(int)t :(int64_t)ttl :(int)algorithm :(BOOL)isCmp;
-(NSDictionary*)add_user:(NSString*)sessionContext :(NSString*)tenantId :(NSString*)txId :(NSDictionary*)shares_and_proofs :(int64_t)ttl :(int)algorithm;
-(NSDictionary*)on_mta_message_reply:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)mta_messages;
-(NSDictionary*)get_si_validation_step1:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)deltas;
-(NSDictionary*)get_si_validation_step2:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)messages;
-(NSDictionary*)get_si_validation_step3:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)sigValidations;
-(NSDictionary*)get_si_validation_step4:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)commitments;
-(NSDictionary*)get_si_validation_step5:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)commitments;
-(NSDictionary*)get_final_signature:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)sis;
-(NSDictionary*)get_sis:(NSString*)txId :(NSArray*)playerIds :(NSDictionary*)req;
-(NSDictionary*)get_cmp_signature:(NSString*)sessionContext :(NSString*)txId :(NSDictionary*)sis;
-(NSDictionary*)start_key_upgrade:(NSString*)tenantId :(NSString*)keyId :(int)algorithm :(NSString*)newKeyId :(NSArray*)playerIds :(NSArray*)newPlayerIds;
-(NSDictionary*)cancel_signing:(NSString*)sessionContext :(NSString*)txId;
-(void)setPublicKeyForMetadata:(NSString*)publicKey :(NSString*)keyId;

-(NSDictionary*)get_recovered_additive_mpc_key:(int)cppAlgorithmIndex :(NSData*)mobileKeyShareData :(NSArray*)cloudKeyShares;
-(NSString*)get_encoded_extended_private_key:(NSData*)recoveredPrivateKey :(NSData*)chainCodeAsByteArray :(int)cppAlgorithmIndex;
-(NSString*)get_encoded_extended_public_key:(NSData*)recoveredPublicKey :(NSData*)chainCodeAsByteArray :(int)cppAlgorithmIndex;
-(NSDictionary*)get_decoded_extended_private_key:(NSString*)extendedPrivateKey;
-(NSData*)get_derived_asset_key:(NSData*)privateKey :(NSData*)chainCode :(int)algorithm :(int)coinType :(int)account :(int)change :(int)index;

+(NSString*)csr_request:(NSString*)playerId :(NSString*)key;
+(NSString*)playerIdFormat:(int64_t)p_id;
+(BOOL)isMobilePlayerId:(int64_t)p_id;
+(NSData*)buildMetadataObject:(NSString*)publicKeyHex :(uint8_t)t :(uint8_t)n :(NSArray*)playerIds :(uint8_t)algorithm;
+(NSData*)buildCmpMetadataObject:(NSString*)publicKeyHex :(uint8_t)t :(uint8_t)n :(NSArray*)playerIds :(uint8_t)algorithm;
+(NSString*)getPayloadFromJsonString:(NSString*)json;
+(NSData*)getDataPayloadFromJsonData:(NSData*)json;


-(void)destroyCtx;
@end
