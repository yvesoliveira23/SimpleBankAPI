import Fluent
import XCTest
@testable import SimpleBankAPI

final class UserModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: UserModel! // System Under Test
    private let testId = UUID()
    
    // MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()
        sut = nil
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests
    func testUserModel_WhenInitializedWithValidData_ShouldCreateInstance() {
        // Given
        let name = "Test User"
        let cpf = "12345678900"
        let email = "test@email.com"
        let password = "password"
        let balance = 100.0
        let isMerchant = false
        
        // When
        sut = UserModel(
            id: testId,
            name: name,
            cpf: cpf,
            email: email,
            password: password,
            balance: balance,
            isMerchant: isMerchant
        )
        
        // Then
        XCTAssertNotNil(sut, "User instance should not be nil")
        XCTAssertEqual(sut.id, testId, "User ID should match provided value")
        XCTAssertEqual(sut.name, name, "User name should match provided value")
        XCTAssertEqual(sut.cpf, cpf, "User CPF should match provided value")
        XCTAssertEqual(sut.email, email, "User email should match provided value")
        XCTAssertEqual(sut.password, password, "User password should match provided value")
        XCTAssertEqual(sut.balance, balance, "User balance should match provided value")
        XCTAssertEqual(sut.isMerchant, isMerchant, "User merchant status should match provided value")
    }
}