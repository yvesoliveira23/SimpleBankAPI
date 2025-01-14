import XCTest
import Fluent
@testable import SimpleBankAPI

final class CreateUserMigrationTests: XCTestCase {
    // MARK: - Properties
    private var app: Application!
    private var sut: CreateUser! // System Under Test
    
    // MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        sut = CreateUser()
    }
    
    override func tearDown() async throws {
        app.shutdown()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Migration Tests
    func testMigration_WhenPreparing_ShouldCreateSchema() async throws {
        // When
        try await sut.prepare(on: app.db).wait()
        
        // Then
        let schema = try await app.db.schema("users").describe().wait()
        XCTAssertTrue(schema.contains { $0.name == "name" }, "Schema should contain name field")
        XCTAssertTrue(schema.contains { $0.name == "cpf" }, "Schema should contain cpf field")
        XCTAssertTrue(schema.contains { $0.name == "email" }, "Schema should contain email field")
        XCTAssertTrue(schema.contains { $0.name == "passwordHash" }, "Schema should contain passwordHash field")
        XCTAssertTrue(schema.contains { $0.name == "isMerchant" }, "Schema should contain isMerchant field")
    }
    
    func testMigration_WhenReverting_ShouldDeleteSchema() async throws {
        // Given
        try await sut.prepare(on: app.db).wait()
        
        // When
        try await sut.revert(on: app.db).wait()
        
        // Then
        XCTAssertThrowsError(try await app.db.schema("users").describe().wait(), "Schema should be deleted")
    }
}