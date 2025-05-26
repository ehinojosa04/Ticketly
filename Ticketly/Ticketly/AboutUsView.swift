import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.mint)

                    Text("About Ticketly")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Simple, fast, and secure QR ticketing.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    Text("What is Ticketly?")
                        .font(.headline)
                        .foregroundColor(.mint)

                    Text("""
Ticketly is a mobile-first public transportation solution that allows you to generate and manage QR code tickets with ease. Whether you're a student, commuter, or just hopping on the next ride — we've got you covered.

Designed for speed and simplicity, Ticketly helps eliminate paper waste, streamline your daily commute, and keep your data secure.
""")

                    Text("Our Mission")
                        .font(.headline)
                        .foregroundColor(.mint)

                    Text("""
We're passionate about building sustainable, accessible tech for real-world mobility. Ticketly is crafted to empower everyday users with smart ticketing tools — all in your pocket.
""")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom)
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    AboutUsView()
}
