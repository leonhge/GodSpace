import SwiftUI

struct ProfileView: View {
    @Binding var userProfile: UserProfileModel
    @StateObject private var appState = AppState()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Username oben links im Eck
            Text(appState.loggedInUsername ?? "Unbekannter Benutzer")
                .font(.title)
                .padding([.top, .leading])
                .onAppear {
                    print("Username displayed: \(appState.loggedInUsername ?? "Unbekannter Benutzer")")
                    // Bild-URL beim Anzeigen abrufen
                    if let id = appState.id {
                        appState.fetchProfileImageURL(for: id)
                    }
                }
            
            // Profilbild des Nutzers
            Button(action: {
                showImagePicker.toggle()
                print("ImagePicker toggled. Show ImagePicker: \(showImagePicker)")
            }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding([.leading, .trailing])
                        .onAppear {
                            print("Selected Image displayed.")
                        }
                } else if let imageURLString = appState.profileImageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding([.leading, .trailing])
                            .onAppear {
                                print("Profile Image displayed from URL: \(imageURLString)")
                            }
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding([.leading, .trailing])
                            .onAppear {
                                print("Placeholder image displayed.")
                            }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing])
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                    .onAppear {
                        print("ImagePicker sheet presented.")
                    }
            }
            
            // Optional: Name des Nutzers anzeigen, wenn er sich vom Benutzernamen unterscheidet
            if let userName = appState.loggedInUsername, !userName.isEmpty {
                Text(userName)
                    .font(.headline)
                    .padding([.leading, .trailing])
                    .onAppear {
                        print("User's name displayed: \(userName)")
                    }
            }
            
            // Telefonnummer des Nutzers (Diese Info sollte entweder in AppState oder UserProfileModel gespeichert werden)
            Text(userProfile.phoneNumber)
                .font(.subheadline)
                .padding([.leading, .trailing])
            
            // Bio des Nutzers (Diese Info sollte entweder in AppState oder UserProfileModel gespeichert werden)
            Text(userProfile.bio)
                .font(.body)
                .padding([.leading, .trailing, .bottom])

            Spacer()
        }
        .onChange(of: selectedImage) { oldImage, newImage in
            if let image = newImage {
                print("Selected Image changed.")
                if let id = appState.id {
                    uploadImage(image, Id: id)
                } else {
                    print("User ID not available.")
                }
            } else {
                print("No new image selected.")
            }
        }
        .onAppear {
            print("ProfileView appeared.")
            // Wenn AppState geladen wird, holen Sie die Benutzerdaten
        }
    }
    
    private func uploadImage(_ image: UIImage, Id: Int) {
        print("Uploading image for user ID: \(Id)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to JPEG data")
            return
        }
        print("Image converted to JPEG data.")
        
        let uuid = UUID().uuidString
        let fileName = "\(uuid).jpg" // Verwende UUID als Dateinamen
        print("Generated file name: \(fileName)")
        
        let url = URL(string: "http://www.elliceleft.de/uploads/uploadProfileImage.php")!
        print("Upload URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        print("Request Content-Type: multipart/form-data; boundary=\(boundary)")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"action\"\r\n\r\n".data(using: .utf8)!)
        body.append("uploadProfileImage\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"Id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(Id)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("Request body prepared.")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                print("Response headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(responseString)")
            }
            
            do {
                if let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server Response: \(responseJson)")
                    
                    if let imageUrl = responseJson["profileImageURL"] as? String {
                        DispatchQueue.main.async {
                            appState.profileImageURL = imageUrl
                            print("Image URL updated: \(imageUrl)")
                        }
                    } else if let error = responseJson["error"] as? String {
                        print("Server Error: \(error)")
                    }
                } else {
                    print("Error: Response is not in expected JSON format")
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
