import Combine
import XCTest

@testable import timeharvest

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
        viewModel.startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.viewModel.timerString, "24:58", "Timer is not updating correctly")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testPauseAndUnpauseTimer() {
        let pauseExpectation = XCTestExpectation(description: "Wait for timer to pause")
        let unpauseExpectation = XCTestExpectation(description: "Wait for timer to unpause")
        viewModel.startTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            viewModel.pauseTimer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                XCTAssertEqual(viewModel.timerString, "24:58", "Timer is not pausing correctly")
                pauseExpectation.fulfill()
                
                viewModel.startTimer()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    XCTAssertEqual(viewModel.timerString, "24:56", "Timer is not unpausing correctly")
                    unpauseExpectation.fulfill()
                }
            }
        }
        
        wait(for: [pauseExpectation, unpauseExpectation], timeout: 10)
    }
    
    func testResetTimer() {
        viewModel.startTimer()
        XCTAssertEqual(viewModel.timerState, .running)
        
        let pauseExpectation = XCTestExpectation(description: "Wait for timer to pause")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            viewModel.pauseTimer()
            XCTAssertEqual(viewModel.timerState, .paused)
            
            let expectedRemainingTime = PomodoroState.work.duration - 2
            XCTAssertEqual(viewModel.timerString, viewModel.formatTimeInterval(expectedRemainingTime), "Timer did not run for 2 seconds before pausing")
            
            viewModel.resetTimer()
            XCTAssertEqual(viewModel.timerState, .stopped)
            XCTAssertEqual(viewModel.currentPomodoroState, .work)
            XCTAssertEqual(viewModel.timerString, viewModel.formatTimeInterval(PomodoroState.work.duration), "Timer did not reset correctly")
            
            pauseExpectation.fulfill()
        }
        
        wait(for: [pauseExpectation], timeout: 10)
    }

    // MARK: Private
    
    private var viewModel: PomodoroViewModel!
    private var cancellables: Set<AnyCancellable>!
}
