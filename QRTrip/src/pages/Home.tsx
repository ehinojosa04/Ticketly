import {
  IonPage,
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButton,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardContent,
  IonLabel,
  IonText,
  IonChip,
  IonGrid,
  IonRow,
  IonCol,
  IonIcon,
} from "@ionic/react";
import { qrCodeOutline, logOutOutline, peopleOutline, walkOutline } from 'ionicons/icons';
import { useAuth } from "../contexts/auth";
import { useEffect, useState } from "react";
import { v4 } from "uuid";
import { firebase, database } from "../../config";
import CreateQrModal from "../components/CreateQRModal";
import "./Home.css";
import UserListModal from "../components/UserListModal";
import CreateTorniqueteModal from "../components/CreateProfileModal";

type QR_CODE = {
  description: string;
  name: string;
  status: "active" | "inactive" | "used" | "generated" | "not_generated";
  timestamp: string;
  user_id?: string;
};

function listenToQrCodes(onUpdate: (data: Record<string, QR_CODE>) => void) {
  const ref = database.ref("qr_codes");
  const listener = ref.on("value", (snapshot) => {
    const data = snapshot.val() || {};
    onUpdate(data);
  });
  return () => ref.off("value", listener);
}

export default function Home() {
  const { user, logout } = useAuth();
  const [qrCodes, setQrCodes] = useState<Record<string, QR_CODE>>({});
  const [showModal, setShowModal] = useState(false);
  const [showUserModal, setShowUserModal] = useState(false);
  const [showTorniqueteModal, setShowTorniqueteModal] = useState(false);

  function createQrCode(data: { name: string; description: string }) {
    try {
      const id = v4();
      database.ref("qr_codes/" + id).set({
        ...data,
        status: "generated",
        timestamp: firebase.database.ServerValue.TIMESTAMP,
      } as QR_CODE);
    } catch (error) {
      console.error("Error creating QR code:", error);
      throw error;
    }
  }

  useEffect(() => {
    const unsubscribe = listenToQrCodes((data) => {
      setQrCodes(data);
    });

    return () => {
      unsubscribe();
    };
  }, []);

  return (
    <IonPage>
      <CreateQrModal
        isOpen={showModal}
        onDismiss={() => setShowModal(false)}
        onSubmit={(data) => {
          createQrCode(data);
          setShowModal(false);
        }}
      />

      <UserListModal
        isOpen={showUserModal}
        onDismiss={() => setShowUserModal(false)}
      />

      <CreateTorniqueteModal
        isOpen={showTorniqueteModal}
        onDismiss={() => setShowTorniqueteModal(false)}
      />

      <IonHeader>
        <IonToolbar>
          <IonTitle>Dashboard</IonTitle>
        </IonToolbar>
      </IonHeader>

      <IonContent className="ion-padding">
        <IonGrid>
          <IonRow className="home-header-row ion-align-items-center ion-justify-content-between">
            <IonCol size="12">
              <h2>Welcome, {user?.email}</h2>
            </IonCol>
            <IonCol size="6" size-md="3">
              <IonButton expand="block" color="danger" onClick={logout}>
                <IonIcon slot="start" icon={logOutOutline} />
                Log Out
              </IonButton>
            </IonCol>
            <IonCol size="6" size-md="3">
              <IonButton expand="block" onClick={() => setShowModal(true)}>
                <IonIcon slot="start" icon={qrCodeOutline} />
                Create QR Code
              </IonButton>
            </IonCol>
            <IonCol size="6" size-md="3">
              <IonButton expand="block" onClick={() => setShowUserModal(true)}>
                <IonIcon slot="start" icon={peopleOutline} />
                View Users
              </IonButton>
            </IonCol>
            <IonCol size="6" size-md="3">
              <IonButton expand="block" onClick={() => setShowTorniqueteModal(true)}>
                <IonIcon slot="start" icon={walkOutline} />
                Create Profile
              </IonButton>
            </IonCol>
          </IonRow>


          <IonRow className="qr-card-grid">
            {Object.entries(qrCodes).map(([id, info]) => (
              <IonCol key={id} className="qr-col">
                <IonCard className="qr-card">
                  <IonCardHeader>
                    <IonCardTitle>{info.name}</IonCardTitle>
                  </IonCardHeader>
                  <IonCardContent>
                    <IonText color="medium">
                      {info.description || <i>No description</i>}
                    </IonText>
                    <div className="qr-card-footer">
                      <IonChip className={`status-chip ${info.status}`}>
                        {info.status}
                      </IonChip>
                      <IonLabel className="qr-id">ID: {id}</IonLabel>
                    </div>
                  </IonCardContent>
                </IonCard>
              </IonCol>
            ))}
          </IonRow>
        </IonGrid>
      </IonContent>
    </IonPage>
  );
}
