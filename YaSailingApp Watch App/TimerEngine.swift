import Foundation
import WatchKit


// Countdown timer
//
class TimerEngine: NSObject, SessionTickerDelegate, ObservableObject {

    private var _sessionTicker: SessionTicker
    private var _totalTime: Int
    private var _adjustment: Int
    private var _onExpiredAction: () -> Void

    @Published var remains: Int
    @Published var mins = 0
    @Published var secs = 0
    
    public override init() {
        self._totalTime = 0
        self._adjustment = 0
        self.remains = 0
        self._sessionTicker = SessionTicker()
        self._onExpiredAction = {}
        
        super .init()
        self._sessionTicker.delegate = self
        self.setRemains()
    }
    
    public convenience init(totalTime: Int) {
        self.init()
        self._totalTime = totalTime
        self.remains = totalTime
    }
    
    public var isRunning: Bool { return self._sessionTicker.isRunning }
    
    public var startTime: Date { return self._sessionTicker.startTime }
    
    public var totalTime: Int {
        get { return self._totalTime }
        set {
            self._totalTime = newValue
            if self.getRemains(time: Date()) < 0 {
                _adjustment = 0
                _sessionTicker.startTime = Date()
            }
        }
    }
    
    public func setOnTimerExpired(action: @escaping () -> Void) {
        _onExpiredAction = action
    }
    
    // Start or resume tick
    //
    public func startTicks() {
        guard WKExtension.shared().applicationState == .active else { return }
        
        self._sessionTicker.start(startTime: Date())
        WKInterfaceDevice.current().play(.start)
    }

    // Stop or pause tick
    //
    public func stopTicks() {
        self._sessionTicker.stop()
        self._adjustment = _totalTime - remains
        WKInterfaceDevice.current().play(.stop)
    }
    
    public func resetTicks() {
        self._sessionTicker.stop()
        self.remains = self._totalTime
        self._adjustment = 0
    }
    
    // Action to perform on every tick
    //
    public func tickAction() {
        setRemains()
        
        if remains <= 0 {
            WKInterfaceDevice.current().play(.success)
            if isRunning {
                self._onExpiredAction()
            }
            self._sessionTicker.stop()
            self._adjustment = 0
        }
        
        if remains <= 10 {
            WKInterfaceDevice.current().play(.start)
        }
        
        if remains % 30 == 0 {
            WKInterfaceDevice.current().play(.stop)
        }
    }
    
    // Adjust remaining seconds
    //
    public var adjustment: Double {
        get {
            return Double(self._adjustment)
        }
        
        set {
            let tmpRemains = getRemains(time: Date(), adj: Int(newValue))
            if tmpRemains >= self._totalTime {
                self._adjustment = isRunning ? Int(Date().distance(to: startTime)) : 0
            } else if tmpRemains <= 0 {
                self._adjustment = self._totalTime
            } else {
                self._adjustment = Int(newValue)
            }

            setRemains()
        }
    }
    
    // returns remaining minutes relative to the specific time
    // used for TimelineView
    //
    public func getUiMin(time: Date) -> Int {
        return getUiRemains(time: time) / 60
    }
    
    // returns remaining seconds relative to the specific time
    // used for TimelineView
    //
    public func getUiSec(time: Date) -> Int {
        return getUiRemains(time: time) % 60
    }
    
    // returns remaining total time in seconds relative to the specific time
    // used for TimelineView
    //
    public func getUiRemains(time: Date) -> Int {
        if !isRunning {
            return remains
        }
        let uiRemains = getRemains(time: time)
        return uiRemains > 0 ? uiRemains : 0
    }

    
    
    
    private func getRemains(time: Date) -> Int {
        return getRemains(time: time, adj: _adjustment)
    }
    
    private func getRemains(time: Date, adj: Int) -> Int {
        return self._totalTime - adj - (isRunning ? Int(startTime.distance(to: time)) : 0)
    }
    
    private func setRemains() {
        remains = getRemains(time: Date())
        mins = remains / 60
        secs = remains % 60
    }

}
