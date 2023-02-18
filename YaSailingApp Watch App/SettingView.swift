
import SwiftUI


struct SettingVew: View {

    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var tabState: TabState
    @State private var _totalTime: Int

    init(totalTime: Int) {
        _totalTime = totalTime
    }
    
    var body: some View {
        VStack {
            Text("Timer Settings")
                .padding()
                .font(.callout)
                .fontWeight(.bold)
            
            Picker("", selection: $_totalTime) {
                ForEach(1..<11) { i in
                    Text("\(i) min").tag(i * 60)
                }
            }
            .font(.caption)
            .fontWeight(.regular)
            .onChange(of: _totalTime) { value in
                timerEngine.totalTime = value
            }
            
            Button(action: {
                timerEngine.totalTime = _totalTime
                timerEngine.resetTicks()
                tabState.tabId = 1
            }) {
                HStack {
                    Image(systemName: "memories")
                        .font(.title3)
                        .padding()
                    Text("Reset Timer")
                        .padding()
                }
            }
            .font(.caption)
            .padding()
        }
    }
}
    

struct SettingView_Previews: PreviewProvider {

    static var previews: some View {

        SettingVew(totalTime: 300)
            .environmentObject(TimerConfig())
            .environmentObject(TimerEngine())
            .environmentObject(TabState())
    }
}
