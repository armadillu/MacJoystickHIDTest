//
//  JoystickManager.m
//  JoystickHIDTest
//
//  Created by John Stringham on 12-05-01.
//  Copyright 2012 We Get Signal. All rights reserved.
//

#import "JoystickManager.h"

@implementation JoystickManager

@synthesize joystickAddedDelegate;

static JoystickManager *instance;

- (id)init {
    self = [super init];
    
    if (self) {
        joysticks = [[NSMutableDictionary alloc] init];
        joystickIDIndex = 0;
        [self setupGamepads];
    }
    
    return self;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    
    if (!initialized) {
        initialized = YES;
        instance = [[JoystickManager alloc] init];
    }
}

+ (JoystickManager *)sharedInstance {
    return instance;
}

- (unsigned long)connectedJoysticks {
    return [joysticks count];
}

- (int)deviceIDByReference:(IOHIDDeviceRef)deviceRef {
    for (id key in joysticks) {
        Joystick *thisJoystick = [joysticks objectForKey:key];
        
        if ([thisJoystick device] == deviceRef)
            return [((NSNumber *)key) intValue];
    }
    
    return -1;
}

- (Joystick *)joystickByID:(int)joystickID {
    return [joysticks objectForKey:[NSNumber numberWithInt:joystickID]];
}

- (void)registerNewJoystick:(Joystick *)joystick {
    [joysticks setObject:joystick forKey:[NSNumber numberWithInt:joystickIDIndex++]];
    NSLog(@"Gamepad was plugged in");
    NSLog(@"Gamepads registered: %lu", joysticks.count);
    [joystickAddedDelegate joystickAdded:joystick];
}



void gamepadWasRemoved(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    NSLog(@"Gamepad was unplugged");
}

void gamepadAction(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value) {
    
    int joystickID = [[JoystickManager sharedInstance] deviceIDByReference:inSender];
    
    if (joystickID == -1) {
        NSLog(@"Invalid device reported.");
        return;
    }
    
 //   NSLog(@"Device index %d reported",joystickID);
    
    IOHIDElementRef element = IOHIDValueGetElement(value);
    
    Joystick *theJoystick = [[JoystickManager sharedInstance] joystickByID:joystickID];
    
   // NSLog(@"%@",[theJoystick giveButtonOrAxesIndex:element]);
    [theJoystick elementReportedChange:element];
    
}

void gamepadWasAdded(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
	IOHIDDeviceRegisterInputValueCallback(device, gamepadAction, inContext);
    
    Joystick *newJoystick = [[Joystick alloc] initWithDevice:device];
    [[JoystickManager sharedInstance] registerNewJoystick:newJoystick];
    
    [newJoystick release];
}


-(void) setupGamepads {
    hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    NSMutableDictionary* criterion = [[NSMutableDictionary alloc] init];
    [criterion setObject: [NSNumber numberWithInt: kHIDPage_GenericDesktop] forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
    [criterion setObject: [NSNumber numberWithInt: kHIDUsage_GD_GamePad] forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
    
    IOHIDManagerSetDeviceMatching(hidManager, (CFDictionaryRef)criterion);
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, gamepadWasAdded, (void*)self);
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, gamepadWasRemoved, (void*)self);
    IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn tIOReturn = IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
    (void)tIOReturn; // to suppress warnings
    
    [criterion release];
}


@end
