//
//  ErrorView.swift
//  dialog
//
//  Created by Bart Reardon on 29/5/2022.
//

import SwiftUI

struct ErrorView: View {
    
    //@Binding var showingSheet : Bool
    @ObservedObject var observedData : DialogUpdatableContent
    //var sheetMessage : String
    
    init(observedContent : DialogUpdatableContent) {
        //sheetMessage = text
        self.observedData = observedContent
        //self._showingSheet = sheet
    }
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "triangle.fill")
                    .resizable()
                    .foregroundColor(.white)
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .foregroundColor(.yellow)
            }
            .frame(width: 64, height: 64)
            .padding(observedData.appProperties.sidePadding)
            Text("invalid-input").bold()
                .padding()
            Text(observedData.sheetErrorMessage)
                .padding(.leading, observedData.appProperties.sidePadding)
                .padding(.trailing, observedData.appProperties.sidePadding)
            Spacer()
            Button(action: {
                observedData.showSheet = false
                observedData.sheetErrorMessage = ""
            }) {
                Text("button-ok".localized)
            }
            .padding(observedData.appProperties.sidePadding)
        }
        .frame(width: 400, height: 350)
    }
}

