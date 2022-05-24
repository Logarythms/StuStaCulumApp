//
//  DispatchGroup+NotifyTimeout.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 19.05.19.
//  Copyright © 2019 stustaculum. All rights reserved.
//

import Foundation

extension DispatchGroup {
    
    func notifyWait(target: DispatchQueue, timeout: DispatchTime, handler: @escaping ((DispatchTimeoutResult) -> Void)) {
        DispatchQueue.global(qos: .default).async {
            let timeout = self.wait(timeout: timeout)
            target.async {
                handler(timeout)
            }
        }
    }
    
}

struct TimedOutError: Error, Equatable {}

///
/// Execute an operation in the current task subject to a timeout.
///
/// - Parameters:
///   - seconds: The duration in seconds `operation` is allowed to run before timing out.
///   - operation: The async operation to perform.
/// - Returns: Returns the result of `operation` if it completed in time.
/// - Throws: Throws ``TimedOutError`` if the timeout expires before `operation` completes.
///   If `operation` throws an error before the timeout expires, that error is propagated to the caller.
public func withTimeout<R>(
    seconds: TimeInterval,
    operation: @escaping @Sendable () async throws -> R
) async throws -> R {
    return try await withThrowingTaskGroup(of: R.self) { group in
        let deadline = Date(timeIntervalSinceNow: seconds)
        
        // Start actual work.
        group.addTask {
            return try await operation()
        }
        // Start timeout child task.
        group.addTask {
            let interval = deadline.timeIntervalSinceNow
            if interval > 0 {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            try Task.checkCancellation()
            // We’ve reached the timeout.
            throw TimedOutError()
        }
        // First finished child task wins, cancel the other task.
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
