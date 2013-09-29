//
//  NSAttributedString+Hyperlink.h
//  bateryLifeExtender
//
//  Created by Marcello Seri on 29/09/13.
//  Copyright (c) 2013 MaMi Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Hyperlink)
    +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end
