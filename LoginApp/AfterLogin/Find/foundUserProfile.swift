
import SwiftUI

struct UserProfileView: View {
    let user: User
    let profileImage: Image
    let bio: String

    var body: some View {
            VStack(spacing: 20) {
                // Benutzername
                Text(user.name)
                    .font(.largeTitle)
                    .padding(.top)
                
                // Profilbild
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                
                // Biografie
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            
            Spacer()
        }
    }

