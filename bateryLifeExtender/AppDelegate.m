//
//  AppDelegate.m
//  bateryLifeExtender
//
//  Created by Marcello Seri on 28/09/13.
//  Copyright (c) 2013 MaMi Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize wc;
@synthesize batteryLoop;

- (void)awakeFromNib
{
    // Insert code here to initialize your application
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusImage = [NSImage imageNamed:@"leaf.png"];
    //statusHighlightedImage = [NSImage imageNamed:@"leafInv.png"];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusImage];
    
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Battery Life Expander"];
    [statusItem setHighlightMode:YES];
    
    battery* bInfo = [self getBatteryInfo];
    wasCharging = bInfo.charging;
    
    [self generateInfoWindow];
    
    [self initializePowerSourceChanges];
    notified = 0;
    
    //NSLog(@"Power start log: %d", notified);
    [self checkStatus];
    
    self.batteryLoop = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
}

- (void) generateInfoWindow {
    
    NSRect frame = NSMakeRect(0, 0, 480, 150);
    self.wc  = [[NSWindow alloc] initWithContentRect:frame
                                           styleMask:NSTitledWindowMask|NSClosableWindowMask
                                             backing:NSBackingStoreBuffered
                                               defer:NO];
    NSWindow* infoWindow = self.wc;
    CGFloat xPos = NSWidth([[infoWindow screen] frame])/2 - NSWidth([infoWindow frame])/2;
    CGFloat yPos = NSHeight([[infoWindow screen] frame])/2 - NSHeight([infoWindow frame])/2;
    [infoWindow setFrame:NSMakeRect(xPos, yPos, NSWidth([infoWindow frame]), NSHeight([infoWindow frame])) display:YES];
    
    infoWindow.title=@"Save Your Battery!";
    
    NSTextView* infoText = [[NSTextView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(20, 46, 440, 80))];
    
    [infoText setTextColor:[NSColor blackColor]];
    [infoText setDrawsBackground:NO];
    [infoText setEditable:NO];
    [infoText setSelectable: YES];
    [infoText alignCenter:nil];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:@"This applet helps to save your battery life informing you to plug and unplug your battery when the charge is appropriate (see "];
    NSURL* url = [NSURL URLWithString: @"http://ow.ly/pjzSK"];
    [string appendAttributedString:[NSAttributedString hyperlinkFromString:@"http://ow.ly/pjzSK" withURL:url]];
    [string appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" for additional info)"]];
    
    [[infoText textStorage] setAttributedString:string];
    
    [infoText setFont:[NSFont fontWithName:@"Helvetica Light" size:16.0]];
    
    NSFontManager * fontManager = [NSFontManager sharedFontManager];
    NSTextStorage * textStorage = [infoText textStorage];
    [textStorage beginEditing];
    [textStorage enumerateAttribute:NSFontAttributeName
                            inRange:NSMakeRange(0, [textStorage length])
                            options:0
                         usingBlock:^(id value,
                                      NSRange range,
                                      BOOL * stop)
     {
         NSFont * font = value;
         font = [fontManager convertFont:font
                                  toSize:16.0];
         if (font != nil) {
             [textStorage removeAttribute:NSFontAttributeName
                                    range:range];
             [textStorage addAttribute:NSFontAttributeName
                                 value:font
                                 range:range];
         }
     }];
    [textStorage endEditing];
    
    [infoWindow.contentView addSubview:infoText];
    
    NSButton* closeButton = [[NSButton alloc] initWithFrame:NSRectFromCGRect(CGRectMake(199, 13, 78, 32))];
    closeButton.title = @"Done!";
    [closeButton setButtonType:NSMomentaryPushInButton];
    [closeButton setBezelStyle:NSRoundedBezelStyle];
    [closeButton setTarget:self];
    [closeButton setAction:@selector(closeInfo:)];
    
    [infoWindow.contentView addSubview:closeButton];
}

# pragma mark IBActions

- (IBAction)info:(id)sender
{
    //NSLog(@"%@", self.wc);
    if (!self.wc) {
        [self generateInfoWindow];
    }
    [self.wc makeKeyAndOrderFront:NSApp];
}

- (IBAction)exit:(id)sender
{
    [NSApp terminate:self];
}

-(void) closeInfo:(id)sender {
    [self.wc orderOut:NSApp];
}

