import {
    IonModal,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonInput,
    IonItem,
    IonLabel,
    IonButton,
    IonList,
    IonText,
    IonSelect,
    IonSelectOption,
} from "@ionic/react";
import { useState } from "react";
import { secondaryAuth, database } from "../../config";


interface Props {
    isOpen: boolean;
    onDismiss: () => void;
}

export default function CreateProfileModal({ isOpen, onDismiss }: Props) {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [role, setRole] = useState<"users" | "admins" | "tourniquets">("tourniquets");
    const [error, setError] = useState("");

    const handleCreate = async () => {
        if (!email.trim() || !password.trim()) {
            setError("Email and password are required.");
            return;
        }

        try {
            const userCredential = await secondaryAuth.createUserWithEmailAndPassword(email, password);
            const uid = userCredential.user?.uid;

            await database.ref(`${role}/${uid}`).set({ email });

            setEmail("");
            setPassword("");
            setRole("tourniquets");
            setError("");
            onDismiss();
        } catch (err: any) {
            console.error("Error creating user:", err);
            setError(err.message || "Failed to create user.");
        }
    };

    return (
        <IonModal isOpen={isOpen} onDidDismiss={onDismiss}>
            <IonHeader>
                <IonToolbar>
                    <IonTitle>Create User</IonTitle>
                </IonToolbar>
            </IonHeader>

            <IonContent className="ion-padding">
                <IonList>
                    <IonItem>
                        <IonLabel position="stacked">Email</IonLabel>
                        <IonInput
                            type="email"
                            value={email}
                            onIonChange={(e) => setEmail(e.detail.value!)}
                            placeholder="Enter email"
                            required
                        />
                    </IonItem>

                    <IonItem>
                        <IonLabel position="stacked">Password</IonLabel>
                        <IonInput
                            type="password"
                            value={password}
                            onIonChange={(e) => setPassword(e.detail.value!)}
                            placeholder="Enter password"
                            required
                        />
                    </IonItem>

                    <IonItem>
                        <IonLabel position="stacked">Role</IonLabel>
                        <IonSelect value={role} placeholder="Select Role" onIonChange={(e) => setRole(e.detail.value)}>
                            <IonSelectOption value="tourniquets">Torniquete</IonSelectOption>
                            <IonSelectOption value="users">User</IonSelectOption>
                            <IonSelectOption value="admins">Admin</IonSelectOption>
                        </IonSelect>
                    </IonItem>
                </IonList>

                {error && (
                    <IonText color="danger">
                        <p style={{ paddingLeft: "16px" }}>{error}</p>
                    </IonText>
                )}

                <IonButton expand="block" onClick={handleCreate}>
                    Create
                </IonButton>
                <IonButton expand="block" fill="clear" onClick={onDismiss}>
                    Cancel
                </IonButton>
            </IonContent>
        </IonModal>
    );
}
