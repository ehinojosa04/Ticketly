import {
    IonModal,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonText,
    IonButton,
    IonListHeader,
    IonSpinner,
} from "@ionic/react";
import { useEffect, useState } from "react";
import { database } from "../../config";

interface Props {
    isOpen: boolean;
    onDismiss: () => void;
}

type Role = "users" | "admins" | "tourniquets";

interface User {
    email?: string;
    name?: string;
    lastname?: string;
    major?: string;
    semester?: string;
}

export default function UserListModal({ isOpen, onDismiss }: Props) {
    const [loading, setLoading] = useState(true);
    const [usersByRole, setUsersByRole] = useState<Record<Role, Record<string, User>>>({
        users: {},
        admins: {},
        tourniquets: {},
    });

    console.log(usersByRole)

    useEffect(() => {
        if (!isOpen) return;

        const roles: Role[] = ["users", "admins", "tourniquets"];
        const listeners: (() => void)[] = [];

        setLoading(true);

        roles.forEach((role) => {
            const ref = database.ref(role + "/");
            const listener = ref.on("value", (snapshot) => {
                setUsersByRole((prev) => ({
                    ...prev,
                    [role]: snapshot.val() || {},
                }));
            });
            listeners.push(() => ref.off("value", listener));
        });

        setLoading(false);

        return () => {
            listeners.forEach((unsubscribe) => unsubscribe());
        };
    }, [isOpen]);

    return (
        <IonModal isOpen={isOpen} onDidDismiss={onDismiss}>
            <IonHeader>
                <IonToolbar>
                    <IonTitle>All Users</IonTitle>
                </IonToolbar>
            </IonHeader>

            <IonContent className="ion-padding">
                {loading ? (
                    <IonSpinner name="dots" />
                ) : (
                    <>
                        {(["admins", "users", "tourniquets"] as Role[]).map((role) => (
                            <IonList key={role}>
                                <IonListHeader>
                                    <IonLabel>
                                        <strong>{role.charAt(0).toUpperCase() + role.slice(1)}</strong>
                                    </IonLabel>
                                </IonListHeader>
                                {Object.entries(usersByRole[role]).map(([id, user]) => (
                                    <IonItem key={id}>
                                        <IonLabel>
                                            {role === "users" ? (
                                                <>
                                                    <h2>{user.name ?? "Unnamed"} {user.lastname ?? ""}</h2>
                                                    <p>{user.email}</p>
                                                    <IonText color="medium">
                                                        {user.major && user.semester ? `${user.major} — Sem ${user.semester}` : ""}
                                                    </IonText>
                                                </>
                                            ) : (
                                                <>
                                                    <h2>{user.email}</h2>
                                                    <IonText color="medium">ID: {id}</IonText>
                                                </>
                                            )}
                                        </IonLabel>
                                    </IonItem>
                                ))}

                            </IonList>
                        ))}
                    </>
                )}
                <IonButton expand="block" fill="clear" onClick={onDismiss}>
                    Close
                </IonButton>
            </IonContent>
        </IonModal>
    );
}
