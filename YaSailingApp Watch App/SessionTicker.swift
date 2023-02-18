import Foundation
import WatchKit

protocol SessionTickerDelegate: AnyObject {
    func tickAction()
}

// Provides per-second ticker in the background, even if wrist is down or app is in a background
//
class SessionTicker: NSObject, ObservableObject {

    private var _timer: Timer?
    private var _session: WKExtendedRuntimeSession
    
    
    @Published public var isRunning: Bool
    @Published public var startTime: Date
    public var delegate: SessionTickerDelegate?

    public override init() {
        _session = WKExtendedRuntimeSession()
        isRunning = false
        startTime = Date()
        super .init()
    }
    
    // Start ticker to run
    //
    public func start(startTime: Date) {
        guard WKExtension.shared().applicationState == .active else { return }
        
        self.startTime = startTime
        self.isRunning = true
        
        if _session.state != .running && _session.state != .scheduled {
            _session = WKExtendedRuntimeSession()
            //_session.delegate = self;
            _session.start(at: startTime)
        }
        
        tick()
    }
    
    // stop ticker running
    //
    public func stop() {
        self.isRunning = false
        self._timer?.invalidate()
        self._timer = nil
        
        if WKExtension.shared().applicationState == .active &&
            (_session.state == .running || _session.state == .scheduled) {
            _session.invalidate()
        }
    }
    
    private func tick() {
        
        delegate?.tickAction()

        if isRunning {
            _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {
                [weak self] (_) in
                self?.tick()
            })
        }
    }
}
