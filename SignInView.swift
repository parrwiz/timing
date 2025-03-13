import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Arkan Community")
                .font(.title)
                .bold()
            
            GoogleSignInButton(action: signInWithGoogle)
                .frame(height: 50)
                .padding(.horizontal, 40)

            Button(action: { showEmailSignIn() }) {
                Text("Continue with Email")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }

            Button(action: signInAnonymously) {
                Text("Continue as Guest")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    private func signInWithGoogle() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        AuthService.shared.signInWithGoogle(presentingViewController: rootViewController) { success, error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func showEmailSignIn() {
        // Navigate to Email Sign-In View (implement separately)
    }

    private func signInAnonymously() {
        AuthService.shared.signInAnonymously { success, error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}
