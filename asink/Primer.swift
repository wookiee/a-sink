
import Foundation

class Primer {

    private let finderQueue = DispatchQueue(label: "Primer.finderQueue", qos: .utility)
    private let lockQueue = DispatchQueue(label: "Primer.lockQueue", qos: .default)
    
    private var _isRunning: Bool = false
    private(set) var isRunning: Bool {
        get { lockQueue.sync { _isRunning } }
        set { lockQueue.sync { _isRunning = newValue } }
    }
    
    private var _lastFoundPrime = -1
    private(set) var lastFoundPrime: Int {
        get { lockQueue.sync { _lastFoundPrime } }
        set { lockQueue.sync { _lastFoundPrime = newValue } }
    }
    
    private var lastTestedNumber = -1
    
    func start() {
        isRunning = true

        finderQueue.async { [weak self] in
            guard let self = self else { return }
            while self.isRunning {
                let test = self.lastTestedNumber + 2
                if test.isPrime() {
                    self.lastFoundPrime = test
                }
                self.lastTestedNumber = test
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
    
    func reset() {
        stop()
        self.lastFoundPrime = -1
    }

}

private extension Int {
    static let smallPrimes = Set([1,2,3,5])
    
    func isPrime() -> Bool {
        
        if Int.smallPrimes.contains(self) { return true }
        
        let (halfOfSelf, remainderBy2) = modf(Double(self) / 2.0)
        if remainderBy2 == 0 { return false }
        
        for test in 3 ..< Int(halfOfSelf) {
            if self % test == 0 {
                return false
            }
        }
        
        return true
    }
}
