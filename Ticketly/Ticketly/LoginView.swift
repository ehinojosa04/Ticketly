import SwiftUI
import FirebaseAuth

struct FirebaseError: Identifiable {
    let id = UUID()
    let message: String
}

struct LoginView: View {
    @State private var user_id: String = ""
    @State private var email: String = ""
    @State private var pwd: String = ""
    @State private var auth: Bool = false
    @State private var loginError: FirebaseError?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Ticketly")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.mint)
                    Text("We're glad to have you back")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    SecureField("Password", text: $pwd)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                Button(action: Login) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding(.horizontal, 30)
                
                NavigationLink("Create a new account", destination: SignInView())
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $auth) {
                HomeView().navigationBarBackButtonHidden()
            }
        }
        .alert(item: $loginError) { error in
            Alert(
                title: Text("Login Error"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func Login() {
        Auth.auth().signIn(withEmail: email, password: pwd) { authResult, error in
            if let error = error {
                loginError = FirebaseError(message: error.localizedDescription)
                return
            }
            
            if let user = authResult?.user {
                user_id = user.uid
                auth = true
            } else {
                loginError = FirebaseError(message: "Failed to retrieve user info.")
            }
        }
    }
}

#Preview {
    LoginView()
}
