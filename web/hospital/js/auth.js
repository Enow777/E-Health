/**
 * Authentication module – handles login, registration, and session management
 * for the Hospital Admin Portal.
 */

import { auth, db } from './firebase-config.js';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js';
import {
  doc, setDoc, getDoc, serverTimestamp,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import { showToast } from './app.js';

// ── Auth guard – call on every protected page ────────────────────────────────
export function requireAuth(onUser) {
  return onAuthStateChanged(auth, async (user) => {
    if (!user) { window.location.href = 'index.html'; return; }
    // Verify hospital role
    const roleSnap = await getDoc(doc(db, 'userRoles', user.uid));
    const role = roleSnap.data()?.role;
    if (role !== 'hospital') {
      await signOut(auth);
      window.location.href = 'index.html?error=access_denied';
      return;
    }
    const hospitalSnap = await getDoc(doc(db, 'hospitals', user.uid));
    if (!hospitalSnap.exists()) {
      await signOut(auth);
      window.location.href = 'index.html?error=no_hospital';
      return;
    }
    onUser(user, hospitalSnap.data());
  });
}

// ── Sign in ──────────────────────────────────────────────────────────────────
export async function signIn(email, password) {
  const cred = await signInWithEmailAndPassword(auth, email, password);
  const roleSnap = await getDoc(doc(db, 'userRoles', cred.user.uid));
  const role = roleSnap.data()?.role;
  if (role !== 'hospital') {
    await signOut(auth);
    throw new Error('This account is not registered as a hospital. Please use the mobile app to log in.');
  }
  return cred.user;
}

// ── Register hospital ────────────────────────────────────────────────────────
export async function registerHospital({ email, password, name, address, phone, type }) {
  const cred = await createUserWithEmailAndPassword(auth, email, password);
  const uid  = cred.user.uid;

  await Promise.all([
    setDoc(doc(db, 'hospitals', uid), {
      name, address, phone, type,
      email, adminUid: uid,
      createdAt: new Date().toISOString(),
      verified: false,
    }),
    setDoc(doc(db, 'userRoles', uid), {
      role: 'hospital',
      createdAt: new Date().toISOString(),
    }),
  ]);
  return cred.user;
}

// ── Sign out ─────────────────────────────────────────────────────────────────
export async function logout() {
  await signOut(auth);
  window.location.href = 'index.html';
}

// ── Redirect if already logged in (for login page) ──────────────────────────
export function redirectIfLoggedIn() {
  onAuthStateChanged(auth, async (user) => {
    if (!user) return;
    const roleSnap = await getDoc(doc(db, 'userRoles', user.uid));
    if (roleSnap.data()?.role === 'hospital') {
      window.location.href = 'dashboard.html';
    }
  });
}
