import Fluent
import Vapor

/// Represents a user in the system
final class UserModel: Model, Content, Equatable {
    // MARK: - Schema
    
    /// The database schema for the user model
    static let schema = "users"
    
    // MARK: - Properties
    
    /// Unique identifier for the user
    @ID(key: .id)
    var id: UUID?
    
    /// User's full name
    @Field(key: "name")
    private(set) var name: String
    
    /// User's encrypted CPF (Brazilian tax ID)
    @Field(key: "cpf")
    private(set) var encryptedCpf: String
    
    /// User's email address
    @Field(key: "email")
    private(set) var email: String
    
    /// Hashed version of user's password
    @Field(key: "passwordHash")
    private(set) var passwordHash: String
    
    /// User's current balance
    @Field(key: "balance")
    private(set) var balanceValue: Double
    
    /// Indicates if the user is a merchant
    @Field(key: "isMerchant")
    private(set) var isMerchant: Bool
    
    // MARK: - Initialization
    
    /// Creates an empty user model
    init() { }
    
    /// Creates a new user with the specified properties
    /// - Parameters:
    ///   - id: Optional unique identifier
    ///   - name: User's full name
    ///   - cpf: User's CPF number
    ///   - email: User's email address
    ///   - passwordHash: Hashed version of user's password
    ///   - balance: Initial account balance
    ///   - isMerchant: Whether the user is a merchant
    init(
        id: UUID? = nil,
        name: String,
        cpf: String,
        email: String,
        passwordHash: String,
        balance: Double,
        isMerchant: Bool
    ) {
        self.id = id
        self.name = name
        self.encryptedCpf = cpf
        self.email = email
        self.passwordHash = passwordHash
        self.balanceValue = balance
        self.isMerchant = isMerchant
    }
    
    // MARK: - Equatable
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        lhs.id == rhs.id && // If ID is truly unique, this might be enough
        lhs.email == rhs.email &&
        lhs.encryptedCpf == rhs.encryptedCpf
    }
}