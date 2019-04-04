import XCTest
import Nimble
@testable import PushNotifications

class ClearAllStateTest: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "81f5b7dda5c66bd2497c15a79a8be6e8858f7bd62ccfbb96cbbed9d327d95a78".hexStringToData()!

    override func setUp() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testItShouldClearAllState() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()

        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "a"))
        XCTAssertEqual(pushNotifications.getDeviceInterests(), ["a"])
        pushNotifications.clearAllState { _ in
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId!))
            .toEventually(beNil(), timeout: 10)

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
        expect(Device.getDeviceId()).toEventuallyNot(equal(deviceId!), timeout: 10)
    }
}
