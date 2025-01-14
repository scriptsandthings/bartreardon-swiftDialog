//
//  CKBasicsView.swift
//  dialog
//
//  Created by Bart Reardon on 29/7/2022.
//

import SwiftUI

struct CKBasicsView: View {
    
    @ObservedObject var observedData : DialogUpdatableContent
    
    let alignmentArray = ["left", "centre", "right"]
    
    init(observedDialogContent : DialogUpdatableContent) {
        self.observedData = observedDialogContent
    }
    
    var body: some View {
        
        VStack {
            LabelView(label: "Title")
            HStack {
                TextField("", text: $observedData.args.titleOption.value)
                ColorPicker("Colour",selection: $observedData.appProperties.titleFontColour)
                Button("Reset") {
                    observedData.appProperties.titleFontColour = .primary
                }
            }
            HStack {
                Text("Font Size: ")
                Slider(value: $observedData.appProperties.titleFontSize, in: 10...80)
                TextField("value:", value: $observedData.appProperties.titleFontSize, formatter: NumberFormatter())
                    .frame(width: 50)
            }
            
            LabelView(label: "Message")
            HStack {
                Picker("Text Alignment", selection: $observedData.args.messageAlignment.value)
                {
                    Text("").tag("")
                    ForEach(observedData.appProperties.allignmentStates.keys.sorted(), id: \.self) {
                        Text($0)
                    }
                }
                .onChange(of: observedData.args.messageAlignment.value) {
                    observedData.appProperties.messageAlignment = observedData.appProperties.allignmentStates[$0] ?? .leading
                    observedData.args.messageAlignment.present = true
                }
                Toggle("Vertical Position", isOn: $observedData.args.messageVerticalAlignment.present)
                    .toggleStyle(.switch)
                ColorPicker("Colour",selection: $observedData.appProperties.messageFontColour)
                Button("Reset") {
                    observedData.appProperties.messageFontColour = .primary
                }
            }
            TextEditor(text: $observedData.args.messageOption.value)
                .frame(minHeight: 50)
                .background(Color("editorBackgroundColour"))
        }
        .padding(20)

    }
}

