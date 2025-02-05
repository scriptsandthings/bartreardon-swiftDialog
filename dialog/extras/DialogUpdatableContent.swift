//
//  TrackProgress.swift
//  file watch test
//
//  Created by Bart Reardon on 13/1/2022.
//
// concept and execution apropriated from depNotify

import Foundation
import SwiftUI

enum StatusState {
    case start
    case done
}

class FileReader {
    /// Provided by Joel Rennich
    
    @ObservedObject var observedData : DialogUpdatableContent
    let fileURL: URL
    var fileHandle: FileHandle?
    var dataAvailable : NSObjectProtocol?
    var dataReady : NSObjectProtocol?
    
    init(observedData : DialogUpdatableContent, fileURL: URL) {
        self.observedData = observedData
        self.fileURL = fileURL
    }
    
    deinit {
        try? self.fileHandle?.close()
    }
    
    func monitorFile() throws {
        
        try self.fileHandle = FileHandle(forReadingFrom: fileURL)
        if let data = try? self.fileHandle?.readToEnd() {
            parseAndPrint(data: data)
        }
        fileHandle?.waitForDataInBackgroundAndNotify()
        
        dataAvailable = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: self.fileHandle, queue: nil) { notification in
            if let data = self.fileHandle?.availableData,
               data.count > 0 {
                self.parseAndPrint(data: data)
                self.fileHandle?.waitForDataInBackgroundAndNotify()
            } else {
                // something weird happened. let's re-load the file
                NotificationCenter.default.removeObserver(self.dataAvailable as Any)
                do {
                    try self.monitorFile()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: self.fileHandle, queue: nil) { notification -> Void in
                                                            NSLog("Task terminated!")
            NotificationCenter.default.removeObserver(self.dataReady as Any)
        }
    }
    
    private func parseAndPrint(data: Data) {
        if let str = String(data: data, encoding: .utf8) {
            for line in str.components(separatedBy: .newlines) {
                let command = line.trimmingCharacters(in: .newlines)
                if command == "" {
                    continue
                }
                processCommands(commands: command)
            }
        }
    }
    
    private func processCommands(commands: String) {
        
        let allCommands = commands.components(separatedBy: "\n")
        
        for line in allCommands {
            
            let command = line.components(separatedBy: " ").first!.lowercased()
                        
            switch command {
            
            case "width:" :
                observedData.windowWidth = NumberFormatter().number(from: line.replacingOccurrences(of: "width: ", with: "")) as! CGFloat
                placeWindow(observedData.mainWindow!, size: CGSize(width: observedData.windowWidth, height: observedData.windowHeight+28))
                
            case "height:" :
                observedData.windowHeight = NumberFormatter().number(from: line.replacingOccurrences(of: "height: ", with: "")) as! CGFloat
                placeWindow(observedData.mainWindow!, size: CGSize(width: observedData.windowWidth, height: observedData.windowHeight+28))
            
            // Title
            case "\(observedData.args.titleOption.long):" :
                observedData.args.titleOption.value = line.replacingOccurrences(of: "\(observedData.args.titleOption.long): ", with: "")
            
            // Message
            case "\(observedData.args.messageOption.long):" :
                observedData.args.messageOption.value = line.replacingOccurrences(of: "\(observedData.args.messageOption.long): ", with: "").replacingOccurrences(of: "\\n", with: "\n")
                //imagePresent = false
                //imageCaptionPresent = false
                //listItemPresent = false
                
            // Message Position
            case "alignment:" :
                observedData.args.messageAlignment.value = line.replacingOccurrences(of: "alignment: ", with: "")
                
            //Progress Bar
            case "\(observedData.args.progressBar.long):" :
                let incrementValue = line.replacingOccurrences(of: "\(observedData.args.progressBar.long): ", with: "")
                switch incrementValue {
                case "increment" :
                    if observedData.progressTotal == 0 {
                        observedData.progressTotal = Double(observedData.args.progressBar.value) ?? 100
                    }
                    observedData.progressValue = observedData.progressValue + 1
                case "reset" :
                    observedData.progressValue = 0
                case "complete" :
                    observedData.progressValue = Double(observedData.args.progressBar.value) ?? 1000
                case "indeterminate" :
                //    progressTotal = 0
                    observedData.progressValue = Double(-1)
                case "remove" :
                    observedData.args.progressBar.present = false
                case "create" :
                    observedData.args.progressBar.present = true
                //case "determinate" :
                //    progressValue = 0
                default :
                    if observedData.progressTotal == 0 {
                        observedData.progressTotal = Double(observedData.args.progressBar.value) ?? 100
                    }
                    observedData.progressValue = Double(incrementValue) ?? 0
                }
                
            //Progress Bar Label
            case "\(observedData.args.progressBar.long)text:" :
                observedData.statusText = line.replacingOccurrences(of: "\(observedData.args.progressBar.long)text: ", with: "")
                
            //Progress Bar Label (typo version with capital T)
            case "\(observedData.args.progressBar.long)Text:" :
                observedData.statusText = line.replacingOccurrences(of: "\(observedData.args.progressBar.long)Text: ", with: "")
            
            // Button 1 label
            case "\(observedData.args.button1TextOption.long):" :
                observedData.args.button1TextOption.value = line.replacingOccurrences(of: "\(observedData.args.button1TextOption.long): ", with: "")
                
            // Button 1 status
            case "button1:" :
                let buttonCMD = line.replacingOccurrences(of: "button1: ", with: "")
                switch buttonCMD {
                case "disable" :
                    observedData.args.button1Disabled.present = true
                case "enable" :
                    observedData.args.button1Disabled.present = false
                default :
                    observedData.args.button1Disabled.present = false
                }

            // Button 2 label
            case "\(observedData.args.button2TextOption.long):" :
                observedData.args.button2TextOption.value = line.replacingOccurrences(of: "\(observedData.args.button2TextOption.long): ", with: "")
            
            // Info Button label
            case "\(observedData.args.infoButtonOption.long):" :
                observedData.args.infoButtonOption.value = line.replacingOccurrences(of: "\(observedData.args.infoButtonOption.long): ", with: "")
                
            // Info text
            case "\(observedData.args.infoText.long):" :
                observedData.args.infoText.value = line.replacingOccurrences(of: "\(observedData.args.infoText.long): ", with: "")
                if observedData.args.infoText.value == "disable" {
                    observedData.args.infoText.present = false
                } else {
                    observedData.args.infoText.present = true
                }
                
            // icon image
            case "\(observedData.args.iconOption.long):" :
                //iconPresent = true
                let iconState = line.replacingOccurrences(of: "\(observedData.args.iconOption.long): ", with: "")
                
                if iconState.components(separatedBy: ": ").first == "size" {
                    //print(iconState)
                    //if let readIconSize = iconState.replacingOccurrences(of: "size: ", with: "") {
                    if iconState.replacingOccurrences(of: "size:", with: "").trimmingCharacters(in: .whitespaces) != "" {
                        observedData.iconSize = string2float(string: iconState.replacingOccurrences(of: "size: ", with: ""))
                    } else {
                        observedData.iconSize = appvars.iconWidth
                    }
                } else {
                    switch iconState {
                    case "centre", "center" :
                        observedData.args.centreIcon.present = true
                    case "left", "default" :
                        observedData.args.centreIcon.present = false
                    case "none" :
                        observedData.args.iconOption.present = false
                        observedData.args.iconOption.value = iconState
                    default:
                        //centreIconPresent = false
                        observedData.args.iconOption.present = true
                        observedData.args.iconOption.value = iconState
                    }
                }
                //print("centre icon is \(centreIconPresent)")
                //iconImage = line.replacingOccurrences(of: "\(observedData.args.iconOption.long): ", with: "")
                
            // overlay icon
            case "\(observedData.args.overlayIconOption.long):":
                observedData.args.overlayIconOption.value = line.replacingOccurrences(of: "\(observedData.args.overlayIconOption.long): ", with: "")
                observedData.args.overlayIconOption.present = true
                if observedData.args.overlayIconOption.value == "none" {
                    observedData.args.overlayIconOption.present = false
                }
                
            // image
            case "\(observedData.args.mainImage.long):" :
                //appvars.imageArray = [line.replacingOccurrences(of: "\(observedData.args.mainImage.long): ", with: "")]
                appvars.imageArray.append(MainImage(path: line.replacingOccurrences(of: "\(observedData.args.mainImage.long): ", with: "")))
                //imagePresent = true
                
            // image Caption
            case "\(observedData.args.mainImageCaption.long):" :
                appvars.imageCaptionArray = [line.replacingOccurrences(of: "\(observedData.args.mainImageCaption.long): ", with: "")]
                //imageCaptionPresent = true
                
            // list items
            case "list:" :
                switch line.replacingOccurrences(of: "list: ", with: "") {
                case "clear":
                    // clean everything out and remove the listview from display
                    observedData.args.listItem.present = false
                    observedData.listItemsArray = [ListItems]()
                case "show":
                    // show the list
                    observedData.args.listItem.present = true
                case "hide":
                    // hide the list but don't delete the contents
                    observedData.args.listItem.present = false
                default:
                    var listItems = line.replacingOccurrences(of: "list: ", with: "").components(separatedBy: ",")
                    listItems = listItems.map { $0.trimmingCharacters(in: .whitespaces) } // trim out any whitespace from the values if there were spaces before after the comma

                    observedData.listItemsArray = [ListItems]()
                    for itemTitle in listItems {
                        observedData.listItemsArray.append(ListItems(title: itemTitle))
                    }
                    observedData.args.listItem.present = true
                }
                
            // list item status
            case "\(observedData.args.listItem.long):" :
                var title             : String = ""
                var icon              : String = ""
                var statusText        : String = ""
                var statusIcon        : String = ""
                let statusTypeArray = ["wait","success","fail","error","pending","progress"]
                var listProgressValue : CGFloat = 0
                var deleteRow         : Bool = false
                var addRow            : Bool = false
                
                var iconIsSet         : Bool = false
                var statusIsSet       : Bool = false
                var statusTextIsSet   : Bool = false
                var progressIsSet     : Bool = false

                let listCommand = line.replacingOccurrences(of: "\(observedData.args.listItem.long): ", with: "")
                
                // Check for the origional way of doign things
                let listItemStateArray = listCommand.components(separatedBy: ": ")
                if listItemStateArray.count > 0 {
                    title = listItemStateArray.first!
                    statusIcon = listItemStateArray.last!
                    // if using the new method, these will not be set as the title value won't match the ItemValue
                    if let row = observedData.listItemsArray.firstIndex(where: {$0.title == title}) {
                        if statusTypeArray.contains(statusIcon) {
                            observedData.listItemsArray[row].statusIcon = statusIcon
                            observedData.listItemsArray[row].statusText = ""
                        } else {
                            observedData.listItemsArray[row].statusIcon = ""
                            observedData.listItemsArray[row].statusText = statusIcon
                        }
                        observedData.listItemUpdateRow = row
                        break
                    }
                }
                
                // And now for the new way
                let commands = listCommand.components(separatedBy: ",")
                
                if commands.count > 0 {
                    for command in commands {
                        let action = command.components(separatedBy: ": ")
                        switch action[0].lowercased().trimmingCharacters(in: .whitespaces) {
                            case "index":
                                if let i = Int(action[1].trimmingCharacters(in: .whitespaces)) {
                                    if i >= 0 && i < observedData.listItemsArray.count {
                                        title = observedData.listItemsArray[i].title
                                    }
                                }
                            case "title":
                                title = action[1].trimmingCharacters(in: .whitespaces)
                            case "icon":
                                icon = action[1].trimmingCharacters(in: .whitespaces)
                                iconIsSet = true
                            case "statustext":
                                statusText = action[1].trimmingCharacters(in: .whitespaces)
                                statusTextIsSet = true
                            case "status":
                                statusIcon = action[1].trimmingCharacters(in: .whitespaces)
                                statusIsSet = true
                            case "progress":
                                listProgressValue = string2float(string: action[1].trimmingCharacters(in: .whitespaces))
                                statusIcon = "progress"
                                progressIsSet = true
                                statusIsSet = true
                            case "delete":
                                deleteRow = true
                            case "add":
                                addRow = true
                            default:
                                break
                            }
                    }
                    
                    // update the list items array
                    if let row = observedData.listItemsArray.firstIndex(where: {$0.title == title}) {
                        if deleteRow {
                            observedData.listItemsArray.remove(at: row)
                            logger(logMessage: "deleted row at index \(row)")
                        } else {
                            if iconIsSet { observedData.listItemsArray[row].icon = icon }
                            if statusIsSet { observedData.listItemsArray[row].statusIcon = statusIcon }
                            if statusTextIsSet { observedData.listItemsArray[row].statusText = statusText }
                            if progressIsSet  {observedData.listItemsArray[row].progress = listProgressValue }
                            observedData.listItemUpdateRow = row
                        }
                    }
                    
                    // add to the list items array
                    if addRow {
                        observedData.listItemsArray.append(ListItems(title: title, icon: icon, statusText: statusText, statusIcon: statusIcon, progress: listProgressValue))
                        logger(logMessage: "row added with \(title) \(icon) \(statusText) \(statusIcon)")
                    }
                    
                }
                
            // quit
            case "quit:" :
                quitDialog(exitCode: appvars.exit5.code)

            default:

                break
            }
        }
    }
}

class DialogUpdatableContent : ObservableObject {
    
