//
//  PrefsViewController.swift
//  OSDemo
//
//  Created by zhanggui on 2018/1/17.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import Cocoa

let TIMEKEY: String = "TimeKey"
class PrefsViewController: NSViewController {

    @IBOutlet weak var presetsPopup: NSPopUpButton!
    
    @IBOutlet weak var customSlider: NSSlider!
    
    @IBOutlet weak var customTextField: NSTextField!
    
   
    
    var prefs: Preference = Preference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        showExistPerfes()
    
    }
    
    @IBAction func popupValueChanged(_ sender: NSPopUpButton) {
        print(sender.title)
        if sender.selectedItem?.title == "Custom" {
            customSlider.isEnabled = true
            return
        }
        let newTime = sender.selectedItem?.tag
        customSlider.integerValue = newTime!
        showSliderValueAtText()
        customSlider.isEnabled = false
        
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        showSliderValueAtText()
        
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func okButtonClicked(_ sender: Any) {
        saveNewPrefs()
        view.window?.close()
    }
}

extension PrefsViewController {

    func saveNewPrefs() {
        prefs.selectedTime =  customSlider.doubleValue * 60
        NotificationCenter.default.post(name: NSNotification.Name.init("PrefsChanged"), object: nil)
        
    }
    func showExistPerfes() {
        let selectedTimeInMiniunes = Int(prefs.selectedTime) / 60
        presetsPopup.selectItem(withTitle: "Custom")
        customSlider.isEnabled = true
        
        for item in presetsPopup.itemArray {
            if item.tag == selectedTimeInMiniunes {
                presetsPopup.select(item)
                customSlider.isEnabled = false
                break
            }
        }
        customSlider.integerValue = selectedTimeInMiniunes
        showSliderValueAtText()
  
    }
    func showSliderValueAtText() {
        let newTimeText = customSlider.integerValue
        let minuteDes = newTimeText == 1 ? "minute" : "minutes"
        customTextField.stringValue = "\(newTimeText) \(minuteDes)"
    }
}
