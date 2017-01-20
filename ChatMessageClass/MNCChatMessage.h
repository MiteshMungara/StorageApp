#import <Foundation/Foundation.h>


@interface MNCChatMessage : NSObject

@property (nonatomic, strong) NSString* messageId;

@property (nonatomic, strong) NSArray* recipientIds;

@property (nonatomic, strong) NSString* senderId;

@property (nonatomic, strong) NSString* text;

@property (nonatomic, strong) NSDictionary* headers;

@property (nonatomic, strong) NSDate* timestamp;

@property (nonatomic, strong) NSString *incoming;

-(id) initWithName:(NSString*)cText;

@end