import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    @State private var signinError: FirebaseError?
    @State private var auth: Bool = false
    @State private var goToLogin: Bool = false

    @State private var email: String = ""
    @State private var pwd: String = ""
    @State private var name: String = ""
    @State private var lastname: String = ""
    @State private var major: String = ""
    @State private var semester: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)
                    
                    VStack(spacing: 8) {
                        Text("🎫 Ticketly")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.mint)
                        
                        Text("Create your account and get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                        
                        SecureField("Password", text: $pwd)
                            .textContentType(.newPassword)
                        
                        TextField("First Name", text: $name)
                        TextField("Last Name", text: $lastname)
                        TextField("Major", text: $major)
                        TextField("Semester", text: $semester)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                    Button(action: SignIn) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    // Navigate to login
                    NavigationLink("Already have an account? Login", destination: LoginView())
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationDestination(isPresented: $goToLogin) {
                LoginView()
            }
            .alert(item: $signinError) { error in
                Alert(
                    title: Text("Sign In Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $auth) {
                Alert(
                    title: Text("Success"),
                    message: Text("Welcome to Ticketly!"),
                    dismissButton: .default(Text("Go to Login")) {
                        goToLogin = true
                    }
                )
            }
        }
    }
    
    func SignIn() {
        Auth.auth().createUser(withEmail: email, password: pwd) { authResult, error in
            if let error = error {
                signinError = FirebaseError(message: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                signinError = FirebaseError(message: "Could not retrieve user ID.")
                return
            }
            
            let ref = Database.database().reference()
            let usersRef = ref.child("users").child(uid)
            
            let userData: [String: Any] = [
                "email": email,
                "name": name,
                "lastname": lastname,
                "major": major,
                "semester": semester
            ]
            
            usersRef.setValue(userData) { error, _ in
                if let error = error {
                    signinError = FirebaseError(message: error.localizedDescription)
                } else {
                    auth = true
                }
            }
        }
    }
}


#Preview {
    SignInView()
}
