//
//  Progress.m
//  X360Burn
//
//  Created by 赵 栓 on 09-9-24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Progress.h"


@implementation Progress

- (id)init {
	self = [super init];
	
	[NSBundle loadNibNamed:@"Progress" owner:self];
	
	return self;
}

- (void)dealloc {
	[progressBar stopAnimation:self];
	[super dealloc];
}

- (void)beginSheetForWindow:(NSWindow *)window {
	[NSApp beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
}

- (void)endSheet {
	[NSApp endSheet:[self window]];
}

- (void)setTask:(NSString *)task {
	[taskText performSelectorOnMainThread:@selector(setStringValue:) withObject:task waitUntilDone:YES];
}

- (void)setStatus:(NSString *)status {
	[statusText performSelectorOnMainThread:@selector(setStringValue:) withObject:status waitUntilDone:YES];
}

- (void)setMaximumValue:(NSNumber *)number {
	[self performSelectorOnMainThread:@selector(setMaxiumValueOnMainThread:) withObject:number waitUntilDone:YES];
}

- (void)setValue:(NSNumber *)number {
	if ([number doubleValue] == -1) {
		[progressBar performSelectorOnMainThread:@selector(startAnimation:) withObject:self waitUntilDone:YES];
	}
	
	if ([number doubleValue] > [progressBar doubleValue]) {
		[self performSelectorOnMainThread:@selector(setDoubleValueOnMainThread:) withObject:number waitUntilDone:YES];		
	}
}

- (void)setMaxiumValueOnMainThread:(NSNumber *)number {
	[progressBar setMaxValue:[number doubleValue]];
	if ([number doubleValue] > 0){
		[progressBar setIndeterminate:NO];
		[progressBar setMaxValue:[number doubleValue]];
	}else{
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	}
}

- (void)setDoubleValueOnMainThread:(NSNumber *)number {
	[progressBar setDoubleValue:[number doubleValue]];
}

@end
