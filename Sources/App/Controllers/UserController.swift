import Vapor
import Fluent

/// A controller responsible for handling user-related routes and actions.
///
/// This controller conforms to the `RouteCollection` protocol and defines
/// routes for creating, retrieving, updating, and deleting users.
///
/// - Methods:
///   - `boot(routes:)`: Registers the user-related routes with the provided `RoutesBuilder`.
///
/// The routes are grouped under the "users" path and are protected by the `UserModel.authenticator()`.
///
/// - Routes:
///   - POST /users: Calls the `create` method to create a new user.
///   - GET /users/:userID: Calls the `get` method to retrieve a user by their ID.
///   - PUT /users/:userID: Calls the `update` method to update a user by their ID.
///   - DELETE /users/:userID: Calls the `delete` method to delete a user by their ID.
struct UserController: RouteCollection {
    // MARK: - RouteCollection Conformance
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users").grouped(UserModel.authenticator())
        users.post(use: create)
        users.get(":userID", use: get)
        users.put(":userID", use: update)
        users.delete(":userID", use: delete)
    }

    // MARK: - Controller Methods
    // Create a new user
    func create(req: Request) throws -> EventLoopFuture<UserModel> {
        let user = try req.content.decode(UserModel.self)
        return user.save(on: req.db).map { user }
    }

    // Retrieve a user by ID
    func get(req: Request) throws -> EventLoopFuture<UserModel> {
        UserModel.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // Update a user by ID
    func update(req: Request) throws -> EventLoopFuture<UserModel> {
        let updatedUser = try req.content.decode(UserModel.self)
        return UserModel.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
                user.name = updatedUser.name
                user.email = updatedUser.email
                return user.save(on: req.db).map { user }
            }
    }

    // Delete a user by ID
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        UserModel.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
                user.delete(on: req.db).transform(to: .noContent)
            }
    }
}
