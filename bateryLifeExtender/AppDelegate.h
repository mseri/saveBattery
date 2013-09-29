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

#define MAXCHARGE 80
#define MINCHARGE 20

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightedImage;
    
    int notified;
}

@property (strong) NSWindow* wc;

- (IBAction)info:(id)sender;
- (IBAction)exit:(id)sender;

- (battery *) getBatteryInfo;
- (void)initializePowerSourceChanges;

- (void) checkStatus;
- (void) sendNotification:(NSString *)message;
void PowerSourcesHaveChanged(void *context);
- (void) powerChanged;

- (void) closeInfo:(id)sender;

@end
