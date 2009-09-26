//
//  DropImageView.m
//  X360Burn
//
//  Created by 赵 栓 on 09-9-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DropImageView.h"


@implementation DropImageView

@synthesize dropText;
@synthesize fileName;
@synthesize fileSize;
@synthesize fileType;
@synthesize filePath;

- (id)initWithFrame:(NSRect)frameRect{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect{
	[super drawRect:dirtyRect];
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	[context restoreGraphicsState];
}

- (void)dealloc{
	[dropText release];
	[fileName release];
	[fileSize release];
	[fileType release];
	[filePath release];
	[self unregisterDraggedTypes];
	[super dealloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric){
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    }
    else{
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
    NSPasteboard *paste = [sender draggingPasteboard];
	//gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObject:NSFilenamesPboardType];
	//a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
	
    if (nil == carriedData){
        //the operation failed for some reason
        return NO;
    }
    else{
        if ([desiredType isEqualToString:NSFilenamesPboardType]){
            //we have a list of file names in an NSData object
            NSArray *fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];
			
			//be caseful since this method returns id.  
			//We just happen to know that it will be an array.
            NSString *path = [fileArray objectAtIndex:0];
			if([[path pathExtension] caseInsensitiveCompare:@"iso"] != NSOrderedSame
			   && [[path pathExtension] caseInsensitiveCompare:@"dmg"] != NSOrderedSame){
				return NO;
			}
			filePath = [path retain];
			NSArray *array = [filePath componentsSeparatedByString:@"/"];
			NSString *nameStr = [NSString stringWithFormat:@"File Name:\t%@", (NSString *)[array objectAtIndex:[array count]-1]];
			[fileName setStringValue:nameStr];
			unsigned long size = [self getImageSizeAtPath:filePath];
			NSString *sizeStr = [NSString stringWithFormat:@"File Size:\t\t%1.2f G", ((float)size)/(1024*1024*1024)];
			[fileSize setStringValue:sizeStr];
			NSString *typeStr = [NSString stringWithFormat:@"File Type:\t%@",[[filePath pathExtension] lowercaseString]];
			[fileType setStringValue:typeStr];
			
			NSImage *Icon = [[NSWorkspace sharedWorkspace] iconForFileType:[filePath pathExtension]];
			[self setImage:Icon];
			[dropText setHidden:YES];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FileSelected" object:nil];
        }
        else{
            return NO;
        }
    }
    return YES;
}

- (unsigned long)getImageSizeAtPath:(NSString *)path{
	if ([[path pathExtension] isEqualTo:@"cue"]) {
		return (unsigned long)[[[[NSFileManager defaultManager] attributesOfItemAtPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"bin"] error:NULL] objectForKey:NSFileSize] floatValue];
	} else {
		return (unsigned long)[[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] floatValue];
	}
}

@end
