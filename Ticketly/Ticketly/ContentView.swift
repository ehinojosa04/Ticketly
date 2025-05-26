import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("🎫 Ticketly")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.mint)
                
                Text("Your Smart Ticket Companion")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                VStack(spacing: 16) {
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    
                    NavigationLink(destination: SignInView()) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color.mint)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.mint, lineWidth: 2)
                            )
                            .font(.headline)
                    }
                    
                    NavigationLink(destination: AboutUsView()) {
                        Text("Learn About Us")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .underline()
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ContentView()
}
