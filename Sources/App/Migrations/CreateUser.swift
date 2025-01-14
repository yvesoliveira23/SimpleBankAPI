import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("cpf", .string, .required)
            .field("email", .string, .required)
            // Storing a hashed password for security reasons
            .field("passwordHash", .string, .required)
            // Indicates whether the user is a merchant
            .field("isMerchant", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}