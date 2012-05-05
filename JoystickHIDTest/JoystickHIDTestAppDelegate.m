//
//  JoystickHIDTestAppDelegate.m
//  JoystickHIDTest
//
//  Created by John Stringham on 12-04-30.
//  Copyright 2012 We Get Signal. All rights reserved.
//

#import "JoystickHIDTestAppDelegate.h"
#import "JoystickManager.h"
#import "Joystick.h"

@implementation JoystickHIDTestAppDelegate

@synthesize window, horizontalSlider, verticalSlider, buttonMatrix;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSLog(@"yay");
    
    JoystickManager *theJoystickManager = [JoystickManager sharedInstance];

    [theJoystickManager setJoystickAddedDelegate:self];
}

- (void)joystickAdded:(Joystick *)joystick {
    [joystick registerForNotications:self];
    NSLog(@"added %@", joystick);
}

- (void)joystickStateChanged:(Joystick *)joystick {
    double value = [joystick getRelativeValueOfAxesIndex:0];
    
    value *= 100.0;
    
    [horizontalSlider setDoubleValue:value];
    
    
    value = [joystick getRelativeValueOfAxesIndex:1]*100.0;
    
    [verticalSlider setDoubleValue:value];
}

- (void) joystickButtonPushed:(int)buttonIndex onJoystick:(Joystick *)joystick {
    if (buttonIndex >= [[buttonMatrix cells] count])
        return;
    
    NSButtonCell *buttonPushed = [[buttonMatrix cells] objectAtIndex:buttonIndex];
    
    [buttonPushed setState:NSOnState];
}

- (void) joystickButtonReleased:(int)buttonIndex onJoystick:(Joystick *)joystick {
    NSButtonCell *buttonPushed = [[buttonMatrix cells] objectAtIndex:buttonIndex];
    
    [buttonPushed setState:NSOffState];
}

@end