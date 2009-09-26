//
//  Progress.h
//  X360Burn
//
//  Created by 赵 栓 on 09-9-24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

@interface Progress : NSWindowController {

	IBOutlet id progressBar;
    IBOutlet id statusText;
    IBOutlet id taskText;
	
}

- (void)beginSheetForWindow:(NSWindow *)window;
- (void)endSheet;
- (void)setTask:(NSString *)task;
- (void)setStatus:(NSString *)status;
- (void)setMaximumValue:(NSNumber *)number;
- (void)setValue:(NSNumber *)number;
- (void)setMaxiumValueOnMainThread:(NSNumber *)number;
- (void)setDoubleValueOnMainThread:(NSNumber *)number;

@end
