import SwiftUI
import FirebaseDatabase

struct QRCodeEditView: View {
    @Environment(\.presentationMode) var presentationMode
    var qrCode: QRCode

    @State private var name: String
    @State private var description: String
    @State private var status: String

    init(qrCode: QRCode) {
        self.qrCode = qrCode
        _name = State(initialValue: qrCode.name)
        _description = State(initialValue: qrCode.description)
        _status = State(initialValue: qrCode.status)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit QR Info")) {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                Picker("Status", selection: $status) {
                    Text("Active").tag("active")
                    Text("Inactive").tag("inactive")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .navigationTitle("Edit QR Code")
    }

    func saveChanges() {
        let ref = Database.database().reference()
            .child("qr_codes")
            .child(qrCode.id)

        let timestamp = Date().timeIntervalSince1970 * 1000 // milliseconds

        let updatedData: [String: Any] = [
            "name": name,
            "description": description,
            "status": status,
            "timestamp": timestamp
        ]

        ref.updateChildValues(updatedData) { error, _ in
            if let error = error {
                print("Error updating QR Code: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}



