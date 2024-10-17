import Foundation
import SwiftUI

class UserProfileModel: ObservableObject {
    @Published var Id: Int?
    @Published var username: String
    @Published var name: String
    @Published var email: String
    @Published var phoneNumber: String
    @Published var bio: String
    @Published var profileImageData: Data?
    @Published var profileImageURL: String?

    init(username: String = "", name: String = "", email: String = "", phoneNumber: String = "", bio: String = "", profileImageData: Data? = nil, profileImageURL: String? = nil) {
        self.username = username
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.bio = bio
        self.profileImageData = profileImageData
        self.profileImageURL = profileImageURL
    }

    func getProfileImage() -> UIImage? {
        if let data = profileImageData {
            return UIImage(data: data)
        }
        return nil
    }

    func loadUserData(username: String) {
        guard let url = URL(string: "http://www.elliceleft.de/uploads/uploadProfileImage.php/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let postString = "username=\(username)"
        request.httpBody = postString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.username = jsonResponse["username"] as? String ?? self.username
                        self.name = jsonResponse["name"] as? String ?? self.name
                        self.email = jsonResponse["email"] as? String ?? self.email
                        self.phoneNumber = jsonResponse["phoneNumber"] as? String ?? self.phoneNumber
                        self.bio = jsonResponse["bio"] as? String ?? self.bio

                        if let profileImageURLString = jsonResponse["profileImageURL"] as? String {
                            self.profileImageURL = profileImageURLString
                            if let profileImageURL = URL(string: profileImageURLString) {
                                self.loadProfileImage(from: profileImageURL)
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        task.resume()
    }

    private func loadProfileImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching profile image: \(error)")
                return
            }

            guard let data = data else { return }

            DispatchQueue.main.async {
                self.profileImageData = data
            }
        }

        task.resume()
    }
}
