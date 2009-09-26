//
//  X360BurnAppDelegate.m
//  X360Burn
//
//  Created by 赵 栓 on 09-9-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "X360BurnAppDelegate.h"

@implementation X360BurnAppDelegate

@synthesize window;
@synthesize dropIcon;
@synthesize burnerPopup;
@synthesize speedPopup;
@synthesize methodPopup;
@synthesize layerBreak;
@synthesize statusText;
@synthesize burnButton;
@synthesize enableLayerBreakButton;
@synthesize burn;

- (void)awakeFromNib {
	[methodPopup removeAllItems];
	[methodPopup addItemWithTitle:@"Apple DiscRecording.framework"];
	[methodPopup addItemWithTitle:@"growisofs"];
	[methodPopup selectItemAtIndex:0];
	[self refresh];
	
	[[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(statusChanged:) name:DRDeviceStatusChangedNotification object:nil];
	[[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(mediaChanged:) name:DRDeviceDisappearedNotification object:nil];
	[[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(mediaChanged:) name:DRDeviceAppearedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileAssigned:) name:@"FileSelected" object:nil];
}

- (void)refresh {
	[burnerPopup removeAllItems];

	int i;
	for (i=0;i< [[DRDevice devices] count];i++){
		//NSString *bsdName = [[[DRDevice devices] objectAtIndex:i] bsdName];
		//NSString *disName = [[[DRDevice devices] objectAtIndex:i] displayName];
		[burnerPopup addItemWithTitle:[[[DRDevice devices] objectAtIndex:i] displayName]];
	}
	
	[self updateDevice:[self currentDevice]];
	
	
}

- (void)updateDevice:(DRDevice *)device {

	if ([[[device status] objectForKey:DRDeviceMediaStateKey] isEqualTo:DRDeviceMediaStateMediaPresent]){
		if ([[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaIsBlankKey] boolValue] | [[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaIsAppendableKey] boolValue] | [[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaIsOverwritableKey] boolValue]){
			[self populateSpeeds:device];
			[speedPopup setEnabled:YES];
			
			[statusText setStringValue:NSLocalizedString(@"Ready to burn", Localized)];
			
			if(dropIcon.filePath != nil)
				[burnButton setEnabled:YES];
		}
		else{
			[device ejectMedia];
		}
	}
	else if ([[[device status] objectForKey:DRDeviceMediaStateKey] isEqualTo:DRDeviceMediaStateInTransition]){
		[speedPopup setEnabled:NO];
		[statusText setStringValue:NSLocalizedString(@"Waiting for the drive...", Localized)];
		[burnButton setEnabled:NO];
	}
	else if ([[[device status] objectForKey:DRDeviceMediaStateKey] isEqualTo:DRDeviceMediaStateNone]){
		[self populateSpeeds:device];
		[speedPopup setEnabled:NO];
		
		[statusText setStringValue:NSLocalizedString(@"Waiting for a disc to be inserted...", Localized)];
		[burnButton setEnabled:NO];
	}
}

- (void)populateSpeeds:(DRDevice *)device {
	NSArray *speeds = [[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceBurnSpeedsKey];
	int speed;
	[speedPopup removeAllItems];
	
	if ([speeds count] > 0){
		int z;
		for (z=0;z<[speeds count];z++) {
			if ([[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaClassKey] isEqualTo:DRDeviceMediaClassCD])
				speed = round([[speeds objectAtIndex:z] floatValue] / DRDeviceBurnSpeedCD1x);
			else
				speed = round([[speeds objectAtIndex:z] floatValue] / DRDeviceBurnSpeedDVD1x);
			
			[speedPopup addItemWithTitle:[[[NSNumber numberWithInt:speed] stringValue] stringByAppendingString:@"x"]];
		}
		
		if ([[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaClassKey] isEqualTo:DRDeviceMediaClassCD])
			speed = round([[speeds objectAtIndex:[speeds count]-1] floatValue] / DRDeviceBurnSpeedCD1x);
		else
			speed = round([[speeds objectAtIndex:[speeds count]-1] floatValue] / DRDeviceBurnSpeedDVD1x);
		
		[speedPopup insertItemWithTitle:[[[NSLocalizedString(@"Maximum Possible", Localized) stringByAppendingString:@" ("] stringByAppendingString:[[NSNumber numberWithInt:speed] stringValue]] stringByAppendingString:@"x)"] atIndex:0];
		[[speedPopup menu] insertItem:[NSMenuItem separatorItem] atIndex:1];
		
		[speedPopup selectItemAtIndex:0];
	}
	else{
		[speedPopup addItemWithTitle:NSLocalizedString(@"Maximum Possible", Localized)];
	}
}


- (DRDevice *)currentDevice {
	return [[DRDevice devices] objectAtIndex:[burnerPopup indexOfSelectedItem]];
}


- (void)dealloc {
	[[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRDeviceStatusChangedNotification object:nil];
	[[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRDeviceDisappearedNotification object:nil];
	[[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRDeviceAppearedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[window	release];
	[burnerPopup release];
	[speedPopup release];
	[methodPopup release];
	[layerBreak release];
	[statusText release];
	[burnButton release];
	[taskWrapper release];
	[super dealloc];
}

- (void)statusChanged:(NSNotification *)notif {
	if ([[[notif object] displayName] isEqualTo:[burnerPopup title]])
		[self updateDevice:[notif object]];
}

- (void)fileAssigned:(NSNotification *)notif {
	[self updateDevice:[self currentDevice]];
}

- (void)mediaChanged:(NSNotification *)notification {
	[burnerPopup removeAllItems];
	
	int i;
	for (i=0;i< [[DRDevice devices] count];i++){
		[burnerPopup addItemWithTitle:[[[DRDevice devices] objectAtIndex:i] displayName]];
	}
	
	[self updateDevice:[self currentDevice]];
}

- (void) burnImageWithDRFW {
	DRDevice *device = [self currentDevice];
	
	NSArray *speeds = [[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceBurnSpeedsKey];
	NSNumber *speed;
	if ([speedPopup indexOfSelectedItem] == 0)
		speed = [speeds objectAtIndex:[speeds count] - 1];
	else
		speed = [speeds objectAtIndex:[speedPopup indexOfSelectedItem] - 2];
	
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	[properties setObject:speed forKey:DRBurnRequestedSpeedKey];
	if([enableLayerBreakButton state] == NSOnState) {
		[properties setObject:[NSNumber numberWithInt:[layerBreak intValue]] forKey:DRBurnDoubleLayerL0DataZoneBlocksKey];
	}
	[properties setObject:[NSNumber numberWithBool:NO] forKey:DRBurnVerifyDiscKey];
	
	burn = [DRBurn burnForDevice:device];
	[burn setProperties:properties];
	id layout = [DRBurn layoutForImageFile:dropIcon.filePath];
	if (layout != nil) {
		[[DRNotificationCenter currentRunLoopCenter] addObserver:self selector:@selector(burnNotification:) name:DRBurnStatusChangedNotification object:burn];
		[burn writeLayout:layout];
		progressPanel = [[Progress alloc] init];
		[progressPanel setTask:@"Burning"];
		[progressPanel beginSheetForWindow:window];
		[progressPanel setMaximumValue:[NSNumber numberWithDouble:0]];
	}
}

- (void) burnImageWithGrowisofs {
	DRDevice *device = [self currentDevice];
	
	NSArray *speeds = [[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceBurnSpeedsKey];
	int speed;
	NSNumber *z;
	if ([speedPopup indexOfSelectedItem] == 0)
		z = [speeds objectAtIndex:[speeds count] - 1];
	else
		z = [speeds objectAtIndex:[speedPopup indexOfSelectedItem] - 2];
	if ([[[[device status] objectForKey:DRDeviceMediaInfoKey] objectForKey:DRDeviceMediaClassKey] isEqualTo:DRDeviceMediaClassCD])
		speed = round([z floatValue] / DRDeviceBurnSpeedCD1x);
	else
		speed = round([z floatValue] / DRDeviceBurnSpeedDVD1x);
	NSString *deviceAndImageArg = [NSString stringWithFormat:@"/dev/r%@=%@", [device bsdName], dropIcon.filePath];
	NSString *cmdPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/growisofs"];
	NSString *speedArg = [NSString stringWithFormat:@"-speed=%d", speed];
	NSString *layerBreakArg = [NSString stringWithFormat:@"-use-the-force-luke=break:%@", [layerBreak stringValue]];
	NSArray *args;
	if ([enableLayerBreakButton state] == NSOnState) {
		args = [NSArray arrayWithObjects:cmdPath, @"-dvd-compat", speedArg, layerBreakArg, @"-Z", deviceAndImageArg, nil];
	} else {
		args = [NSArray arrayWithObjects:cmdPath, @"-dvd-compat", speedArg, @"-Z", deviceAndImageArg, nil];
	}
	taskWrapper = [[TaskWrapper alloc] initWithDelegate:self arguments:args];
	[taskWrapper startProcess];
}

#pragma mark --Actions--

- (IBAction)burnerPopup:(id)sender {
	[self updateDevice:[self currentDevice]];
}

- (IBAction)startBurn:(id)sender {
	switch ([methodPopup indexOfSelectedItem]) {
		case 0:
			[self burnImageWithDRFW];
			break;
		case 1:
			[self burnImageWithGrowisofs];
			break;
		default:
			break;
	}
}

- (IBAction)eject:(id)sender {
	[[self currentDevice] ejectMedia];
}

- (IBAction)toggleLayerBreak:(id)sender {
	if ([enableLayerBreakButton state] == NSOnState) {
		[layerBreak setEnabled:YES];
	} else {
		[layerBreak setEnabled:NO];
	}

}

#pragma mark --Notification--

- (void)burnNotification:(NSNotification*)notification {
	NSDictionary *status = [notification userInfo];
	
	NSString *time = @"";
	
	if ([[status objectForKey:DRStatusPercentCompleteKey] floatValue] > 0) {
		if (![[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateTrackOpen]) {
			NSNumber *percent = [NSNumber numberWithFloat:[[status objectForKey:DRStatusPercentCompleteKey] floatValue] * 100];
			[progressPanel setMaximumValue:[NSNumber numberWithFloat:1.0]];
			[progressPanel setValue:[status objectForKey:DRStatusPercentCompleteKey]];
			time = [[[[percent stringValue] componentsSeparatedByString:@"."] objectAtIndex:0]  stringByAppendingString:@"%"];
			time = [[@" (" stringByAppendingString:time] stringByAppendingString:@")"];
		}
	} else {
		[progressPanel setMaximumValue:[NSNumber numberWithFloat:0]];
	}
	
	if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStatePreparing]) {
		[progressPanel setStatus:@"Preparing..."];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateTrackOpen]) {
		if ([[status objectForKey:DRStatusTotalTracksKey] intValue] > 1)
			[progressPanel setStatus:[NSString stringWithFormat:@"Opening track %@", [[status objectForKey:DRStatusCurrentTrackKey] stringValue]]];
		else
			[progressPanel setStatus:@"Opening track"];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateTrackWrite]) {
		if ([[status objectForKey:DRStatusTotalTracksKey] intValue] > 1)
			[progressPanel setStatus:[NSString stringWithFormat:@"Writing track %@ of %@ %@", [[status objectForKey:DRStatusCurrentTrackKey] stringValue], [[status objectForKey:DRStatusTotalTracksKey] stringValue], time]];
		else
			[progressPanel setStatus:[NSString stringWithFormat:@"Writing track %@", time]];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateTrackClose]) {
		if ([[status objectForKey:DRStatusTotalTracksKey] intValue] > 1)
			[progressPanel setStatus:[NSString stringWithFormat:@"Closing track %@ of %@", [[status objectForKey:DRStatusCurrentTrackKey] stringValue], [[status objectForKey:DRStatusTotalTracksKey] stringValue]]];
		else
			[progressPanel setStatus:[NSString stringWithFormat:@"Closing track"]];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateSessionClose]) {
		[progressPanel setStatus:[NSString stringWithFormat:@"Closing session"]];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateFinishing]) {
		[progressPanel setStatus:[NSString stringWithFormat:@"Finishing..."]];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateVerifying]) {
		[progressPanel setStatus:[NSString stringWithFormat:@"Verifying..."]];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateDone]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRBurnStatusChangedNotification object:[notification object]];
		[progressPanel performSelectorOnMainThread:@selector(endSheet) withObject:nil waitUntilDone:YES];
		[progressPanel release];
	} else if ([[status objectForKey:DRStatusStateKey] isEqualTo:DRStatusStateFailed]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[DRNotificationCenter currentRunLoopCenter] removeObserver:self name:DRBurnStatusChangedNotification object:[notification object]];
		
		[progressPanel performSelectorOnMainThread:@selector(endSheet) withObject:nil waitUntilDone:YES];
		[progressPanel release];
		
		NSString *info;
		if ([[status objectForKey:DRErrorStatusKey] objectForKey:DRErrorStatusErrorInfoStringKey])
			info = [[status objectForKey:DRErrorStatusKey] objectForKey:DRErrorStatusErrorInfoStringKey];
		else 
			info = [[status objectForKey:DRErrorStatusKey] objectForKey:DRErrorStatusErrorStringKey];
		
		[NSAlert alertWithMessageText:@"Burn Failed" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:info];
		
	}
}

#pragma mark --TaskWrapperDelegate--

- (void)appendOutput:(NSString *)output {
	printf("[growisofs:\t%s]\n", [output UTF8String]);
	[progressPanel setStatus:[output retain]];
	int i = [output rangeOfString:@"("].location;
	if (i != -1) {
		NSScanner *scanner = [NSScanner scannerWithString:output];
		[scanner setScanLocation:i + 1];
		double value;
		[scanner scanDouble:&value];
		[progressPanel setValue:[NSNumber numberWithDouble:value]];
	}
}

- (void)processStarted {
	progressPanel = [[Progress alloc] init];
	[progressPanel setTask:@"Burning"];
	[progressPanel beginSheetForWindow:window];
	[progressPanel setMaximumValue:[NSNumber numberWithDouble:100]];
}

- (void)processFinished {
	[progressPanel performSelectorOnMainThread:@selector(endSheet) withObject:nil waitUntilDone:YES];
	[[self currentDevice] ejectMedia];
	[progressPanel release];
}

@end
