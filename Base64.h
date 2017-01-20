#import <Foundation/Foundation.h>

@interface NSString (base64encode)
- (NSString *)base64encode;
@end

@interface NSData (base64encode)
- (NSString *)base64encode;
@end

@interface Base64 : NSObject
+ (void) initialize;
+ (NSString *)encode:(const uint8_t*)input length:(NSInteger)length;
+ (NSString *)encode:(NSData*)rawBytes;
+ (NSData *)decode:(const char*)string length:(NSInteger)inputLength;
+ (NSData *)decode:(NSString*)string;
@end