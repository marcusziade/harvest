import Combine
import Foundation

enum PomodoroState {
    case work
    case shortBreak
    case longBreak
    
    var duration: TimeInterval {
        switch self {
        case .work:
            return 25 * 60
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
}

final class PomodoroViewModel: ObservableObject {
    
    @Published var timerString = ""
    @Published var currentPomodoroState: PomodoroState = .work
    @Published var pomodoroStats = PomodoroStats(completedSessions: 0, totalTimeSpent: 0)
    
    init() {
        loadStatsFromUserDefaults()
    }
    
    func startTimer() {
        remainingTime = currentPomodoroState.duration
        
        timerSubscription?.cancel()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [unowned self] _ in
                remainingTime -= 1
                timerString = formatTimeInterval(remainingTime)
                
                if remainingTime <= 0 {
                    completeTimer()
                }
            }
    }
    
    func pauseTimer() {
        timerSubscription?.cancel()
    }
    
    func resetTimer() {
        timerSubscription?.cancel()
        timerString = formatTimeInterval(0)
        currentPomodoroState = .work
    }
    
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: Private
    
    private var timerSubscription: AnyCancellable?
    private var remainingTime: TimeInterval = 0
    private var sessionCount = 0
    
    private func completeTimer() {
        timerSubscription?.cancel()
        
        switch currentPomodoroState {
        case .work:
            completeSession()
            
        case .shortBreak, .longBreak:
            currentPomodoroState = .work
        }
        
        startTimer()
    }
    
    private func completeSession() {
        pomodoroStats.completedSessions += 1
        pomodoroStats.totalTimeSpent += currentPomodoroState.duration
        
        sessionCount += 1
        currentPomodoroState = sessionCount % 4 == 0 ? .longBreak : .shortBreak
    }
}

extension PomodoroViewModel {
    
    struct PomodoroStats {
        var completedSessions: Int
        var totalTimeSpent: TimeInterval
    }
    
    private func saveStatsToUserDefaults() {
        UserDefaults.standard.set(pomodoroStats.completedSessions, forKey: "completedSessions")
        UserDefaults.standard.set(pomodoroStats.totalTimeSpent, forKey: "totalTimeSpent")
    }
    
    private func loadStatsFromUserDefaults() {
        let completedSessions = UserDefaults.standard.integer(forKey: "completedSessions")
        let totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        pomodoroStats = PomodoroStats(completedSessions: completedSessions, totalTimeSpent: totalTimeSpent)
    }
}
