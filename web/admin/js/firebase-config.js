import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js';
import { getAuth }        from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js';
import { getFirestore }   from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

const firebaseConfig = {
  apiKey:            'AIzaSyAfibzxBlB_pzwOCk291mfb1E3X3iO_9SQ',
  authDomain:        'swiva-257eb.firebaseapp.com',
  projectId:         'swiva-257eb',
  storageBucket:     'swiva-257eb.firebasestorage.app',
  messagingSenderId: '137301333148',
  appId:             '1:137301333148:web:f1f823f86f6eb2232b4959',
};

const app  = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db   = getFirestore(app, 'ehealthdatabase');

export { app, auth, db };
