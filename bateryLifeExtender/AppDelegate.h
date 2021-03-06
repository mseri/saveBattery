//
//  AppDelegate.h
//  bateryLifeExtender
//
//  Created by Marcello Seri on 28/09/13.
//  Copyright (c) 2013 MaMi Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>

#import "battery.h"
#import "NSAttributedString+Hyperlink.h"

#define NOTIFICATIONS 3

#define MAXCHARGE 80.0f
#define MINCHARGE 20.0f

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    //NSImage *statusHighlightedImage;
    
    bool wasCharging;
    int notified;
}

@property (strong, retain) NSWindow* wc;
@property (strong) NSTimer *batteryLoop;

- (void) generateInfoWindow;

- (IBAction)info:(id)sender;
- (IBAction)exit:(id)sender;
- (void) closeInfo:(id)sender;

- (battery *) getBatteryInfo;
- (void)initializePowerSourceChanges;

- (void) checkStatus;
- (void) sendNotification:(NSString *)message;
void PowerSourcesHaveChanged(void *context);
- (void) powerChanged;

- (void) fileNotifications;
- (void) receiveSleepNote:(NSNotification*) note;
- (void) receiveWakeNote:(NSNotification*) note;

@end
