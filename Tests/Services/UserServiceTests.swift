import XCTest
@testable import SimpleBankAPI

final class UserServiceTests: XCTestCase {
    // MARK: - Properties
    private var sut: UserService!  // System Under Test
    private let testCpf = "12345678900"
    private let testPassword = "TestPass123"
    
    // MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()
        sut = UserService()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - CPF Encryption Tests
    func testEncryptCpf_WhenValidCpf_ShouldReturnEncryptedValue() throws {
        // Given
        let cpf = testCpf
        
        // When
        let encrypted = try sut.encryptCpf(cpf)
        
        // Then
        XCTAssertNotEqual(cpf, encrypted, "Encrypted CPF should be different from original")
        XCTAssertFalse(encrypted.isEmpty, "Encrypted CPF should not be empty")
    }
    
    func testDecryptCpf_WhenValidEncryptedCpf_ShouldReturnOriginalValue() throws {
        // Given
        let cpf = testCpf
        let encrypted = try sut.encryptCpf(cpf)
        
        // When
        let decrypted = sut.decryptCpf(encrypted)
        
        // Then
        XCTAssertEqual(cpf, decrypted, "Decrypted CPF should match original")
    }
    
    // MARK: - Password Tests
    func testSetPassword_WhenValidPassword_ShouldReturnHashedValue() throws {
        // Given
        let password = testPassword
        
        // When
        let hashedPassword = try sut.setPassword(password)
        
        // Then
        XCTAssertNotEqual(password, hashedPassword, "Hashed password should be different from original")
        XCTAssertFalse(hashedPassword.isEmpty, "Hashed password should not be empty")
    }
    
    func testVerifyPassword_WhenValidCredentials_ShouldReturnTrue() throws {
        // Given
        let password = testPassword
        let hashedPassword = try sut.setPassword(password)
        
        // When
        let isValid = try sut.verifyPassword(password, hash: hashedPassword)
        
        // Then
        XCTAssertTrue(isValid, "Password verification should succeed")
    }
    
    // MARK: - Balance Tests
    func testSetBalance_WhenPositiveAmount_ShouldSucceed() throws {
        // Given
        let amount = 100.0
        
        // When
        let balance = try sut.setBalance(amount)
        
        // Then
        XCTAssertEqual(balance, amount, "Balance should match input amount")
    }
    
    func testSetBalance_WhenNegativeAmount_ShouldThrowError() {
        // Given
        let amount = -100.0
        
        // When/Then
        XCTAssertThrowsError(try sut.setBalance(amount)) { error in
            // Then
            XCTAssertTrue(error is UserService.BalanceError, "Error should be BalanceError")
            XCTAssertEqual(error as? UserService.BalanceError, .negativeBalance)
        }
    }
}