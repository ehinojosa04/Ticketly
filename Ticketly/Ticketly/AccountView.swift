import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct AccountView: View {
    @State private var name = ""
    @State private var lastname = ""
    @State private var major = ""
    @State private var semester = ""
    @State private var save_attempt = false
    @State private var save_success = false
    @State private var logout_attempt = false
    @State private var logout_success = false
    @State private var error: FirebaseError?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Account Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Update your personal details")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 16)

                    Group {
                        TextField("Name", text: $name)
                        TextField("Lastname", text: $lastname)
                        TextField("Major", text: $major)
                        TextField("Semester", text: $semester)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.words)

                    Button(action: { save_attempt = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Changes")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }

                    Button(action: { logout_attempt = true }) {
                        HStack {
                            Image(systemName: "arrow.backward.circle")
                            Text("Log Out")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadUserInfo()
            }
            .alert(item: $error) { err in
                Alert(title: Text("Error"),
                      message: Text(err.message),
                      dismissButton: .default(Text("OK")))
            }
            .alert("Save Changes?", isPresented: $save_attempt) {
                Button("Yes", action: saveUserInfo)
                Button("Cancel", role: .cancel) { save_attempt = false }
            } message: {
                Text("Are you sure you want to update your profile?")
            }
            .alert("Log Out?", isPresented: $logout_attempt) {
                Button("Yes", action: logout)
                Button("Cancel", role: .cancel) { logout_attempt = false }
            } message: {
                Text("This will log you out of Ticketly.")
            }
            .navigationDestination(isPresented: $save_success) {
                HomeView().navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $logout_success) {
                ContentView().navigationBarBackButtonHidden(true)
            }
        }
    }

    func loadUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)

        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                self.name = data["name"] as? String ?? ""
                self.lastname = data["lastname"] as? String ?? ""
                self.major = data["major"] as? String ?? ""
                self.semester = data["semester"] as? String ?? ""
            }
        }
    }

    func saveUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)

        let updatedData: [String: Any] = [
            "name": name,
            "lastname": lastname,
            "major": major,
            "semester": semester
        ]

        ref.updateChildValues(updatedData) { error, _ in
            if let error = error {
                self.error = FirebaseError(message: error.localizedDescription)
            } else {
                self.save_success = true
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            logout_success = true
        } catch {
            self.error = FirebaseError(message: "Error signing out: \(error.localizedDescription)")
        }
    }
}



#Preview {
    AccountView()
}
