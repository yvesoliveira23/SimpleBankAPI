import Fluent
import Vapor

final class UserModel: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "cpf")
    var encryptedCpf: String

    @Field(key: "email")
    var email: String
    
    @Field(key: "passwordHash")
    var passwordHash: String
    
    @Field(key: "balance")
    var balanceValue: Double

    @Field(key: "isMerchant")
    var isMerchant: Bool

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
}