    // set up some defaults
    
    var path: String
    var previousCommand : String = ""
    
    @Published var mainWindow : NSWindow?
    
    // bring in all the collected appArguments
    // TODO: reduce double handling of data.
    @Published var args : CommandLineArguments
    @Published var appProperties : AppVariables = appvars
    
    @Published var titleFontColour: Color
    @Published var titleFontSize: CGFloat
    
    @Published var messageText: String
    @Published var statusText: String
    @Published var progressValue: Double
    @Published var progressTotal: Double
    @Published var iconSize: CGFloat
    
    @Published var imageArray : [MainImage]
    //@Published var imagePresent: Bool
    //@Published var imageCaptionPresent: Bool
    
    @Published var listItemsArray : [ListItems]
    @Published var listItemUpdateRow: Int

    @Published var requiredFieldsPresent : Bool
    
    @Published var windowWidth: CGFloat
    @Published var windowHeight: CGFloat
    
    @Published var showSheet: Bool
    @Published var sheetErrorMessage: String
    
    var status: StatusState
    
    let commandFilePermissions: [FileAttributeKey: Any] = [FileAttributeKey.posixPermissions: 0o666]
        
    // init
    
    init() {
        
        self.args = appArguments
        self.appProperties = appvars
        
        if appArguments.statusLogFile.present {
            path = appArguments.statusLogFile.value
        } else {
            path = "/var/tmp/dialog.log"
        }
                
        
        // initialise all our observed variables
        // for the most part we pull from whatever was passed in save for some tracking variables
        
        //button1Disabled = appArguments.button1Disabled.present
        if appArguments.timerBar.present && !appArguments.hideTimerBar.present {
            //self._button1disabled = State(initialValue: true)
            appArguments.button1Disabled.present = true
        }
                
        titleFontColour = appvars.titleFontColour
        titleFontSize = appvars.titleFontSize
        
        messageText = appArguments.messageOption.value
        statusText = appArguments.progressText.value
        progressValue = 0
        progressTotal = 0
        listItemUpdateRow = 0
        
        iconSize = string2float(string: appArguments.iconSize.value)
        
        imageArray = appvars.imageArray
        //imagePresent = appArguments.mainImage.present
        //imageCaptionPresent = appArguments.mainImageCaption.present
        
        listItemsArray = appvars.listItems

        requiredFieldsPresent = false
        
        windowWidth = appvars.windowWidth
        windowHeight = appvars.windowHeight
        
        showSheet = false
        sheetErrorMessage = ""

        // start the background process to monotor the command file
        status = .start
        
        // delete if it already exists
        self.killCommandFile()

        // create a fresh command file
        self.createCommandFile(commandFilePath: path)
        
        // start the background process to monotor the command file
        if let url = URL(string: path) {
            let fr = FileReader(observedData: self, fileURL: url)
            do {
                try fr.monitorFile()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func createCommandFile(commandFilePath: String) {
        let fm = FileManager()
        
        // check to make sure the file exists
        if fm.fileExists(atPath: commandFilePath) {
            logger(logMessage: "Existing file at \(commandFilePath). Cleaning")
            let text = ""
            do {
                try text.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                logger(logMessage: "Existing file at \(commandFilePath) but couldn't clean. ")
                logger(logMessage: "Error info: \(error)")
            }
        } else {
            logger(logMessage: "Creating file at \(commandFilePath)")
            fm.createFile(atPath: path, contents: nil, attributes: commandFilePermissions)
        }
    }
            
    
    
    func killCommandFile() {
        // delete the command file
        
        let fs = FileManager.init()
        
        if fs.isDeletableFile(atPath: path) {
            do {
                try fs.removeItem(atPath: path)
                //NSLog("Deleted Dialog command file")
            } catch {
                logger(logMessage: "Unable to delete command file")
            }
        }
    }
}
