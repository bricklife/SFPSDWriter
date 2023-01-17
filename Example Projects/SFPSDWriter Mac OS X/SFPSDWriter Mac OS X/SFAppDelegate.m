//
//  SFAppDelegate.m
//  SFPSDWriter Mac OS X
//
//  Created by Konstantin Erokhin on 12/06/13.
//  Copyright (c) 2013 Shiny Frog. All rights reserved.
//

#import "SFAppDelegate.h"

#import <SFPSDWriter/SFPSDWriter.h>

@implementation SFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // The images we want to insert in the PSD
    NSImage *firstImage = [NSImage imageNamed:@"firstImage"];
    NSImage *secondImage = [NSImage imageNamed:@"secondImage"];
    
    // SFPSDWriter instance
    SFPSDWriter *psdWriter = [[SFPSDWriter alloc] initWithDocumentSize:NSSizeToCGSize(firstImage.size) andResolution:300.0 andResolutionUnit:SFPSDResolutionUnitPPI];
    
    // We want all our layers to be included in a group...
    SFPSDGroupOpeningLayer *firstGroup = [psdWriter openGroupLayerWithName:@"We ♥ groups!"];
    
    // ... and the group should be open at file opening
    [firstGroup setIsOpened:YES];
    
    // Adding the first image layer
    [psdWriter addLayerWithCGImage:[firstImage CGImageForProposedRect:NULL context:NULL hints:NULL]
                           andName:@"First Layer"
                        andOpacity:1
                         andOffset:NSMakePoint(0, 0)];
    
    // I mean, we really love groups
    // This time we don't need to change group's attributes so we don't store the reference
    [psdWriter openGroupLayerWithName:@"You'll have to open me!"];
    
    // The second image will be in the second group, offsetted by (116px, 66px), semi-transparent...
    SFPSDLayer *secondLayer = [psdWriter addLayerWithCGImage:[secondImage CGImageForProposedRect:NULL context:NULL hints:NULL]
                                                     andName:@"Second Layer"
                                                  andOpacity:0.5
                                                   andOffset:NSMakePoint(116, 66)];
    
    // ... and with "Darken" blend mode
    [secondLayer setBlendMode:SFPSDLayerBlendModeDarken];

    // We'll prepare the Drop Shadow Effect Layer information
    SFPSDDropShadowEffectLayerInformation *dropShadowInformation = [[SFPSDDropShadowEffectLayerInformation alloc] init];
    dropShadowInformation.enabled = YES;
    dropShadowInformation.size = 100;
    dropShadowInformation.angle = 90;
    dropShadowInformation.distance = 5;
    dropShadowInformation.color = [[NSColor redColor] CGColor];
    dropShadowInformation.blendMode = SFPSDLayerBlendModeNormal;
    dropShadowInformation.useGlobalLight = NO;
    dropShadowInformation.opacity = 100;

    // We'll set the Drop Sahdow on the second layer (we can add it to the SFPSDGroupOpeningLayer too)
    [secondLayer setDropShadowEffectLayerInformation:dropShadowInformation];

    // Other available Effect Layers are:
    // - Inner Shadow (SFPSDInnerShadowEffectLayerInformation)
    // - Outer Glow (SFPSDOuterGlowEffectLayerInformation)
    // - Inner Glow (SFPSDInnerGlowEffectLayerInformation)
    // - Bevel (SFPSDBevelEffectLayerInformation)
    // - Solid Fill (SFPSDSolidFillEffectLayerInformation)

    // We have to close every group we've opened
    [psdWriter closeCurrentGroupLayer]; // second group
    [psdWriter closeCurrentGroupLayer]; // first group

    // We can change the embedded color profile of the document (for example with an "sRGB IEC61966-2.1")
    [psdWriter setColorProfile:SFPSDSRGBColorProfile];

    // We'll write our test file to the Desktop
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString *fullFilePath = [basePath stringByAppendingPathComponent:@"SFPSDWriter Test File.psd"];
    
    // Retrieving the PSD data
    NSError *error = nil;
    NSData *psd = [psdWriter createPSDDataWithError:&error];
    
    // Checking for errors
    if (nil != error) {
        NSLog(@"There was an error writing the PSD: %@", [error description]);
        return;
    }
    
    // Writing the data on disk
    [psd writeToFile:fullFilePath atomically:NO];
    
    // Opening the newly created file! :)
    [[NSWorkspace sharedWorkspace] openFile:fullFilePath];
}

@end
