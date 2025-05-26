import SwiftUI
import Firebase
import FirebaseDatabase
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    @StateObject private var viewModel = QRCodeGeneratorViewModel()
    
    @State private var qrID: String?
    @State private var qrImage: UIImage?
    
    @State private var codeName: String = ""
    @State private var codeDescription: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""


    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Create a New QR Code")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Give it a name and description")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)

                Group {
                    TextField("Code Name", text: $codeName)
                    TextField("Code Description", text: $codeDescription)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                Button(action: generateQR) {
                    Text("Generate QR Code")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                }
                .padding(.horizontal)

                if let qrImage = qrImage {
                    VStack(spacing: 12) {
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        if let qrID = qrID {
                            Text("QR ID: \(qrID)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("New QR")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("QR Code Generation"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }

    }

    private func generateQR() {
        viewModel.generateQRCode(
            status: "inactive",
            name: codeName.isEmpty ? "My QR Code" : codeName,
            description: codeDescription
        ) { newID in
            if let newID = newID {
                self.qrID = newID
                self.qrImage = viewModel.createQRCodeImage(from: newID)
                self.alertMessage = "QR code successfully generated!"
            } else {
                self.alertMessage = "Failed to generate QR code. Please try again."
            }
            self.showAlert = true
        }
    }

}
