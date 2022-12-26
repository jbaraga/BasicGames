//
//  PDFViewRepresentable.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/26/22.
//

import Foundation
import SwiftUI
import PDFKit


struct PDFViewRepresentable: NSViewRepresentable {
    typealias NSViewType = PDFView
    let pdfView: PDFView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> PDFView {
        pdfView.delegate = context.coordinator
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        return
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        var parent: PDFViewRepresentable
        
        init(_ parent: PDFViewRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}


struct ThumbnailView: NSViewRepresentable {
    typealias NSViewType = PDFThumbnailView
    let pdfView: PDFView
    let size: CGSize
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> PDFThumbnailView {
        let thumbnailView = PDFThumbnailView()
        let width = size.width > 0 ? size.width * 0.8 : 128
        thumbnailView.thumbnailSize = CGSize(width: width, height: width)
        thumbnailView.pdfView = pdfView
        return thumbnailView
    }
    
    func updateNSView(_ nsView: PDFThumbnailView, context: Context) {
        let width = size.width * 0.8
        var aspectRatio: CGFloat = 1
        if let page = pdfView.currentPage {
            let size = page.bounds(for: .mediaBox).size
            aspectRatio = size.height / size.width
        }
        nsView.thumbnailSize = CGSize(width: width, height: width * aspectRatio)
    }
    
    class Coordinator {
        var parent: ThumbnailView
        
        init(_ parent: ThumbnailView) {
            self.parent = parent
        }
    }
}
