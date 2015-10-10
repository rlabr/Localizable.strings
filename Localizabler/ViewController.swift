//
//  ViewController.swift
//  Localizabler
//
//  Created by Cristian Baluta on 01/10/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var pathControl: NSPathControl?
	@IBOutlet var segmentedControl: NSSegmentedControl?
	@IBOutlet var keysTableView: NSTableView?
	@IBOutlet var translationsTableView: NSTableView?
	
	var keysTableViewDataSource: KeysTableViewDataSource?
	var translationsTableViewDataSource: TranslationsTableViewDataSource?
	var languages = [String: LocalizationFile]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let win = NSApplication.sharedApplication().windows.first
		win?.titlebarAppearsTransparent = true
		win?.titleVisibility = NSWindowTitleVisibility.Hidden;
		
		keysTableViewDataSource = KeysTableViewDataSource(tableView: keysTableView!)
		translationsTableViewDataSource = TranslationsTableViewDataSource(tableView: translationsTableView!)
		
		keysTableViewDataSource?.onRowPressed = { (rowNumber: Int, key: String) -> Void in
			
			var translations = [TranslationData]()
			
			for (lang, localizationFile) in self.languages {
				
				translations.append(
					(originalValue: localizationFile.translationForTerm(key),
						newValue: nil,
						countryCode: lang
					) as TranslationData
				)
			}
			self.translationsTableViewDataSource?.data = translations
			self.translationsTableView?.reloadData()
		}
		
		// Do any additional setup after loading the view.
		if let dir = NSUserDefaults.standardUserDefaults().objectForKey("localizationsDirectory") {
            self.pathControl!.URL = NSURL(string: dir as! String)
            self.scanDirectoryForLocalizationfiles()
			self.showDefaultLanguage()
        }
    }
    
    @IBAction func browseButtonClicked(sender: NSButton) {
		
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false;
        panel.beginWithCompletionHandler { (result) -> Void in
            RCLogO(result)
            if result == NSFileHandlingPanelOKButton {
                print(panel.URLs.first)
                self.pathControl!.URL = panel.URLs.first
                NSUserDefaults.standardUserDefaults().setObject(panel.URLs.first?.absoluteString, forKey: "localizationsDirectory")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.scanDirectoryForLocalizationfiles()
				self.showDefaultLanguage()
            }
        }
    }
    
    func scanDirectoryForLocalizationfiles() {
        
        _ = SearchIOSLocalizations().searchInDirectory(self.pathControl!.URL!) { (localizationsDict) -> Void in
            RCLogO(localizationsDict)
            self.segmentedControl!.segmentCount = localizationsDict.count
            var i = 0
            for (key, url) in localizationsDict {
				self.loadLocalizationFile(url, forKey: key)
                self.segmentedControl?.setLabel(key, forSegment: i)
                i++
            }
        }
    }
    
	func loadLocalizationFile(url: NSURL, forKey key: String) {
        self.languages[key] = IOSLocalizationFile(url: url)
    }
	
	func showDefaultLanguage() {
		
		var keys = [String]()
		if let file = languages["Base"] {
			keys = file.allTerms()
		}
		else if let file = languages["en"] {
			keys = file.allTerms()
		}
		keysTableViewDataSource?.data = keys
		keysTableView?.reloadData()
	}
}
