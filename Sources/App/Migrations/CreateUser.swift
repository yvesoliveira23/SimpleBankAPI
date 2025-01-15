import Fluent

/// Migration to create the users table in the database
struct CreateUser: Migration {
    // MARK: - Migration Methods
    
    /// Prepares the database schema by creating the users table
    /// - Parameter database: The database connection
    /// - Returns: A future that resolves when the schema is created
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            // Primary key
            .id()
            
            // User information
            .field("name", .string, .required)
            .field("cpf", .string, .required)
                .unique(on: "cpf")
            .field("email", .string, .required)
                .unique(on: "email")
            
            // Authentication
            .field("passwordHash", .string, .required)
            
            // Account settings
            .field("isMerchant", .bool, .required)
            .field("balance", .double, .required)
            
            // Timestamps
            .field("createdAt", .datetime, .required)
            .field("updatedAt", .datetime, .required)
            
            // Create the schema
            .create()
    }
    
    /// Reverts the database schema by dropping the users table
    /// - Parameter database: The database connection
    /// - Returns: A future that resolves when the schema is deleted
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}