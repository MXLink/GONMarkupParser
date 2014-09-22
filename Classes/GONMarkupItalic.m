//
//  GONMarkupItalic.m
//  GONMarkupParserSample
//
//  Created by Nicolas Goutaland on 19/09/14.
//  Copyright (c) 2014 Nicolas Goutaland. All rights reserved.
//

#import "GONMarkupItalic.h"
#import "GONMarkup+Private.h"

@implementation GONMarkupItalic
#pragma mark - Constructor
+ (instancetype)italicMarkup
{
    return [self markupForTag:GONMarkupItalic_TAG];
}

#pragma mark - Style
- (void)openingMarkupFound:(NSString *)aTag configuration:(NSMutableDictionary *)aConfigurationDictionary context:(NSMutableDictionary *)aContext
{
    // Look for current font
    UIFont *currentFont = [aConfigurationDictionary objectForKey:NSFontAttributeName];
    if (!currentFont)
    {
        // No found defined, use default one with default size
        currentFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    
    // Update font to set trait
    UIFontDescriptor *fontDescriptor = currentFont.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    
    // Check if font is already italic
    UIFont *italicFont = currentFont;
    if (!(traits & UIFontDescriptorTraitItalic))
    {
        traits |= UIFontDescriptorTraitItalic;
        currentFont = [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:traits]
                                            size:currentFont.pointSize];

        // Font may not exists, fallback.
        // Note : In iOS7, if no fount is found, normal one will be returned. Since iOS8, nil will be returned
        if (!italicFont || [currentFont isEqual:italicFont])
        {
            // If a fallback block was defined, try it
            if (_italicFontFallbackBlock)
                italicFont = (_italicFontFallbackBlock(currentFont));
            
            // If no font after block, use default system one
            if (!italicFont)
            {
                if (self.parser.debugEnabled)
                {
                    if (!_italicFontFallbackBlock)
                        NSLog(@"%@ : No italic font found for <%@-%@>. Consider setting up <italicFontFallbackBlock> to provide a fallback font", [[self class] description], currentFont.familyName, currentFont.fontName);
                    else
                        NSLog(@"%@ : No italic font returned from fallback block for <%@-%@>. Consider seting up one", [[self class] description], currentFont.familyName, currentFont.fontName);
                }

                italicFont = [UIFont italicSystemFontOfSize:currentFont.pointSize];
            }
        }
    }

    // Update configuration
    [aConfigurationDictionary setObject:italicFont
                                 forKey:NSFontAttributeName];
}
@end
