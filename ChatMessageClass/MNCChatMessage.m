//
//  MNCChatMessage.m
//  ios-sinch-messaging-tutorial
//
//  Created by christian jensen on 1/19/15.
//  Copyright (c) 2015 christian jensen. All rights reserved.
//

#import "MNCChatMessage.h"

@implementation MNCChatMessage

@synthesize text;

-(id) initWithName:(NSString*) cText
{
    self = [super init];
    if(self)
    {
        self.text = cText;
    }
    return self;
}
@end
