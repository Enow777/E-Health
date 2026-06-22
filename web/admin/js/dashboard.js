import { db } from './firebase-config.js';
import { requireAdmin, logout } from './auth.js';
import { initSidebar, formatDate, escapeHtml, avatarHtml, statusBadge } from './app.js';
import {
  collection, query, getDocs, orderBy, limit, where, onSnapshot,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

requireAdmin(async () => {
  initSidebar();
  document.getElementById('logout-btn').addEventListener('click', logout);

  // ── Live counters ──────────────────────────────────────────────────────────
  const statIds = {
    hospitals: 'stat-hospitals',
    doctors:   'stat-doctors',
    patients:  'stat-patients',
    appts:     'stat-appointments',
  };

  const snap = await getDocs(collection(db, 'userRoles'));
  let hospitals = 0, doctors = 0, patients = 0;
  snap.forEach((d) => {
    const r = d.data().role;
    if (r === 'hospital') hospitals++;
    else if (r === 'doctor') doctors++;
    else if (r === 'patient') patients++;
  });
  document.getElementById(statIds.hospitals).textContent = hospitals;
  document.getElementById(statIds.doctors).textContent   = doctors;
  document.getElementById(statIds.patients).textContent  = patients;

  const apptSnap = await getDocs(collection(db, 'appointments'));
  document.getElementById(statIds.appts).textContent = apptSnap.size;

  // ── Pending doctors (needing approval from any hospital) ───────────────────
  const pendingQ = query(
    collection(db, 'doctorProfiles'),
    where('approvalStatus', '==', 'pending'),
    orderBy('createdAt', 'desc'),
    limit(10),
  );
  onSnapshot(pendingQ, (snap) => {
    const tbody = document.getElementById('pending-doctors-tbody');
    if (!tbody) return;
    if (snap.empty) {
      tbody.innerHTML = '<tr><td colspan="4" class="empty-cell">No pending requests</td></tr>';
      return;
    }
    tbody.innerHTML = snap.docs.map((d) => {
      const p = d.data();
      return `<tr>
        <td>${avatarHtml(p.fullName)} <span>${escapeHtml(p.fullName || '—')}</span></td>
        <td>${escapeHtml(p.hospitalName || '—')}</td>
        <td>${formatDate(p.createdAt)}</td>
        <td>${statusBadge('pending')}</td>
      </tr>`;
    }).join('');
  });

  // ── Recently registered hospitals ──────────────────────────────────────────
  const hospQ = query(collection(db, 'hospitals'), orderBy('createdAt', 'desc'), limit(8));
  onSnapshot(hospQ, (snap) => {
    const tbody = document.getElementById('recent-hospitals-tbody');
    if (!tbody) return;
    if (snap.empty) {
      tbody.innerHTML = '<tr><td colspan="3" class="empty-cell">No hospitals yet</td></tr>';
      return;
    }
    tbody.innerHTML = snap.docs.map((d) => {
      const h = d.data();
      return `<tr>
        <td>${avatarHtml(h.name, '#059669')} <span>${escapeHtml(h.name || '—')}</span></td>
        <td>${escapeHtml(h.type || '—')}</td>
        <td>${formatDate(h.createdAt)}</td>
      </tr>`;
    }).join('');
  });
});
