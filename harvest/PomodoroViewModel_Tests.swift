import Combine
import XCTest

@testable import harvest

final class PomodoroViewModel_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        viewModel = PomodoroViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFormatTimeInterval() {
        let interval1: TimeInterval = 90
        let formattedString1 = viewModel.formatTimeInterval(interval1)
        XCTAssertEqual(formattedString1, "01:30", "Formatted time interval is incorrect")
        
        let interval2: TimeInterval = 3599
        let formattedString2 = viewModel.formatTimeInterval(interval2)
        XCTAssertEqual(formattedString2, "59:59", "Formatted time interval is incorrect")
    }
    
    func testPomodoroStateDuration() {
        let workDuration = PomodoroState.work.duration
        XCTAssertEqual(workDuration, 25 * 60, "Work duration is incorrect")
        
        let shortBreakDuration = PomodoroState.shortBreak.duration
        XCTAssertEqual(shortBreakDuration, 5 * 60, "Short break duration is incorrect")
        
        let longBreakDuration = PomodoroState.longBreak.duration
        XCTAssertEqual(longBreakDuration, 15 * 60, "Long break duration is incorrect")
    }
    
    func testStartTimer() {
        let expectation = XCTestExpectation(description: "Wait for timer to update")
        viewModel.currentPomodoroState = .work
        viewModel.startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.viewModel.timerString, "24:58", "Timer is not updating correctly")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testPauseTimer() {
        let expectation = XCTestExpectation(description: "Wait for timer to pause")
        viewModel.currentPomodoroState = .work
        viewModel.startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewModel.pauseTimer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertEqual(self.viewModel.timerString, "24:58", "Timer is not pausing correctly")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testResetTimer() {
        viewModel.currentPomodoroState = .work
        viewModel.startTimer()
        viewModel.resetTimer()
        
        XCTAssertEqual(viewModel.timerString, "00:00", "Reset timer is not setting timerString to 00:00")
        XCTAssertEqual(viewModel.currentPomodoroState, .work, "Reset timer is not setting currentPomodoroState to .work")
    }
    
    // MARK: Private
    
    private var viewModel: PomodoroViewModel!
    private var cancellables: Set<AnyCancellable>!
}
