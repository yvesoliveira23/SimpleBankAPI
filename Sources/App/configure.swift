import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Uncomment the line below to serve files from the /Public folder.
    // This is useful for serving static files like images, CSS, and JavaScript.
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        port: Environment.get("DATABASE_PORT").flatMap { Int($0) } ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql))

    app.migrations.add(CreateUser())
    app.migrations.add(CreateTransaction())

    // Configure Leaf
    if let useLeaf = Environment.get("USE_LEAF"), useLeaf == "true" {
        app.views.use(.leaf)
    }
    // Configure the application's routes by registering all route handlers
    try routes(app)
}
