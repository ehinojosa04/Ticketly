import {
  IonButton,
  IonContent,
  IonHeader,
  IonInput,
  IonItem,
  IonList,
  IonPage,
  IonTitle,
  IonToolbar,
  IonToast,
  IonSpinner,
} from "@ionic/react";
import { useState } from "react";
import { firebase } from "../../config";
import { useAuth } from "../contexts/auth";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [toastMessage, setToastMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const auth = useAuth();

  const handleLogin = async () => {
    if (!email || !password) {
      setToastMessage("Email and password are required");
      return;
    }

    try {
      setLoading(true);
      const success = await auth.login(email, password); // wait for full permission check

      if (success) {
        setToastMessage("✅ Login successful!");
        window.location.href = "/home"; // or use useHistory().push("/home");
      } else {
        setToastMessage("ℹ️ You must log in with an admin account.");
      }
    } catch (error: any) {
      setToastMessage(error.message || "Unexpected error");
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordReset = async () => {
    if (!email) {
      setToastMessage("Please enter your email first");
      return;
    }

    try {
      await firebase.auth().sendPasswordResetEmail(email);
      setToastMessage("📧 Password reset email sent.");
    } catch (error: any) {
      setToastMessage(error.message || "Could not send reset email.");
    }
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Login</IonTitle>
        </IonToolbar>
      </IonHeader>

      <IonContent fullscreen className="ion-padding">
        <IonList>
          <IonItem>
            <IonInput
              label="Email"
              labelPlacement="floating"
              type="email"
              placeholder="Enter email"
              value={email}
              onIonChange={(e) => setEmail(e.detail.value!)}
            />
          </IonItem>
          <IonItem>
            <IonInput
              label="Password"
              labelPlacement="floating"
              type="password"
              placeholder="Enter password"
              value={password}
              onIonChange={(e) => setPassword(e.detail.value!)}
            />
          </IonItem>
        </IonList>

        <IonButton expand="block" onClick={handleLogin} disabled={loading}>
          {loading ? <IonSpinner name="dots" /> : "Login"}
        </IonButton>

        <IonButton expand="block" fill="clear" onClick={handlePasswordReset}>
          Forgot password?
        </IonButton>

        <IonToast
          isOpen={!!toastMessage}
          message={toastMessage}
          duration={2000}
          onDidDismiss={() => setToastMessage("")}
        />
      </IonContent>
    </IonPage>
  );
}
