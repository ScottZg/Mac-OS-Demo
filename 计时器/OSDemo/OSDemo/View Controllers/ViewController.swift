//
//  ViewController.swift
//  OSDemo
//
//  Created by zhanggui on 2018/1/17.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import Cocoa
import AVFoundation
class ViewController: NSViewController {
    
    //MARK:Properties
    @IBOutlet weak var timeLeftField: NSTextField!
    @IBOutlet weak var eggImageView: NSImageView!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
   
    
    @IBOutlet weak var bottomStackView: NSStackView!
    @IBOutlet weak var resetButton: NSButton!
    
    var soundPlayer: AVAudioPlayer?
    var eggTimer = EggTimer()
    var prefs = Preference()
    //MARK:life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        eggTimer.delegate = self
        setupPrefs()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func resetButtonClicked(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
    @IBAction func stopButtonClicked(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
    }
    @IBAction func startButtonClicked(_ sender: Any) {
        if eggTimer.isPaused {
            eggTimer.resumeTimer()
        }else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
        perpareSound()
    }
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        startButtonClicked(sender)
    }
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        stopButtonClicked(sender)
    }
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        resetButtonClicked(sender)
    }
    
    //MARK: Mouse action
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
           updateBottomViewDisplay()
        }
    }
    func updateBottomViewDisplay() {
        if bottomStackView.alphaValue == 0 {
           bottomStackView.alphaValue = 1
        }else {
           bottomStackView.alphaValue = 0
        }
    }
}
extension ViewController {
    func perpareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "ding", withExtension: "mp3") else {
            return
        }
        do {
           soundPlayer =  try AVAudioPlayer.init(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch  {
            print("Sound player not available: \(error)")
        }
    }
    func playSound() {
        soundPlayer?.play()
    }
    @objc func checkTimeChange() {
        if eggTimer.isStopped || eggTimer.isPaused {
            updatePrefs()
        }else {
            let alert = NSAlert()
            
            alert.messageText = "确认要重设时间么？"
            alert.informativeText = "这样会重新设置你的计时器"
            alert.alertStyle = NSAlert.Style.informational
            
            alert.addButton(withTitle: "重设")
            alert.addButton(withTitle: "取消")
        
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                 updatePrefs()
            }
        }
    }
    //MARK:prefs
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        let notificatioName = NSNotification.Name.init("PrefsChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(checkTimeChange), name: notificatioName, object: nil)
        
    }
    func updatePrefs() {
        eggTimer.duration = prefs.selectedTime
        resetButtonClicked(self)
    }
    //MARK:configuration button
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop: Bool
        let enableReset: Bool
        if eggTimer.isStopped {
            enableStart = true
            enableStop = false
            enableReset = false
        }else if  eggTimer.isPaused {
            enableStart = true
            enableStop = false
            enableReset = true
        }else {
            enableReset = false
            enableStop = true
            enableStart = false
        }
        startButton.isEnabled = enableStart
        stopButton.isEnabled = enableStop
        resetButton.isEnabled = enableReset
        
        if let appDel = NSApplication.shared.delegate as? AppDelegate {
            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
    }
    //MARK: update display
    func updateDisplay(for timerRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timerRemaining)
        eggImageView.image = imageToDisplay(for: timerRemaining)
        
    }
    func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        let minutesRemaining = floor(timeRemaining/60)
        
        
        let secondsRemaining = timeRemaining - (minutesRemaining*60)
        
        let secondsDisplay = String.init(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        
        return timeRemainingDisplay
    }
    func imageToDisplay(for timeRemaining:TimeInterval) -> NSImage{
        let percentageComplete = 100 - (timeRemaining / 360 * 100)
        
        if eggTimer.isStopped {
            let stoppedImageName = (timeRemaining == 0) ? "100" : "stopped"
            return NSImage.init(named: NSImage.Name.init(stoppedImageName))!
        }
        
        let imageName: String
        switch percentageComplete {
        case 0 ..< 25:
            imageName = "0"
        case 25 ..< 50:
            imageName = "25"
        case 50 ..< 75:
            imageName = "50"
        case 75 ..< 100:
            imageName = "75"
        default:
            imageName = "100"
        }
        
        return NSImage(named: NSImage.Name(rawValue: imageName))!
    }
}

extension ViewController:EggTimerProtocol {
    //MARK: Delegate
    func timerHasFinished(_ timer: EggTimer) {
        updateDisplay(for: 0)
        playSound()
        configureButtonsAndMenus()
    }
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
}
