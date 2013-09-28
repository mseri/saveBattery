//
//  AppDelegate.m
//  bateryLifeExtender
//
//  Created by Marcello Seri on 28/09/13.
//  Copyright (c) 2013 MaMi Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib
{
    // Insert code here to initialize your application
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusImage = [NSImage imageNamed:@"leaf.png"];
    statusHighlightedImage = [NSImage imageNamed:@"leafInv.png"];
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightedImage];
    
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Battery Life Expander"];
    [statusItem setHighlightMode:YES];
    
    [self checkStatus];
    
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
}

- (IBAction)configure:(id)sender
{
    
}

- (IBAction)exit:(id)sender
{
    [NSApp terminate:self];
}

- (void) checkStatus {
    
    battery* bInfo = [self getBatteryInfo];
    NSLog(@"%f - %d", bInfo.percent, bInfo.charging);
    
}

- (void) sendNotification:(NSString *)message {
    
}

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
        
        return  bInfo;
    }
    
    for (int i = 0 ; i < numOfSources ; i++)
    {
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource) {
            NSLog(@"Error in IOPSGetPowerSourceDescription");
            
            return bInfo;
        }
        psValue = (CFStringRef) CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));
        
        int curCapacity = 0;
        int maxCapacity = 0;
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSIsChargingKey));
        bInfo.charging = CFBooleanGetValue((CFBooleanRef)psValue);
        
        bInfo.percent = ((double)curCapacity/(double)maxCapacity * 100.0f);
        
        return bInfo;
    }
    
    bInfo.percent = -1.0f;
    
    return bInfo;
}

@end
