//
//  EggView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/26/22.
//

import SwiftUI
import PDFKit


struct EggView: View {
    let document: PDFDocument
    
    @FocusState private var isFocused: Bool
    
    //pdfView must be StateObject to maintain single instance during inits
    @StateObject private var pdfView: PDFView = {
        let pdfView = PDFView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        return pdfView
    }()
    
    private var contentView: some View {
        PDFViewRepresentable(pdfView: pdfView)
            .onAppear {
                document.unlock(withPassword: PDFDocument.pwd)
                pdfView.document = document
                pdfView.scrollToBeginningOfDocument(nil)
                pdfView.scrollPageDown(nil)
                isFocused = true
            }
    }


    var body: some View {
        contentView
    }
}


struct EggView_Previews: PreviewProvider {
    static var previews: some View {
        EggView(document: PDFDocument())
    }
}


extension PDFView: @retroactive ObservableObject {}
