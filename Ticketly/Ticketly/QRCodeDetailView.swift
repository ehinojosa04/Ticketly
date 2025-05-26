import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeDetailView: View {
    var qrCode: QRCode
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(qrCode.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Label(qrCode.status.capitalized,
                          systemImage: qrCode.status.lowercased() == "active" ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(qrCode.status.lowercased() == "active" ? .green : .red)
                        .font(.subheadline)
                }

                if let image = createQRCodeImage(from: qrCode.id) {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240, maxHeight: 240)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Text("⚠️ Failed to generate QR code")
                        .foregroundColor(.red)
                }


                if !qrCode.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(qrCode.description)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }


                Spacer()
            }
            .padding()
        }
        .navigationTitle("QR Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: QRCodeEditView(qrCode: qrCode)) {
                    Text("Edit")
                        .fontWeight(.medium)
                        .foregroundColor(.mint)
                }
            }
        }
    }

    func createQRCodeImage(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        let transform = CGAffineTransform(scaleX: 10, y: 10)

        if let outputImage = filter.outputImage?.transformed(by: transform) {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}
