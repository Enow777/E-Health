import { db }       from './firebase-config.js';
import { requireAuth, logout } from './auth.js';
import {
  collection, query, where, onSnapshot, getDocs, orderBy, limit,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import { initSidebar, formatDate, timeAgo, avatarHtml, statusBadge, updateNavBadge, escapeHtml } from './app.js';

let hospitalId, hospitalData;
const unsubs = [];

requireAuth((user, hospital) => {
  hospitalId   = user.uid;
  hospitalData = hospital;
  init();
});

function init() {
  initSidebar();
  setHospitalName();
  wireLogout();
  subscribeStats();
  subscribeRecentDoctors();
  subscribeRecentAppointments();
  subscribeNotifBadge();
}

function setHospitalName() {
  document.querySelectorAll('.hospital-name').forEach(el => el.textContent = hospitalData.name || 'Hospital');
  const av = document.getElementById('sidebar-avatar');
  if (av) av.textContent = (hospitalData.name || 'H')[0].toUpperCase();
}

function wireLogout() {
  document.getElementById('logout-btn')?.addEventListener('click', logout);
}

// ── Stats ───────────────────────────────────────────────────────────────────
function subscribeStats() {
  // Pending approvals
  const pendingQ = query(
    collection(db, 'doctorProfiles'),
    where('hospitalId', '==', hospitalId),
    where('approvalStatus', '==', 'pending'),
  );
  unsubs.push(onSnapshot(pendingQ, snap => {
    setText('stat-pending', snap.size);
  }));

  // Approved doctors
  const approvedQ = query(
    collection(db, 'doctorProfiles'),
    where('hospitalId', '==', hospitalId),
    where('approvalStatus', '==', 'approved'),
  );
  unsubs.push(onSnapshot(approvedQ, snap => {
    setText('stat-doctors', snap.size);
    // Count patients across approved doctors
    if (snap.size === 0) { setText('stat-patients', 0); return; }
    const doctorIds = snap.docs.map(d => d.id);
    countPatients(doctorIds);
  }));

  // Today's appointments
  const today = new Date().toISOString().slice(0, 10);
  const todayQ = query(
    collection(db, 'appointments'),
    where('date', '==', today),
  );
  unsubs.push(onSnapshot(todayQ, async snap => {
    // filter by hospital's doctors
    const approvedSnap = await getDocs(
      query(collection(db, 'doctorProfiles'), where('hospitalId', '==', hospitalId), where('approvalStatus', '==', 'approved'))
    );
    const ids = new Set(approvedSnap.docs.map(d => d.id));
    const count = snap.docs.filter(d => ids.has(d.data().doctorId)).length;
    setText('stat-appointments', count);
  }));
}

async function countPatients(doctorIds) {
  const chunks = [];
  for (let i = 0; i < doctorIds.length; i += 10) chunks.push(doctorIds.slice(i, i + 10));
  const sets = await Promise.all(chunks.map(chunk =>
    getDocs(query(collection(db, 'appointments'), where('doctorId', 'in', chunk)))
  ));
  const uniquePatients = new Set();
  sets.forEach(snap => snap.docs.forEach(d => uniquePatients.add(d.data().patientId)));
  setText('stat-patients', uniquePatients.size);
}

function setText(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

// ── Recent pending doctors ───────────────────────────────────────────────────
function subscribeRecentDoctors() {
  const q = query(
    collection(db, 'doctorProfiles'),
    where('hospitalId', '==', hospitalId),
    where('approvalStatus', '==', 'pending'),
  );
  unsubs.push(onSnapshot(q, rawSnap => {
    // Sort newest first and cap at 5 client-side (avoids composite index)
    const docs = [...rawSnap.docs]
      .sort((a, b) => (b.data().createdAt || '') > (a.data().createdAt || '') ? 1 : -1)
      .slice(0, 5);
    const snap = { docs, empty: docs.length === 0 };
    const container = document.getElementById('recent-pending');
    if (!container) return;
    if (snap.empty) {
      container.innerHTML = `<div class="empty-state" style="padding:32px">
        <span class="empty-icon material-icons">how_to_reg</span>
        <h3>No pending requests</h3>
        <p>All doctor requests have been reviewed.</p></div>`;
      return;
    }
    container.innerHTML = snap.docs.map(d => {
      const data = d.data();
      return `<tr>
        <td><div style="display:flex;align-items:center;gap:10px">
          ${avatarHtml(data.fullName, data.photoUrl, 36)}
          <div><div style="font-weight:600;font-size:.875rem">${escapeHtml(data.fullName)}</div>
          <div style="font-size:.75rem;color:var(--text-muted)">${escapeHtml((data.specialties || []).join(', ') || data.specialty || '—')}</div></div>
        </div></td>
        <td>${escapeHtml(data.clinic || '—')}</td>
        <td>${formatDate(data.createdAt)}</td>
        <td><span class="badge badge-pending"><span class="badge-dot"></span>Pending</span></td>
        <td><a href="doctors.html" class="btn btn-sm btn-primary">Review</a></td>
      </tr>`;
    }).join('');
  }));
}

// ── Recent appointments ──────────────────────────────────────────────────────
function subscribeRecentAppointments() {
  const q = query(
    collection(db, 'appointments'),
    orderBy('createdAt', 'desc'),
    limit(20),
  );
  unsubs.push(onSnapshot(q, async snap => {
    const approvedSnap = await getDocs(
      query(collection(db, 'doctorProfiles'), where('hospitalId', '==', hospitalId), where('approvalStatus', '==', 'approved'))
    );
    const ids = new Set(approvedSnap.docs.map(d => d.id));
    const rows = snap.docs.filter(d => ids.has(d.data().doctorId)).slice(0, 5);
    const container = document.getElementById('recent-appointments');
    if (!container) return;
    if (!rows.length) {
      container.innerHTML = `<div class="empty-state" style="padding:32px">
        <span class="empty-icon material-icons">event_busy</span>
        <h3>No appointments yet</h3></div>`;
      return;
    }
    container.innerHTML = rows.map(d => {
      const data = d.data();
      const doctorName = data.doctor?.fullName || data.doctor?.name || '—';
      return `<tr>
        <td>${escapeHtml(data.patientName || '—')}</td>
        <td>Dr. ${escapeHtml(doctorName)}</td>
        <td>${escapeHtml(data.date)} ${escapeHtml(data.time)}</td>
        <td>${statusBadge(data.status)}</td>
      </tr>`;
    }).join('');
  }));
}

// ── Notification badge ───────────────────────────────────────────────────────
function subscribeNotifBadge() {
  const q = query(
    collection(db, 'hospitals', hospitalId, 'notifications'),
    where('isRead', '==', false),
  );
  unsubs.push(onSnapshot(q, snap => updateNavBadge(snap.size)));
}
