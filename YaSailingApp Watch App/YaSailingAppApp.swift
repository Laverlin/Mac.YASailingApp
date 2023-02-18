import SwiftUI


@main
struct YaSailingApp_Watch_AppApp: App {
    @StateObject var timerConfig = TimerConfig()
    var body: some Scene {
        WindowGroup {
            MainView(totalTime: timerConfig.totalSeconds)
        }
    }
}

class TabState: ObservableObject {
    @Published public var tabId = 1
}

struct MainView: View {
    @StateObject var tabState = TabState()
    @StateObject var timerEngine: TimerEngine
    @StateObject var locationManager = LocationManager()
    
    init(totalTime: Int) {
        _timerEngine = StateObject(wrappedValue: TimerEngine(totalTime: totalTime))
    }
    
    var body: some View {
        TabView(selection: $tabState.tabId) {
            SettingVew(totalTime: timerEngine.totalTime)
                .environmentObject(timerEngine)
                .environmentObject(tabState)
                .tag(0)
            TimerVew()
                .environmentObject(timerEngine)
                .environmentObject(locationManager)
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}
