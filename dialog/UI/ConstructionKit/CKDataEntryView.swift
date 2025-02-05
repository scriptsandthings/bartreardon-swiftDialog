//
//  CKDataEntryView.swift
//  dialog
//
//  Created by Bart Reardon on 29/7/2022.
//

import SwiftUI

struct CKDataEntryView: View {
    
    @ObservedObject var observedData : DialogUpdatableContent
    
    init(observedDialogContent : DialogUpdatableContent) {
        self.observedData = observedDialogContent
    }
    
    var body: some View {
        VStack {
            HStack {
                Toggle("Format output as JSON", isOn: $observedData.args.jsonOutPut.present)
                .toggleStyle(.switch)
                Spacer()
            }
            LabelView(label: "Textfields")
            HStack {
                Button(action: {
                    observedData.appProperties.textFields.append(TextFieldState(title: ""))
                    observedData.args.textField.present = true
                    appArguments.textField.present = true
                }, label: {
                    Image(systemName: "plus")
                })
                Toggle("Show", isOn: $observedData.args.textField.present)
                    .toggleStyle(.switch)
                
                //Button("Clear All") {
                //    observedData.listItemPresent = false
                //    observedData.listItemsArray = [ListItems]()
                //}
                
                Spacer()
            }
            
            ForEach(0..<observedData.appProperties.textFields.count, id: \.self) { item in
                HStack {
                    Button(action: {
                        //observedData.listItemsArray.remove(at: i)
                    }, label: {
                        Image(systemName: "trash")
                    })
                    .disabled(true) // MARK: disabled until I can work out how to delete from the array without causing a crash
                    Toggle("Required", isOn: $observedData.appProperties.textFields[item].required)
                        .onChange(of: observedData.appProperties.textFields[item].required, perform: { _ in
                            observedData.requiredFieldsPresent.toggle()
                        })
                        .toggleStyle(.switch)
                    Toggle("Secure", isOn: $observedData.appProperties.textFields[item].secure)
                        .toggleStyle(.switch)
                    Spacer()
                }
                HStack {
                    TextField("Title", text: $observedData.appProperties.textFields[item].title)
                    TextField("Value", text: $observedData.appProperties.textFields[item].value)
                    TextField("Prompt", text: $observedData.appProperties.textFields[item].prompt)
                }
                .padding(.leading, 20)
                HStack {
                    TextField("Regex", text: $observedData.appProperties.textFields[item].regex)
                    TextField("Regex Error", text: $observedData.appProperties.textFields[item].regexError)
                }
                .padding(.leading, 20)
                Divider()
            }
            LabelView(label: "Select")
            
            LabelView(label: "Checkbox")
            Spacer()
        }
        .padding(20)
    }
}

