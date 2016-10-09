//
//  InterfaceController.swift
//  StopWatchSamp WatchKit Extension
//
//  Created by Tatsuhiko Arai on 2016/10/09.
//  Copyright © 2016 Tatsuhiko Arai. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    var elapseTimeFromStart: TimeInterval = 0
    var startDate: Date!
    var elapseTimeFromPrev: TimeInterval = 0
    var prevDate: Date!
    var watchTimer: Timer!
    var lapNo = 0

    @IBOutlet var stopWatchLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var lapButton: WKInterfaceButton!
    @IBOutlet var lapTable: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onStartButtonPressed() {
        self.startDate = Date()
        self.prevDate = self.startDate
        self.startTimer()

        self.startButton.setHidden(true)
        self.stopButton.setHidden(false)

        self.resetButton.setHidden(true)
        self.lapButton.setHidden(false)
    }

    @IBAction func onStopButtonPressed() {
        let dateNow = Date()

        self.stopTimer()

        self.elapseTimeFromStart += dateNow.timeIntervalSince(self.startDate)
        self.startDate = nil

        self.elapseTimeFromPrev += dateNow.timeIntervalSince(self.prevDate)
        self.prevDate = nil

        self.stopButton.setHidden(true)
        self.startButton.setHidden(false)

        self.lapButton.setHidden(true)
        self.resetButton.setHidden(false)
    }

    @IBAction func onResetButtonPressed() {
        self.elapseTimeFromStart = 0
        self.elapseTimeFromPrev = 0
        self.lapNo = 0

        self.stopWatchLabel.setText("00:00.00")
        self.lapTable.removeRows(at: IndexSet(integersIn: 0..<self.lapTable.numberOfRows))
    }

    @IBAction func onLapButtonPressed() {
        let dateNow = Date()
        let interval = dateNow.timeIntervalSince(self.prevDate) + self.elapseTimeFromPrev
        self.lapTable.insertRows(at: IndexSet([0]), withRowType: "lapTimeRow")
        if let row = self.lapTable.rowController(at: 0) as? LapTimeRowController {
            self.lapNo += 1
            row.lapNoLabel.setText("\(self.lapNo)")
            row.lapLabel.setText(interval.formattedString)
        }

        self.elapseTimeFromPrev = 0
        self.prevDate = dateNow
    }

    func startTimer() {
        self.watchTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let dateNow = Date()
            let interval = dateNow.timeIntervalSince(self.startDate) + self.elapseTimeFromStart
            self.stopWatchLabel.setText(interval.formattedString)
        }
    }

    func stopTimer() {
        self.watchTimer.invalidate()
        self.watchTimer = nil
    }

}

class LapTimeRowController: NSObject {
    @IBOutlet var lapNoLabel: WKInterfaceLabel!
    @IBOutlet weak var lapLabel: WKInterfaceLabel!
}

extension TimeInterval {
    var formattedString: String {
        let timeDate = Date(timeIntervalSince1970: self)
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "mm:ss.SS"
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormat.string(from: timeDate)
    }
}
