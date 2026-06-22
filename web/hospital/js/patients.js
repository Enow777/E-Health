import { db }                from './firebase-config.js';
import { requireAuth, logout } from './auth.js';
import {
  collection, query, where, onSnapshot, getDocs, doc, getDoc, orderBy,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import {
  initSidebar, showToast, avatarHtml, escapeHtml, formatDate, updateNavBadge,
} from './app.js';

let hospitalId, hospitalData;
let allPatients = [];
let filterDoctor = '';
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
  loadPatients();
  subscribeNotifBadge();
  document.getElementById('search-patients')?.addEventListener('input', render);
  document.getElementById('filter-doctor')?.addEventListener('change', e => { filterDoctor = e.target.value; render(); });
}

function setHospitalName() {
  document.querySelectorAll('.hospital-name').forEach(el => el.textContent = hospitalData.name || 'Hospital');
  const av = document.getElementById('sidebar-avatar');
  if (av) av.textContent = (hospitalData.name || 'H')[0].toUpperCase();
}
function wireLogout() { document.getElementById('logout-btn')?.addEventListener('click', logout); }

// ── Load all patients who have appointments with hospital doctors ─────────────
async function loadPatients() {
  showLoading(true);
  try {
    // Get approved doctors
    const doctorSnap = await getDocs(query(
      collection(db, 'doctorProfiles'),
      where('hospitalId', '==', hospitalId),
      where('approvalStatus', '==', 'approved'),
    ));
    const doctors = doctorSnap.docs.map(d => ({ id: d.id, ...d.data() }));

    if (!doctors.length) { showLoading(false); renderEmpty(); return; }

    // Populate doctor filter dropdown
    const filterEl = document.getElementById('filter-doctor');
    if (filterEl) {
      filterEl.innerHTML = `<option value="">All doctors</option>` +
        doctors.map(d => `<option value="${d.id}">Dr. ${escapeHtml(d.fullName)}</option>`).join('');
    }

    // Get all appointments for hospital doctors (batch by 10)
    const chunks = [];
    for (let i = 0; i < doctors.length; i += 10) chunks.push(doctors.slice(i, i + 10));
    const apptSnaps = await Promise.all(
      chunks.map(chunk => getDocs(query(collection(db, 'appointments'), where('doctorId', 'in', chunk.map(d => d.id)))))
    );

    // Build patient → appointments map
    const patientMap = new Map(); // patientId → { patientId, doctorIds: Set, appointments: [] }
    apptSnaps.forEach(snap => snap.docs.forEach(d => {
      const data = d.data();
      const pid = data.patientId;
      if (!pid) return;
      if (!patientMap.has(pid)) patientMap.set(pid, { patientId: pid, doctorIds: new Set(), appointments: [], doctorNames: new Set() });
      const entry = patientMap.get(pid);
      entry.doctorIds.add(data.doctorId);
      entry.appointments.push(data);
      const dName = data.doctor?.fullName || data.doctor?.name || '';
      if (dName) entry.doctorNames.add(dName);
    }));

    if (!patientMap.size) { showLoading(false); renderEmpty(); return; }

    // Fetch patient profiles in batches of 10
    const patientIds = [...patientMap.keys()];
    const patientChunks = [];
    for (let i = 0; i < patientIds.length; i += 10) patientChunks.push(patientIds.slice(i, i + 10));
    const profileSnaps = await Promise.all(
      patientChunks.map(chunk => getDocs(query(collection(db, 'patients'), where('__name__', 'in', chunk))))
    );

    allPatients = [];
    profileSnaps.forEach(snap => snap.docs.forEach(d => {
      const entry = patientMap.get(d.id) || {};
      allPatients.push({
        id: d.id,
        ...d.data(),
        doctorIds: [...(entry.doctorIds || [])],
        doctorNames: [...(entry.doctorNames || [])],
        appointmentCount: (entry.appointments || []).length,
        lastAppointment: (entry.appointments || []).sort((a, b) => b.date > a.date ? 1 : -1)[0]?.date || '',
      });
    }));

    // Sort alphabetically
    allPatients.sort((a, b) => (a.fullName || '').localeCompare(b.fullName || ''));
    updateCount();
    render();
  } catch (e) {
    showToast('Failed to load patients: ' + e.message, 'error');
  } finally {
    showLoading(false);
  }
}

function showLoading(show) {
  const l = document.getElementById('loading'); if (l) l.style.display = show ? 'flex' : 'none';
  const t = document.getElementById('patient-table'); if (t) t.style.display = show ? 'none' : '';
}

function renderEmpty() {
  const tbody = document.getElementById('patient-tbody');
  if (tbody) tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state">
    <span class="empty-icon material-icons">people_outline</span>
    <h3>No patients found</h3>
    <p>Patients who book appointments with your doctors will appear here.</p>
  </div></td></tr>`;
}

function render() {
  const q = (document.getElementById('search-patients')?.value || '').toLowerCase();
  let filtered = allPatients.filter(p => {
    const matchSearch = !q || (p.fullName || '').toLowerCase().includes(q)
      || (p.patientCode || '').toLowerCase().includes(q)
      || (p.email || '').toLowerCase().includes(q);
    const matchDoctor = !filterDoctor || p.doctorIds.includes(filterDoctor);
    return matchSearch && matchDoctor;
  });

  const tbody = document.getElementById('patient-tbody');
  if (!tbody) return;

  if (!filtered.length) { renderEmpty(); return; }

  tbody.innerHTML = filtered.map(p => `<tr>
    <td><div style="display:flex;align-items:center;gap:10px">
      ${avatarHtml(p.fullName, p.photoUrl, 36)}
      <div><div style="font-weight:600;font-size:.875rem">${escapeHtml(p.fullName || '—')}</div>
      <div style="font-size:.75rem;color:var(--text-muted)">${escapeHtml(p.patientCode || '—')}</div></div>
    </div></td>
    <td>${escapeHtml(p.email || '—')}</td>
    <td>${escapeHtml(p.phoneNumber || '—')}</td>
    <td>${p.doctorNames.map(n => `<div style="font-size:.8rem">Dr. ${escapeHtml(n)}</div>`).join('') || '—'}</td>
    <td><span style="font-weight:600">${p.appointmentCount}</span></td>
    <td>${p.lastAppointment ? escapeHtml(p.lastAppointment) : '—'}</td>
  </tr>`).join('');

  updateCount(filtered.length);
}

function updateCount(n) {
  const el = document.getElementById('patient-count');
  if (el) el.textContent = `${n ?? allPatients.length} patient${(n ?? allPatients.length) !== 1 ? 's' : ''}`;
}

function subscribeNotifBadge() {
  const q = query(collection(db, 'hospitals', hospitalId, 'notifications'), where('isRead', '==', false));
  unsubs.push(onSnapshot(q, snap => updateNavBadge(snap.size)));
}
