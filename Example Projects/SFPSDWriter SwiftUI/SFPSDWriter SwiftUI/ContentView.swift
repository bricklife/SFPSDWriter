//
//  ContentView.swift
//  SFPSDWriter SwiftUI
//
//  Created by Shinichiro Oba on 2023/01/17.
//

import SwiftUI
import SFPSDWriter

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .task {
            // The images we want to insert in the PSD
            let firstImage = loadCGImage(named: "firstImage")!
            let secondImage = loadCGImage(named: "secondImage")!
            
            // SFPSDWriter instance
            let psdWriter = SFPSDWriter(documentSize: CGSize(width: firstImage.width, height: firstImage.height),
                                        resolution: 300,
                                        resolutionUnit: .ppi)
            
            // We want all our layers to be included in a group...
            let firstGroup = psdWriter.openGroupLayer(name: "We ♥ groups!")
            
            // ... and the group should be open at file opening
            firstGroup.isOpened = true
            
            // Adding the first image layer
            psdWriter.addLayer(cgImage: firstImage,
                               name: "First Layer",
                               opacity: 1,
                               offset: .zero)
            
            // I mean, we really love groups
            // This time we don't need to change group's attributes so we don't store the reference
            psdWriter.openGroupLayer(name: "You'll have to open me!")
            
            // The second image will be in the second group, offsetted by (116px, 66px), semi-transparent...
            let secondLayer = psdWriter.addLayer(cgImage: secondImage,
                                                 name: "Second Layer",
                                                 opacity: 0.5,
                                                 offset: .init(x: 116, y: 66))
            
            // ... and with "Darken" blend mode
            secondLayer.blendMode = SFPSDLayerBlendModeDarken
            
            // We'll prepare the Drop Shadow Effect Layer information
            let dropShadowInformation = SFPSDDropShadowEffectLayerInformation()
            dropShadowInformation.enabled = true
            dropShadowInformation.size = 100
            dropShadowInformation.angle = 90
            dropShadowInformation.distance = 5
            //dropShadowInformation.color = CGColor(red: 1, green: 0, blue: 0, alpha: 0)
            dropShadowInformation.blendMode = SFPSDLayerBlendModeNormal
            dropShadowInformation.useGlobalLight = false
            dropShadowInformation.opacity = 100
            
            // We'll set the Drop Sahdow on the second layer (we can add it to the SFPSDGroupOpeningLayer too)
            secondLayer.dropShadowEffectLayerInformation = dropShadowInformation
            
            // Other available Effect Layers are:
            // - Inner Shadow (SFPSDInnerShadowEffectLayerInformation)
            // - Outer Glow (SFPSDOuterGlowEffectLayerInformation)
            // - Inner Glow (SFPSDInnerGlowEffectLayerInformation)
            // - Bevel (SFPSDBevelEffectLayerInformation)
            // - Solid Fill (SFPSDSolidFillEffectLayerInformation)
            
            // We have to close every group we've opened
            psdWriter.closeCurrentGroupLayer() // second group
            psdWriter.closeCurrentGroupLayer() // first group
            
            // We can change the embedded color profile of the document (for example with an "sRGB IEC61966-2.1")
            psdWriter.colorProfile = .sRGB
            
            // We'll write our test file into the documents folder of the application
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = urls[0]
            let fileUrl = documentsDirectory.appendingPathComponent("SFPSDWriter Test File.psd")
            
            do {
                // Retrieving the PSD data
                let psdData = try psdWriter.createPSDData()
                
                // Writing the data on disk
                try psdData.write(to: fileUrl)
                
                print(fileUrl.path)
            } catch {
                print(error)
            }
        }
    }
}

#if canImport(UIKit)
func loadCGImage(named: String) -> CGImage? {
    return UIImage(named: named)?.cgImage
}
#elseif canImport(AppKit)
func loadCGImage(named: String) -> CGImage? {
    return NSImage(named: named)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
}
#endif