#pragma mark Access Battery Info

-(battery*) getBatteryInfo {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    
    CFDictionaryRef pSource = NULL;
    const void *psValue;
    
    battery* bInfo = [[battery alloc] init];
    bInfo.percent = -1.0f;
    bInfo.charging = TRUE;
    
    long numOfSources = CFArrayGetCount(sources);
    if (numOfSources == 0) {
        NSLog(@"Error in CFArrayGetCount");
        
        //CFRelease(pSource);
        CFRelease(sources);
        CFRelease(blob);
        return  bInfo;
    }
    
    for (int i = 0 ; i < numOfSources ; i++)
    {
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource) {
            NSLog(@"Error in IOPSGetPowerSourceDescription");
            
            //CFRelease(pSource);
            CFRelease(sources);
            CFRelease(blob);
            return bInfo;
        }
        
        int curCapacity = 0;
        int maxCapacity = 0;
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
        
        bInfo.percent = ((double)curCapacity/(double)maxCapacity * 100.0f);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSPowerSourceStateKey));
        if(CFEqual(psValue, CFSTR(kIOPSACPowerValue)))
        {
            bInfo.charging = YES;
            //NSLog(@"Corrente");
        }
        else if(CFEqual(psValue, CFSTR(kIOPSBatteryPowerValue)))
        {
            bInfo.charging = NO;
            //NSLog(@"Batteria");
        }
        else
        {
            NSLog(@"%s", psValue);
            bInfo.percent = -1.0f;
        }
        
        //CFRelease(pSource);
        CFRelease(sources);
        CFRelease(blob);
        
        return bInfo;
    }
    
    //CFRelease(pSource);
    CFRelease(sources);
    CFRelease(blob);

    return bInfo;
}

-(void)initializePowerSourceChanges
{
    CFRunLoopSourceRef CFrls;
    
    // Create and add RunLoopSource
    // Here I pass my context instead of NULL!
    CFrls =
    IOPSNotificationCreateRunLoopSource(PowerSourcesHaveChanged, (__bridge void
                                                                  *)self);
    if(CFrls) {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), CFrls,
                           kCFRunLoopDefaultMode);
        CFRelease(CFrls);
    }
}

#pragma mark Actions On Power Events

- (void) checkStatus {
    
    battery* bInfo = [self getBatteryInfo];
    //NSLog(@"%f - %d", bInfo.percent, bInfo.charging);
    
    if (notified < NOTIFICATIONS && bInfo.charging && bInfo.percent >= MAXCHARGE) {
        notified++;
        [self sendNotification:@"The battery charge is higher than 80%, you should now unplug it."];
        statusImage = [NSImage imageNamed:@"leafRed.png"];
    } else if (notified < NOTIFICATIONS && !bInfo.charging && bInfo.percent <= MINCHARGE) {
        notified++;
        [self sendNotification:@"The battery charge is lower than 20%, you should now plug it."];
        statusImage = [NSImage imageNamed:@"leafRed.png"];
    } else if (bInfo.percent <= -1.0f) {
        [self sendNotification:@"Something is wrong with your battery. Check it as soon as possible."];
        statusImage = [NSImage imageNamed:@"leafQuestion.png"];
    } else {
        statusImage = [NSImage imageNamed:@"leaf.png"];
    }
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusImage];

    //NSLog(@"After check log: %d", notified);
}

- (void) sendNotification:(NSString *)message {
    //NSLog(@"notification");
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Save you battery life!";
    notification.informativeText = message;
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

void PowerSourcesHaveChanged(void *context) {
    id callbackObject = (__bridge id) context;
    [callbackObject powerChanged];
}

-(void) powerChanged {
    battery* bInfo = [self getBatteryInfo];
    
    // Make a check only if the charging status changed.
    if (wasCharging != bInfo.charging) {
        wasCharging = bInfo.charging;
        notified = 0;
        [self checkStatus];
    }
}

#pragma mark Notification Delegate Methods
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark Manage Sleep

- (void) receiveSleepNote: (NSNotification*) note
{
    //NSLog(@"receiveSleepNote: %@", [note name]);
    [self.batteryLoop invalidate];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    //NSLog(@"receiveSleepNote: %@", [note name]);
    self.batteryLoop = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
}

- (void) fileNotifications
{
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

@end
