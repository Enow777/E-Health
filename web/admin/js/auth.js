import { auth, db } from './firebase-config.js';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js';
import {
  doc,
  getDoc,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

/**
 * Call on every protected page.
 * onUser(user, adminDoc) fires when a verified admin is signed in.
 * Redirects to index.html if not signed in or not admin role.
 */
export function requireAdmin(onUser) {
  onAuthStateChanged(auth, async (user) => {
    if (!user) { window.location.href = 'index.html'; return; }
    try {
      const roleSnap = await getDoc(doc(db, 'userRoles', user.uid));
      if (!roleSnap.exists() || roleSnap.data().role !== 'admin') {
        await signOut(auth);
        window.location.href = 'index.html?error=unauthorized';
        return;
      }
      const adminDoc = { uid: user.uid, email: user.email };
      onUser(user, adminDoc);
    } catch (err) {
      console.error('Auth check failed', err);
      window.location.href = 'index.html?error=auth_error';
    }
  });
}

export async function signIn(email, password) {
  const cred = await signInWithEmailAndPassword(auth, email, password);
  const roleSnap = await getDoc(doc(db, 'userRoles', cred.user.uid));
  if (!roleSnap.exists() || roleSnap.data().role !== 'admin') {
    await signOut(auth);
    throw new Error('This account does not have admin access.');
  }
  return cred.user;
}

export function logout() {
  signOut(auth).then(() => { window.location.href = 'index.html'; });
}

export function redirectIfLoggedIn() {
  onAuthStateChanged(auth, async (user) => {
    if (!user) return;
    const roleSnap = await getDoc(doc(db, 'userRoles', user.uid));
    if (roleSnap.exists() && roleSnap.data().role === 'admin') {
      window.location.href = 'dashboard.html';
    }
  });
}
