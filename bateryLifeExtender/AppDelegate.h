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


#define NOTIFICATIONS 3

#define MAXCHARGE 80
#define MINCHARGE 20

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightedImage;
    
    bool wasCharging;
    bool isCharging;
    
    int notificated;
}

- (IBAction)configure:(id)sender;
- (IBAction)exit:(id)sender;

- (void) checkStatus;
- (void) sendNotification:(NSString *)message;

- (battery *) getBatteryInfo;

@end
