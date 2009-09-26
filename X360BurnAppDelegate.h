//
//  X360BurnAppDelegate.h
//  X360Burn
//
//  Created by 赵 栓 on 09-9-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiscRecording/DiscRecording.h>
#import "DropImageView.h"
#import "TaskWrapper.h"
#import "Progress.h"

@interface X360BurnAppDelegate : NSWindowController<TaskWrapperDelegate> {
    NSWindow *window;
	DropImageView *dropIcon;
	NSPopUpButton *burnerPopup;
	NSPopUpButton *speedPopup;
	NSPopUpButton *methodPopup;
	NSTextField *layerBreak;
	NSTextField *statusText;
	NSButton *burnButton;
	NSButton *enableLayerBreakButton;
	DRBurn *burn;
	Progress *progressPanel;
	TaskWrapper *taskWrapper;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet id dropIcon;
@property (assign) IBOutlet NSPopUpButton *burnerPopup;
@property (assign) IBOutlet NSPopUpButton *speedPopup;
@property (assign) IBOutlet NSPopUpButton *methodPopup;
@property (assign) IBOutlet NSTextField *layerBreak;
@property (assign) IBOutlet NSTextField *statusText;
@property (assign) IBOutlet NSButton *burnButton;
@property (assign) IBOutlet NSButton *enableLayerBreakButton;
@property (assign) DRBurn *burn;

- (void)refresh;
- (void)updateDevice:(DRDevice *)device;
- (DRDevice *)currentDevice;
- (void)populateSpeeds:(DRDevice *)device;
- (IBAction)burnerPopup:(id)sender;
- (void)statusChanged:(NSNotification *)notif;
- (void)fileAssigned:(NSNotification *)notif;
- (void)mediaChanged:(NSNotification *)notification;
- (IBAction)startBurn:(id)sender;
- (IBAction)eject:(id)sender;
- (IBAction)toggleLayerBreak:(id)sender;
- (void) burnImageWithDRFW;
- (void) burnImageWithGrowisofs;
- (void)burnNotification:(NSNotification*)notification;

@end
