import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = QRCodeGeneratorViewModel()
    
    var body: some View {
        Group {
            if let user_id = Auth.auth().currentUser?.uid {
                NavigationStack {
                    VStack(spacing: 0) {
                        HStack {
                            NavigationLink(destination: AccountView()) {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.mint)
                            }
                            
                            Spacer()
                            
                            Text("Ticketly")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink(destination: QRCodeGeneratorView()) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.mint)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .overlay(
                            Divider(), alignment: .bottom
                        )

                        if viewModel.qrCodes.isEmpty {
                            Spacer()
                            ProgressView("Loading your tickets...")
                                .padding()
                            Spacer()
                        } else {
                            List {
                                ForEach(viewModel.qrCodes.filter { $0.status.lowercased() == "active" || $0.status.lowercased() == "inactive" }) { qrCode in
                                    NavigationLink(destination: QRCodeDetailView(qrCode: qrCode)) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(qrCode.name)
                                                .font(.headline)

                                            Text(qrCode.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)

                                            HStack {
                                                Label(qrCode.status.capitalized, systemImage: qrCode.status.lowercased() == "active" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .foregroundColor(qrCode.status.lowercased() == "active" ? .green : .red)
                                                    .font(.caption)

                                                Spacer()

                                                Text(formatDate(qrCode.timestamp))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                    .onAppear {
                        viewModel.fetchQRCodes(for: user_id)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("You must be logged in to view this page.")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                .padding()
            }
        }
    }
    
    func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
