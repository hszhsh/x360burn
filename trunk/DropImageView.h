//
//  DropImageView.h
//  X360Burn
//
//  Created by 赵 栓 on 09-9-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DropImageView : NSImageView {
	NSTextField *dropText;
	NSTextField *fileName;
	NSTextField *fileSize;
	NSTextField *fileType;
	NSString *filePath;
}

@property (assign) IBOutlet NSTextField *dropText;
@property (assign) IBOutlet NSTextField *fileName;
@property (assign) IBOutlet NSTextField *fileSize;
@property (assign) IBOutlet NSTextField *fileType;
@property (assign) NSString *filePath;

- (unsigned long)getImageSizeAtPath:(NSString *)path;

@end
