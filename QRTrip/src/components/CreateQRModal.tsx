import {
    IonButton,
    IonContent,
    IonHeader,
    IonInput,
    IonItem,
    IonLabel,
    IonList,
    IonModal,
    IonTitle,
    IonToolbar,
} from "@ionic/react";
import { useState } from "react";

interface Props {
    isOpen: boolean;
    onDismiss: () => void;
    onSubmit: (data: { name: string; description: string }) => void;
}

export default function CreateQrModal({ isOpen, onDismiss, onSubmit }: Props) {
    const [name, setName] = useState("");
    const [description, setDescription] = useState("");

    const handleCreate = () => {
        if (name.trim()) {
            onSubmit({ name, description });
            setName("");
            setDescription("");
            onDismiss();
        }
    };

    return (
        <IonModal isOpen={isOpen} onDidDismiss={onDismiss}>
            <IonHeader>
                <IonToolbar>
                    <IonTitle>Create QR Code</IonTitle>
                </IonToolbar>
            </IonHeader>
            <IonContent className="ion-padding">
                <IonList>
                    <IonItem>
                        <IonLabel position="stacked">Name</IonLabel>
                        <IonInput
                            value={name}
                            placeholder="Enter name"
                            onIonChange={(e) => setName(e.detail.value!)}
                        />
                    </IonItem>
                    <IonItem>
                        <IonLabel position="stacked">Description</IonLabel>
                        <IonInput
                            value={description}
                            placeholder="Optional description"
                            onIonChange={(e) => setDescription(e.detail.value!)}
                        />
                    </IonItem>
                </IonList>
                <IonButton expand="block" onClick={handleCreate} disabled={!name}>
                    Create
                </IonButton>
                <IonButton expand="block" fill="clear" color="medium" onClick={onDismiss}>
                    Cancel
                </IonButton>
            </IonContent>
        </IonModal>
    );
}
