import SwiftUI

struct ContentView: View {

    @StateObject private var pomodoroVM = PomodoroViewModel()

    var body: some View {
        VStack {
            Text(pomodoroVM.timerString)
                .font(.system(size: 100))
                .padding()
            buttonHStackView
            Spacer()
        }
        .padding()
    }
    
    // MARK: Private
    
    private var buttonHStackView: some View {
        HStack {
            Spacer()
            
            Button {
                pomodoroVM.startTimer()
            } label: {
                Text("Start")
            }
            .disabled(pomodoroVM.timerState == .running)
            
            Spacer()
            
            Button {
                pomodoroVM.pauseTimer()
            } label: {
                Text("Pause")
            }
            .disabled(pomodoroVM.timerState != .running)
            
            Spacer()
            
            Button {
                pomodoroVM.isResetPromptShown = true
            } label: {
                Text("Reset")
            }
            .confirmationDialog("Confirm reset", isPresented: $pomodoroVM.isResetPromptShown) {
                Button {
                    pomodoroVM.resetTimer()
                } label: {
                    Text("Reset")
                }
            }
            .foregroundColor(.accentColor)
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
