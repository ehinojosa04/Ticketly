import SwiftUI
import Firebase
import FirebaseDatabase
import CoreImage.CIFilterBuiltins
import FirebaseAuth

struct QRCode: Identifiable {
    let id: String
    let userID: String
    let status: String
    let name: String
    let description: String
    let timestamp: TimeInterval
}


class QRCodeGeneratorViewModel: ObservableObject {
    private let dbRef = Database.database().reference().child("qr_codes")
    
    @Published var qrCodes: [QRCode] = []

    func fetchQRCodes(for userID: String) {
        dbRef.queryOrdered(byChild: "user_id").queryEqual(toValue: userID)
            .observe(.value) { snapshot in
                var codes: [QRCode] = []
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let data = snap.value as? [String: Any],
                       let status = data["status"] as? String,
                       let name = data["name"] as? String,
                       let description = data["description"] as? String,
                       let timestamp = data["timestamp"] as? TimeInterval {
                        
                        let code = QRCode(
                            id: snap.key,
                            userID: userID,
                            status: status,
                            name: name,
                            description: description,
                            timestamp: timestamp
                        )
                        codes.append(code)
                    }
                }
                
                DispatchQueue.main.async {
                    self.qrCodes = codes.sorted { $0.timestamp > $1.timestamp }
                }
            }
    }

    func generateQRCode(status: String, name: String, description: String, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil) // also handle this case
            return
        }

        dbRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: [String: Any]] {
                if let existingQR = value.first(where: { $0.value["status"] as? String == "generated" }) {
                    let qrID = existingQR.key
                    let updateData: [String: Any] = [
                        "name": name,
                        "description": description,
                        "timestamp": ServerValue.timestamp(),
                        "status": status,
                        "user_id": uid
                    ]
                    self.dbRef.child(qrID).updateChildValues(updateData) { error, _ in
                        if let error = error {
                            print("❌ Error updating QR code: \(error.localizedDescription)")
                            completion(nil)
                        } else {
                            print("✅ Existing QR code updated: \(qrID)")
                            completion(qrID)
                        }
                    }
                    return
                }
            }

            completion(nil)
        }
    }




    
    func createQRCodeImage(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
