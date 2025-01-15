import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public struct AppConfiguration {
    /// Database configuration
    struct Database {
        static let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? SQLPostgresConfiguration.ianaPortNumber
        static let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        static let username = Environment.get("DATABASE_USERNAME") ?? "vapor_username"
        static let password = Environment.get("DATABASE_PASSWORD") ?? ""
    }
    
    /// Feature flags
    struct Features {
        static let enableLeaf = Environment.get("ENABLE_LEAF") == "true"
    }
}

/// Configures the application with the given settings
/// - Parameter app: The application instance to configure
/// - Throws: An error if configuration fails
public func configure(_ app: Application) async throws {
    // Configure database
    try configureDatabase(app)
    
    // Configure view engine
    configureViewEngine(app)
    
    // Configure routes
    try configureRoutes(app)
}

// MARK: - Private Configuration Methods

private func configureDatabase(_ app: Application) throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(
        configuration: .init(
            port: AppConfiguration.Database.port,
            hostname: AppConfiguration.Database.hostname,
            username: AppConfiguration.Database.username,
            password: AppConfiguration.Database.password
        )
    ), as: .psql)
}

private func configureViewEngine(_ app: Application) {
    if AppConfiguration.Features.enableLeaf {
        app.views.use(.leaf)
    }
}

private func configureRoutes(_ app: Application) throws {
    do {
        try routes(app)
    } catch {
        app.logger.report(error: error)
        throw error
    }
}