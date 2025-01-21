import XCTest
import XCTVapor
@testable import App

final class UserControllerTests: XCTestCase {
    // MARK: - Properties
    private var app: Application!
    private var sut: UserController!
    
    // MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try await configure(app)
        sut = UserController()
    }
    
    override func tearDown() async throws {
        await app.db.shutdown()
        app.shutdown()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Create Tests
    func testCreateUser_WhenValidData_ShouldReturnCreatedUser() async throws {
        // Given
        let userData = try TestFactory.makeUserDTO()
        
        // When/Then
        try app.test(.POST, "api/v1/users", beforeRequest: { req in
            try req.content.encode(userData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .created)
            let user = try response.content.decode(UserDTO.self)
            XCTAssertNotNil(user.id)
            XCTAssertEqual(user.name, userData.name)
        })
    }
    
    func testCreateUser_WhenInvalidData_ShouldReturnBadRequest() async throws {
        // Given
        let invalidData = try TestFactory.makeInvalidUserDTO()
        
        // When/Then
        try app.test(.POST, "api/v1/users", beforeRequest: { req in
            try req.content.encode(invalidData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    func testCreateUser_WhenDuplicateEmail_ShouldReturnConflict() async throws {
        // Given
        let user = try await createTestUser()
        let duplicateEmailData = try TestFactory.makeUserDTO(email: user.email)
        
        // When/Then
        try app.test(.POST, "api/v1/users", beforeRequest: { req in
            try req.content.encode(duplicateEmailData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .conflict)
        })
    }
    
    func testCreateUser_WhenDuplicateCPF_ShouldReturnConflict() async throws {
        // Given
        let user = try await createTestUser()
        let duplicateCPFData = try TestFactory.makeUserDTO(cpf: user.cpf)
        
        // When/Then
        try app.test(.POST, "api/v1/users", beforeRequest: { req in
            try req.content.encode(duplicateCPFData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .conflict)
        })
    }
    
    // MARK: - Read Tests
    func testGetUser_WhenUserExists_ShouldReturnUser() async throws {
        // Given
        let user = try await createTestUser()
        
        // When/Then
        try app.test(.GET, "api/v1/users/\(user.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let fetchedUser = try response.content.decode(UserDTO.self)
            XCTAssertEqual(fetchedUser.id, user.id)
        })
    }
    
    func testGetUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonexistentId = UUID()
        
        // When/Then
        try app.test(.GET, "api/v1/users/\(nonexistentId)", afterResponse: { response in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    // MARK: - Update Tests
    func testUpdateUser_WhenValidData_ShouldReturnUpdatedUser() async throws {
        // Given
        let user = try await createTestUser()
        let updateData = TestFactory.makeUpdateUserDTO()
        
        // When/Then
        try app.test(.PUT, "api/v1/users/\(user.id!)", beforeRequest: { req in
            try req.content.encode(updateData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let updatedUser = try response.content.decode(UserDTO.self)
            XCTAssertEqual(updatedUser.name, updateData.name)
        })
    }
    
    func testUpdateUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonExistentUserId = UUID()
        let updateData = TestFactory.makeUpdateUserDTO()
        
        // When/Then
        try app.test(.PUT, "api/v1/users/\(nonExistentUserId)", beforeRequest: { req in
            try req.content.encode(updateData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    func testUpdateUser_WhenInvalidData_ShouldReturnBadRequest() async throws {
        // Given
        let user = try await createTestUser()
        let invalidData = TestFactory.makeInvalidUpdateUserDTO()
        
        // When/Then
        try app.test(.PUT, "api/v1/users/\(user.id!)", beforeRequest: { req in
            try req.content.encode(invalidData)
        }, afterResponse: { response in
            XCTAssertEqual(response.status, .badRequest)
        })
    }
    
    // MARK: - Delete Tests
    func testDeleteUser_WhenUserExists_ShouldDeleteUser() async throws {
        // Given
        let user = try await createTestUser()
        
        // When/Then
        try app.test(.DELETE, "api/v1/users/\(user.id!)", afterResponse: { response in
            XCTAssertEqual(response.status, .noContent)
        })
    }
    
    func testDeleteUser_WhenUserDoesNotExist_ShouldReturnNotFound() async throws {
        // Given
        let nonexistentId = UUID()
        
        // When/Then
        try app.test(.DELETE, "api/v1/users/\(nonexistentId)", afterResponse: { response in
            XCTAssertEqual(response.status, .notFound)
        })
    }
    
    // MARK: - List Tests
    func testListUsers_WhenUsersExist_ShouldReturnList() async throws {
        // Given
        let users = try await createMultipleUsers(count: 3)
        
        // When/Then
        try app.test(.GET, "api/v1/users", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let userList = try response.content.decode([UserDTO].self)
            XCTAssertEqual(userList.count, users.count)
        })
    }
    
    func testListUsers_WhenNoUsers_ShouldReturnEmptyList() async throws {
        // When/Then
        try app.test(.GET, "api/v1/users", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let userList = try response.content.decode([UserDTO].self)
            XCTAssertTrue(userList.isEmpty)
        })
    }
    
    func testListUsers_WithPagination_ShouldReturnPagedResults() async throws {
        // Given
        let users = try await createMultipleUsers(count: 10)
        
        // When/Then
        try app.test(.GET, "api/v1/users?page=1&per=5", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let userList = try response.content.decode([UserDTO].self)
            XCTAssertEqual(userList.count, 5)
        })
    }
    
    func testListUsers_WithFiltering_ShouldReturnFilteredResults() async throws {
        // Given
        let user1 = try await createTestUser(name: "Alice")
        let user2 = try await createTestUser(name: "Bob", email: "bob@example.com", cpf: "12345678901")
        
        // When/Then
        try app.test(.GET, "api/v1/users?name=Alice", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let userList = try response.content.decode([UserDTO].self)
            XCTAssertEqual(userList.count, 1)
            XCTAssertEqual(userList.first?.name, user1.name)
        })
    }
    
    func testListUsers_WithSorting_ShouldReturnSortedResults() async throws {
        // Given
        let user1 = try await createTestUser(name: "Alice")
        let user2 = try await createTestUser(name: "Bob", email: "bob@example.com", cpf: "12345678901")
        
        // When/Then
        try app.test(.GET, "api/v1/users?sort=name", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            let userList = try response.content.decode([UserDTO].self)
            XCTAssertEqual(userList.count, 2)
            XCTAssertEqual(userList.first?.name, user1.name)
            XCTAssertEqual(userList.last?.name, user2.name)
        })
    }
    
    // MARK: - Helper Methods
    private func createTestUser(
        name: String = "Test User",
        email: String = "test@example.com",
        cpf: String = "12345678900"
    ) async throws -> UserModel {
        let user = UserModel(
            name: name,
            cpf: cpf,
            email: email,
            passwordHash: try Bcrypt.hash("password123"),
            balance: 100.0,
            isMerchant: false
        )
        try await user.save(on: app.db)
        return user
    }
    
    private func createMultipleUsers(count: Int) async throws -> [UserModel] {
        var users: [UserModel] = []
        for i in 0..<count {
            let user = try await createTestUser(
                name: "User \(i)",
                email: "user\(i)@example.com",
                cpf: "1234567890\(i)"
            )
            users.append(user)
        }
        return users
    }
}