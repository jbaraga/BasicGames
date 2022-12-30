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
    
    private let pwd: String = {
        let data = Data([116, 75, 82, 107, 107, 66, 117, 71, 75, 68, 67, 114, 73, 57, 52, 87, 88, 70, 82, 88, 122, 72, 83, 114, 106, 52, 74, 78, 120, 65, 105])
        return String(data: data, encoding: .utf8) ?? ""
    }()
    
    //pdfView must be StateObject to maintain single instance during inits
    @StateObject private var pdfView: PDFView = {
        let pdfView = PDFView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        return pdfView
    }()
    
    @ViewBuilder
    var contentView: some View {
//        let pdfView = self.pdfView
//        GeometryReader { geometry in
//            HSplitView {
//                GeometryReader { leftPaneGeometry in
//                    ThumbnailView(pdfView: pdfView, size: leftPaneGeometry.size)
//                        .frame(maxWidth: geometry.size.width * 0.5)
//                }
//                PDFViewRepresentable(pdfView: pdfView)
//                    .frame(minWidth: geometry.size.width * 0.5)
//            }
//        }
        PDFViewRepresentable(pdfView: pdfView)
        .onAppear {
            document.unlock(withPassword: pwd)
            pdfView.document = document
        }
    }


    var body: some View {
        contentView
            .navigationTitle("Easter Egg")
    }
}


struct EggView_Previews: PreviewProvider {
    static var previews: some View {
        EggView(document: PDFDocument())
    }
}


extension PDFView: ObservableObject {}
