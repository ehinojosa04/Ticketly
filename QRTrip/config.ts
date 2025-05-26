import firebase from "firebase/compat/app";
import "firebase/compat/auth";
import "firebase/compat/database"

export const firebaseConfig = {
  apiKey: "AIzaSyBXXDbUPUgjg5sdOeY1DIN0h2Ax1QRIgpU",
  authDomain: "public-transportation-9411a.firebaseapp.com",
  databaseURL:
    "https://public-transportation-9411a-default-rtdb.firebaseio.com",
  projectId: "public-transportation-9411a",
  storageBucket: "public-transportation-9411a.firebasestorage.app",
  messagingSenderId: "229683155001",
  appId: "1:229683155001:web:1162cdf04f2b1adce47de8",
};

const app = !firebase.apps.length
  ? firebase.initializeApp(firebaseConfig)
  : firebase.app();

const auth = firebase.auth(app);
const database = firebase.database();

export { firebase, auth, database };

export const secondaryApp = firebase.initializeApp(firebaseConfig, "Secondary");
export const secondaryAuth = secondaryApp.auth();