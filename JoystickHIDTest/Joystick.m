//
//  Joystick.m
//  JoystickHIDTest
//
//  Created by John Stringham on 12-05-01.
//  Copyright 2012 We Get Signal. All rights reserved.
//

#import "Joystick.h"

@implementation Joystick

@synthesize device;

- (id)initWithDevice:(IOHIDDeviceRef)theDevice
{
    self = [super init];
    if (self) {
        device = theDevice;
        
        delegates = [[NSMutableArray alloc] initWithCapacity:0];
        
        elements = (NSArray *)IOHIDDeviceCopyMatchingElements(theDevice, NULL, kIOHIDOptionsTypeNone);
        
        NSMutableArray *tempButtons = [NSMutableArray array];
        NSMutableArray *tempAxes = [NSMutableArray array];
        
        int i;
        for (i=0; i<elements.count; ++i) {
            IOHIDElementRef thisElement = (IOHIDElementRef)[elements objectAtIndex:i];
            
            int elementType = IOHIDElementGetType(thisElement);
            
            if (elementType == kIOHIDElementTypeInput_Axis || elementType == kIOHIDElementTypeInput_Misc) {
                [tempAxes addObject:thisElement];
            } else {
                [tempButtons addObject:thisElement];
            }
        }
        buttons = [[NSArray arrayWithArray:tempButtons] retain];
        axes = [[NSArray arrayWithArray:tempAxes] retain];
        
        NSLog(@"New device address: %p from %p",device,theDevice);
        NSLog(@"found %lu buttons and %lu axes",tempButtons.count,tempAxes.count);
        // For more detailed info there are Usage tables
        // eg: kHIDUsage_GD_X
        // declared in IOHIDUsageTables.h
        // could use to determine major axes
    }
    
    return self;
}

- (void)elementReportedChange:(IOHIDElementRef)theElement {
    
    int elementType = IOHIDElementGetType(theElement);
    IOHIDValueRef pValue;
    IOHIDDeviceGetValue(device, theElement, &pValue);
    
    int elementUsage = IOHIDElementGetUsage(theElement);
    
    if (elementUsage == kHIDUsage_GD_Hatswitch) {
        int hatpositions = IOHIDElementGetLogicalMax(theElement);
        NSLog(@"THIS IS A HAT WITH %d DIRECTIONS",hatpositions);
    }
    
    int value = IOHIDValueGetIntegerValue(pValue);
    int i;
    
    if (elementType != kIOHIDElementTypeInput_Axis && elementType != kIOHIDElementTypeInput_Misc) {
        
        
        for (i=0; i<delegates.count; ++i) {
            id <JoystickNotificationDelegate> delegate = [delegates objectAtIndex:i];
            
            if (value==1)
                [delegate joystickButtonPushed:[self getButtonOrAxesIndex:theElement]];
            else
                [delegate joystickButtonReleased:[self getButtonOrAxesIndex:theElement]];
                 
        }
        
        NSLog(@"Non-axis reported value of %d",value);
        return;
    }
    
    
    
    NSLog(@"Axis reported value of %d",value);
    
    for (i=0; i<delegates.count; ++i) {
        id <JoystickNotificationDelegate> delegate = [delegates objectAtIndex:i];
        
        [delegate joystickStateChanged:self];
    }
}

- (void)registerForNotications:(id <JoystickNotificationDelegate>)delegate {
    [delegates addObject:delegate];
}

- (void)deregister:(id<JoystickNotificationDelegate>)delegate {
    [delegates removeObject:delegate];
}

- (int)getButtonOrAxesIndex:(IOHIDElementRef)theElement {
    int elementType = IOHIDElementGetType(theElement);
    
    NSArray *searchArray;
    NSString *returnString = @"";
    
    if (elementType == kIOHIDElementTypeInput_Button) {
        searchArray = buttons;
        returnString = @"Button";
    } else {
        searchArray = axes;
        returnString = @"Axis";
    }
    
    int i;
    
    for (i=0; i<searchArray.count; ++i) {
        if ([searchArray objectAtIndex:i] == theElement)
            return i;
            //  returnString = [NSString stringWithFormat:@"%@_%d",returnString,i];
    }
    
    return -1;
}

- (double)getRelativeValueOfAxesIndex:(int)index {
    IOHIDElementRef theElement = [axes objectAtIndex:index];
    
    double value;
    double min = IOHIDElementGetPhysicalMin(theElement);
    double max = IOHIDElementGetPhysicalMax(theElement);
    
    IOHIDValueRef pValue;
    IOHIDDeviceGetValue(device, theElement, &pValue);
    
    value = ((double)IOHIDValueGetIntegerValue(pValue)-min) * (1/(max-min));
    
    return value;
}

- (unsigned int)numButtons {
    return (unsigned int)[buttons count];
}

- (unsigned int)numAxes {
    return (unsigned int)[axes count];
}

- (void)dealloc
{
    [super dealloc];
}

@end
