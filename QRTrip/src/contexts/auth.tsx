// src/contexts/AuthContext.tsx
import React, { useContext, useEffect, useState, createContext } from "react";
import { firebase, auth, database } from "../../config";
import { useHistory } from "react-router-dom";

interface AuthContextType {
  user: firebase.User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true,
  login: async () => false,
  logout: async () => { },
  resetPassword: async () => { },
});

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [user, setUser] = useState<firebase.User | null>(null);
  const [loading, setLoading] = useState(true);
  const history = useHistory();

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(async (firebaseUser) => {
      if (!firebaseUser) {
        setUser(null);
        setLoading(false);
        return;
      }

      try {
        const uid = firebaseUser.uid;
        const adminSnapshot = await database.ref("admins/" + uid).get();

        if (!adminSnapshot.exists()) {
          console.warn("❌ User is not an admin, signing out.");
          await auth.signOut();
          setUser(null);
        } else {
          setUser(firebaseUser);
        }
      } catch (error) {
        console.error("Error during auth state check:", error);
        await auth.signOut();
        setUser(null);
      } finally {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const userCredential = await auth.signInWithEmailAndPassword(email, password);
      const uid = userCredential?.user?.uid;

      if (!uid) {
        console.warn("❌ No UID returned after login.");
        await auth.signOut();
        setUser(null);
        return false;
      }

      const adminSnapshot = await database.ref("admins/" + uid).get();

      if (!adminSnapshot.exists()) {
        console.warn("❌ User is not an admin, logging out.");
        await auth.signOut();
        setUser(null);
        return false;
      }

      // ✅ At this point we know the user is an admin
      setUser(userCredential.user);
      return true;

    } catch (error) {
      console.error("Login error:", error);
      setUser(null); // Ensure user state is cleared on failure
      return false;
    }
  };


  const logout = async () => {
    try {
      await auth.signOut();
      setUser(null);
      history.push("/");
    } catch (error) {
      console.error("Logout error:", error);
      throw error;
    }
  };

  const resetPassword = async (email: string) => {
    try {
      await auth.sendPasswordResetEmail(email);
    } catch (error) {
      console.error("Password reset error:", error);
      throw error;
    }
  };

  return (
    <AuthContext.Provider
      value={{ user, loading, login, logout, resetPassword }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
