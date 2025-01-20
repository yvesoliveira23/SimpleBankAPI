import XCTest
import XCTVapor
@testable import App

final class UserControllerTests: XCTestCase {
    // MARK: - Properties
    private var app: Application!
    // System Under Test: This is the instance of UserController that we are testing.
    // It is initialized in the setUp method and deinitialized in the tearDown method.
    private var sut: UserController!
    
    // MARK: - Lifecycle
    override func setUp() async throws {
        app = Application(.testing)
        do {
            try await configure(app)
        } catch {
            XCTFail("Failed to configure app: \(error)")
        }
        sut = UserController()
    }
    
    override func tearDown() async throws {
        app.shutdown()
        sut = nil
    }
    
    // MARK: - Create a User
    func testCreateUser_WhenValidData_ShouldReturnCreatedUser() async throws {
        // Given
        let userData = createUserDTO(
            name: "Test User",
            cpf: "12345678900",
            email: "test@example.com",
            password: "password123",
            balance: 100.0
        )
        
        // When
        try app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode(userData)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .created)
            let user = try response.content.decode(UserDTO.self)
            XCTAssertEqual(user.name, userData.name)
            XCTAssertEqual(user.email, userData.email)
            XCTAssertNotNil(user.id)
        })
    }
    
    func testCreateUser_WhenInvalidData_ShouldReturnBadRequest() async throws {
        let invalidData: UserDTO
        do {
            invalidData = try UserDTO(
                name: "",
                cpf: "invalid",
                email: "invalid-email",
                password: "short",
                balance: -100.0,
                isMerchant: false
            )
        } catch {
            XCTFail("Failed to initialize UserDTO with invalid data: \(error)")
            return
        }
        
        // When
        try app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode(invalidData)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    // MARK: - Retrieve a User
    func testGetUser_WhenUserExists_ShouldReturnUser() async throws {
        // Given
        let user = try await createAndSaveTestUser()
        
        // When
        try app.test(.GET, "users/\(user.id!)", afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .ok)
            let fetchedUser = try response.content.decode(UserDTO.self)
            XCTAssertEqual(fetchedUser.id, user.id)
        })
    }
    
    func testGetUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonExistentUserId = UUID()
        try app.test(.GET, "users/\(nonExistentUserId)", afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    // MARK: - Update a User
    func testUpdateUser_WhenValidData_ShouldReturnUpdatedUser() async throws {
        // Given
        let user = try await createAndSaveTestUser()
        let updateData = UserUpdateDTO(
            name: "Updated Name",
            email: "updated@example.com",
            isMerchant: true
        )
        
        // When
        try app.test(.PUT, "users/\(user.id!)", beforeRequest: { req in
            try req.content.encode(updateData)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .ok)
            let updatedUser = try response.content.decode(UserDTO.self)
            XCTAssertEqual(updatedUser.name, updateData.name)
            XCTAssertEqual(updatedUser.email, updateData.email)
            XCTAssertEqual(updatedUser.isMerchant, updateData.isMerchant)
        })
    }
    
    func testUpdateUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonExistentUserId = UUID()
        let updateData = UserUpdateDTO(
            name: "Updated Name",
            email: "updated@example.com",
            isMerchant: true
        )
        
        try app.test(.PUT, "users/\(nonExistentUserId)", beforeRequest: { req in
            try req.content.encode(updateData)
        }, afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    // MARK: - Delete a User
    func testDeleteUser_WhenUserExists_ShouldReturnNoContent() async throws {
        // Given
        let user = try await createTestUser()
        
        // When
        try app.test(.DELETE, "users/\(user.id!)", afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .noContent)
            
            // Verify user was deleted
            try app.test(.GET, "users/\(user.id!)", afterResponse: { response in
                XCTAssertEqual(response.status, .notFound)
            })
        })
    }
    
    func testDeleteUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonExistentUserId = UUID()
        try app.test(.DELETE, "users/\(nonExistentUserId)", afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    // MARK: - List Tests
    func testListUsers_WhenUsersExist_ShouldReturnUserList() async throws {
        // Given
        let user1 = try await createAndSaveTestUser()
        let user2 = try await createAndSaveTestUser(email: "test2@example.com")
        
        // When
        try app.test(.GET, "users", afterResponse: { response in
            // Then
            XCTAssertEqual(response.status, .ok)
            let users = try response.content.decode([UserDTO].self)
            XCTAssertGreaterThanOrEqual(users.count, 2)
            XCTAssertTrue(users.contains { $0.id == user1.id })
            XCTAssertTrue(users.contains { $0.id == user2.id })
        })
    }
    
    // MARK: - Helper Methods
    private func createUserDTO(name: String, cpf: String, email: String, password: String, balance: Double, isMerchant: Bool) -> UserDTO {
        return UserDTO(
            name: name,
            cpf: cpf,
            email: email,
            password: password,
            balance: balance,
            isMerchant: isMerchant
        )
    }
    
    private func createAndSaveTestUser(email: String = "test@example.com") async throws -> UserModel {
        let user = UserModel(
            name: "Test User",
            cpf: "12345678900",
            email: email,
            passwordHash: try Bcrypt.hash("password123"),
            balance: 100.0,
            isMerchant: false
        )
        try await user.save(on: app.db)
        return user
    }
    
    private func createAndSaveTestUser() async throws -> UserModel {
        let user = UserModel(
            name: "Test User",
            cpf: "12345678900",
            email: "test@example.com",
            passwordHash: try Bcrypt.hash("password123"),
            balance: 100.0,
            isMerchant: false
        )
        try await user.save(on: app.db)
        return user
    }
}
