//
//  Joystick.h
//  JoystickHIDTest
//
//  Created by John Stringham on 12-05-01.
//  Copyright 2012 We Get Signal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "JoystickNotificationDelegate.h"

@interface Joystick : NSObject {
    IOHIDDeviceRef  device;
    
    
@private
    NSArray  *elements;
    
    NSArray *axes;
    NSArray *buttons;
    
    NSMutableArray *delegates;
}

@property(readwrite) IOHIDDeviceRef device;

@property(readonly) unsigned int numButtons;
@property(readonly) unsigned int numAxes;

- (id)initWithDevice:(IOHIDDeviceRef)theDevice;
- (int)getButtonOrAxesIndex:(IOHIDElementRef)theElement;

- (double)getRelativeValueOfAxesIndex:(int)index;

- (void)elementReportedChange:(IOHIDElementRef)theElement;
- (void)registerForNotications:(id <JoystickNotificationDelegate>)delegate;
- (void)deregister:(id<JoystickNotificationDelegate>)delegate;

@end
