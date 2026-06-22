import { db }                from './firebase-config.js';
import { requireAuth, logout } from './auth.js';
import {
  collection, query, where, onSnapshot, getDocs,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import {
  initSidebar, initTabs, escapeHtml, formatDate, statusBadge, updateNavBadge,
} from './app.js';

let hospitalId, hospitalData;
let approvedDoctorIds = [];
let allAppointments   = [];
const unsubs = [];

requireAuth((user, hospital) => {
  hospitalId   = user.uid;
  hospitalData = hospital;
  init();
});

async function init() {
  initSidebar();
  initTabs('appointments-page');
  setHospitalName();
  wireLogout();
  await loadApprovedDoctors();
  subscribeAppointments();
  subscribeNotifBadge();

  document.getElementById('search-appts')?.addEventListener('input', renderAll);
  document.getElementById('filter-status')?.addEventListener('change', renderAll);
  document.getElementById('filter-date')?.addEventListener('change', renderAll);
  document.getElementById('filter-doctor-appts')?.addEventListener('change', renderAll);
}

function setHospitalName() {
  document.querySelectorAll('.hospital-name').forEach(el => el.textContent = hospitalData.name || 'Hospital');
  const av = document.getElementById('sidebar-avatar');
  if (av) av.textContent = (hospitalData.name || 'H')[0].toUpperCase();
}
function wireLogout() { document.getElementById('logout-btn')?.addEventListener('click', logout); }

async function loadApprovedDoctors() {
  const snap = await getDocs(query(
    collection(db, 'doctorProfiles'),
    where('hospitalId', '==', hospitalId),
    where('approvalStatus', '==', 'approved'),
  ));
  approvedDoctorIds = snap.docs.map(d => d.id);

  // Populate doctor filter
  const filterEl = document.getElementById('filter-doctor-appts');
  if (filterEl) {
    filterEl.innerHTML = `<option value="">All doctors</option>` +
      snap.docs.map(d => `<option value="${d.id}">Dr. ${escapeHtml(d.data().fullName)}</option>`).join('');
  }
}

function subscribeAppointments() {
  if (!approvedDoctorIds.length) { renderAll(); return; }
  const chunks = [];
  for (let i = 0; i < approvedDoctorIds.length; i += 10) chunks.push(approvedDoctorIds.slice(i, i + 10));

  chunks.forEach(chunk => {
    const q = query(
      collection(db, 'appointments'),
      where('doctorId', 'in', chunk),
    );
    unsubs.push(onSnapshot(q, snap => {
      const incoming = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      const existingIds = new Set(incoming.map(a => a.id));
      allAppointments = [
        ...allAppointments.filter(a => !existingIds.has(a.id)),
        ...incoming,
      ].sort((a, b) => (b.date || '') > (a.date || '') ? 1 : -1);
      renderAll();
      updateTabCounts();
    }));
  });
}

function renderAll() {
  const q       = (document.getElementById('search-appts')?.value || '').toLowerCase();
  const status  = document.getElementById('filter-status')?.value || '';
  const date    = document.getElementById('filter-date')?.value || '';
  const doctor  = document.getElementById('filter-doctor-appts')?.value || '';

  const filter = (a) => {
    const matchQ      = !q      || (a.patientName || '').toLowerCase().includes(q) || (a.doctor?.fullName || '').toLowerCase().includes(q);
    const matchStatus = !status || a.status === status;
    const matchDate   = !date   || a.date === date;
    const matchDoctor = !doctor || a.doctorId === doctor;
    return matchQ && matchStatus && matchDate && matchDoctor;
  };

  renderTable('tbody-all',       allAppointments.filter(filter));
  renderTable('tbody-pending',   allAppointments.filter(a => a.status === 'pending'   && filter(a)));
  renderTable('tbody-upcoming',  allAppointments.filter(a => a.status === 'upcoming'  && filter(a)));
  renderTable('tbody-completed', allAppointments.filter(a => a.status === 'completed' && filter(a)));
  renderTable('tbody-cancelled', allAppointments.filter(a => a.status === 'cancelled' && filter(a)));
}

function updateTabCounts() {
  const count = (s) => allAppointments.filter(a => a.status === s).length;
  setCount('count-all-appts',  allAppointments.length);
  setCount('count-pending-appts',  count('pending'));
  setCount('count-upcoming-appts', count('upcoming'));
  setCount('count-completed-appts',count('completed'));
  setCount('count-cancelled-appts',count('cancelled'));
}

function setCount(id, n) { const el = document.getElementById(id); if (el) el.textContent = n; }

function renderTable(tbodyId, rows) {
  const tbody = document.getElementById(tbodyId);
  if (!tbody) return;

  if (!rows.length) {
    tbody.innerHTML = `<tr><td colspan="7"><div class="empty-state" style="padding:32px">
      <span class="empty-icon material-icons">event_busy</span>
      <h3>No appointments found</h3>
    </div></td></tr>`;
    return;
  }

  tbody.innerHTML = rows.map(a => {
    const doctorName = a.doctor?.fullName || a.doctor?.name || '—';
    const typeIcon   = a.consultationType === 'Video consultation' ? '📹' : '🏥';
    const urgency    = a.urgency && a.urgency !== 'normal'
      ? `<span class="badge badge-${a.urgency === 'urgent' ? 'pending' : 'rejected'}" style="font-size:.7rem">${a.urgency}</span>` : '';
    return `<tr>
      <td><div style="font-weight:600;font-size:.875rem">${escapeHtml(a.patientName || '—')}</div></td>
      <td>Dr. ${escapeHtml(doctorName)}</td>
      <td>${escapeHtml(a.date)} &nbsp;<span style="color:var(--text-muted)">${escapeHtml(a.time)}</span></td>
      <td>${typeIcon} ${escapeHtml(a.consultationType || a.type || '—')}</td>
      <td>${statusBadge(a.status)} ${urgency}</td>
      <td>${escapeHtml(a.isRated ? '★ Rated' : '—')}</td>
      <td><span style="font-size:.75rem;color:var(--text-muted)">${formatDate(a.createdAt)}</span></td>
    </tr>`;
  }).join('');
}

function subscribeNotifBadge() {
  const q = query(collection(db, 'hospitals', hospitalId, 'notifications'), where('isRead', '==', false));
  unsubs.push(onSnapshot(q, snap => updateNavBadge(snap.size)));
}
