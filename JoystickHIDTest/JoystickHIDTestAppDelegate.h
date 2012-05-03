//
//  JoystickHIDTestAppDelegate.h
//  JoystickHIDTest
//
//  Created by John Stringham on 12-04-30.
//  Copyright 2012 We Get Signal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JoystickNotificationDelegate.h"

@interface JoystickHIDTestAppDelegate : NSObject <NSApplicationDelegate, JoystickNotificationDelegate> {
@private
    NSWindow *window;
    
    NSSlider *horizontalSlider;
    NSSlider *verticalSlider;
    
    NSMatrix *buttonMatrix;
}

@property (assign) IBOutlet NSSlider *horizontalSlider;
@property (assign) IBOutlet NSSlider *verticalSlider;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMatrix *buttonMatrix;

- (void)joystickStateChanged:(Joystick *)joystick;
- (void)joystickButtonPushed:(int)buttonIndex;
- (void)joystickButtonReleased:(int)buttonIndex;

@end
