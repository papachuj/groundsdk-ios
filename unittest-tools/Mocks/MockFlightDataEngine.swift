// Copyright (C) 2019 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

@testable import GroundSdk

/// This class mocks the dependencies of the `FlightDataEngine` in order to test it.
/// It does not change the behavior of the engine but enable to mock and control the collector (File system operations).
public class MockFlightDataEngine: FlightDataEngine {

    private var mockCollector: MockFlightDataCollector!

    /// Number of calls to the function collect called on the collector
    var collectCnt: Int {
        return mockCollector.collectCnt
    }

    /// Number of calls to the function delete crash called on the collector
    var deleteCnt: Int {
        return mockCollector.deleteCnt
    }

    /// Latest deleted crash url
    var latestDeletedUrl: URL? {
        return mockCollector.latestDeletedUrl
    }

    /// Mock the collection completion
    ///
    /// - Parameter result: mock list of the crash report that the collector has found
    func completeCollection(result: Set<URL>) {
        mockCollector.completeCollection(result: result)
    }

    override public func createCollector() -> FlightDataCollector {
        mockCollector = MockFlightDataCollector(rootDir: engineDir, flightDataLocalWorkDir: workDir)
        return mockCollector
    }
}

/// Collector mock
private class MockFlightDataCollector: FlightDataCollector {

    private(set) var collectCnt = 0

    private(set) var deleteCnt = 0

    private(set) var latestDeletedUrl: URL?

    private var collectCallback: ((Set<URL>) -> Void)?

    override func collectFlightDatas(completionCallback: @escaping (_ flightDataFiles: Set<URL>) -> Void) {
        collectCallback = completionCallback
        collectCnt += 1
    }

    func completeCollection(result: Set<URL>) {
        collectCallback!(result)
        collectCallback = nil
    }

    override func deleteFlightData(at url: URL) {
        latestDeletedUrl = url
        deleteCnt += 1
    }
}
