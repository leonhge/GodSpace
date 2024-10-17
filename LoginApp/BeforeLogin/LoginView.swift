import SwiftUI
import Foundation

// MARK: - Utility Classes

final class Datenbank {
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
}

final class Login {
    var username: String
    var password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    init() {
        self.username = ""
        self.password = ""
    }
}

final class POST {
    var string: String

    init(datenbank: Datenbank, login: Login, aktion: String) {
        string = "loginUser=\(login.username)&loginPasswort=\(login.password)&datenbankPasswort=\(datenbank.password)&datenbankName=\(datenbank.name)&datenbankUser=\(datenbank.username)&aktion=\(aktion)"
    }

    init(datenbank: Datenbank, login: Login) {
        string = "loginUser=\(login.username)&loginPasswort=\(login.password)&datenbankPasswort=\(datenbank.password)&datenbankName=\(datenbank.name)&datenbankUser=\(datenbank.username)"
    }
}

// MARK: - Login Funktionalität


