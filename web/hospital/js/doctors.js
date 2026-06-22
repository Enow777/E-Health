import { db }                from './firebase-config.js';
import { requireAuth, logout } from './auth.js';
import {
  collection, query, where, onSnapshot, doc,
  updateDoc, deleteDoc, getDocs, writeBatch,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import {
  initSidebar, initTabs, initSearch, showToast, confirmDialog,
  avatarHtml, escapeHtml, formatDate, updateNavBadge, statusBadge,
} from './app.js';

let hospitalId, hospitalData;
let allDoctors = [];
const unsubs   = [];

requireAuth((user, hospital) => {
  hospitalId   = user.uid;
  hospitalData = hospital;
  init();
});

function init() {
  initSidebar();
  initTabs('doctors-page');
  setHospitalName();
  wireLogout();
  subscribeDoctors();
  subscribeNotifBadge();
  document.getElementById('search-doctors')?.addEventListener('input', renderAll);
}

function setHospitalName() {
  document.querySelectorAll('.hospital-name').forEach(el => el.textContent = hospitalData.name || 'Hospital');
  const av = document.getElementById('sidebar-avatar');
  if (av) av.textContent = (hospitalData.name || 'H')[0].toUpperCase();
}

function wireLogout() {
  document.getElementById('logout-btn')?.addEventListener('click', logout);
}

// ── Subscribe to all doctors under this hospital ─────────────────────────────
function subscribeDoctors() {
  const q = query(
    collection(db, 'doctorProfiles'),
    where('hospitalId', '==', hospitalId),
  );
  unsubs.push(onSnapshot(q, snap => {
    allDoctors = snap.docs
      .map(d => ({ id: d.id, ...d.data() }))
      .sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''));
    renderAll();
    updateTabCounts();
  }));
}

function renderAll() {
  const q = (document.getElementById('search-doctors')?.value || '').toLowerCase();
  const filter = d => !q || d.fullName?.toLowerCase().includes(q)
    || d.specialty?.toLowerCase().includes(q)
    || d.clinic?.toLowerCase().includes(q);

  renderList('list-pending',  allDoctors.filter(d => d.approvalStatus === 'pending' && filter(d)),  'pending');
  renderList('list-approved', allDoctors.filter(d => d.approvalStatus === 'approved' && filter(d)), 'approved');
  renderList('list-rejected', allDoctors.filter(d => d.approvalStatus === 'rejected' && filter(d)), 'rejected');
  renderList('list-all',      allDoctors.filter(filter), 'all');
}

function updateTabCounts() {
  const count = (status) => allDoctors.filter(d => d.approvalStatus === status).length;
  setCount('count-pending',  count('pending'));
  setCount('count-approved', count('approved'));
  setCount('count-rejected', count('rejected'));
  setCount('count-all',      allDoctors.length);
}

function setCount(id, n) {
  const el = document.getElementById(id);
  if (el) el.textContent = n;
}

function renderList(containerId, doctors, listType) {
  const container = document.getElementById(containerId);
  if (!container) return;

  if (!doctors.length) {
    const labels = { pending: 'No pending requests', approved: 'No approved doctors', rejected: 'No rejected requests', all: 'No doctors yet' };
    container.innerHTML = `<div class="empty-state">
      <span class="empty-icon material-icons">local_hospital</span>
      <h3>${labels[listType] || 'No results'}</h3>
      <p>Doctors who request to join your hospital will appear here.</p>
    </div>`;
    return;
  }

  container.innerHTML = `<div class="doctor-grid">${doctors.map(d => doctorCard(d, listType)).join('')}</div>`;
}

function doctorCard(d, listType) {
  const specialties = (d.specialties || [d.specialty]).filter(Boolean).join(', ') || '—';
  const approvalActions = listType === 'pending' ? `
    <button class="btn btn-sm btn-success" onclick="approveDoctor('${d.id}','${escapeHtml(d.fullName)}')">
      <span class="material-icons" style="font-size:16px">check</span> Approve
    </button>
    <button class="btn btn-sm btn-outline-danger" onclick="rejectDoctor('${d.id}','${escapeHtml(d.fullName)}')">
      <span class="material-icons" style="font-size:16px">close</span> Reject
    </button>` : listType === 'approved' ? `
    <button class="btn btn-sm btn-outline" onclick="viewDoctor('${d.id}')">
      <span class="material-icons" style="font-size:16px">visibility</span> View
    </button>
    <button class="btn btn-sm btn-outline-danger" onclick="removeDoctor('${d.id}','${escapeHtml(d.fullName)}')">
      <span class="material-icons" style="font-size:16px">person_remove</span> Remove
    </button>` : `
    <button class="btn btn-sm btn-outline" onclick="viewDoctor('${d.id}')">
      <span class="material-icons" style="font-size:16px">visibility</span> View
    </button>
    <button class="btn btn-sm btn-outline-danger" onclick="deleteDoctor('${d.id}','${escapeHtml(d.fullName)}')">
      <span class="material-icons" style="font-size:16px">delete</span> Delete
    </button>`;

  return `<div class="doctor-card" id="card-${d.id}">
    <div class="doctor-card-header">
      ${avatarHtml(d.fullName, d.photoUrl)}
      <div class="doctor-card-meta">
        <strong>Dr. ${escapeHtml(d.fullName || '—')}</strong>
        <span>${escapeHtml(specialties)}</span>
        ${statusBadge(d.approvalStatus || 'pending')}
      </div>
    </div>
    <div class="doctor-card-info">
      <div class="info-row"><span class="material-icons">local_hospital</span>${escapeHtml(d.clinic || '—')}</div>
      <div class="info-row"><span class="material-icons">work_outline</span>${escapeHtml(d.experience || '—')}</div>
      <div class="info-row"><span class="material-icons">language</span>${escapeHtml(d.languages || 'English')}</div>
      <div class="info-row"><span class="material-icons">schedule</span>Joined ${formatDate(d.createdAt)}</div>
      ${d.rating > 0 ? `<div class="info-row"><span class="material-icons" style="color:#F59E0B">star</span>${d.rating.toFixed(1)} (${d.ratingCount} reviews)</div>` : ''}
    </div>
    <div class="doctor-card-actions">${approvalActions}</div>
  </div>`;
}

// ── Actions (exposed to window for onclick) ──────────────────────────────────
window.approveDoctor = async (id, name) => {
  confirmDialog({
    title: 'Approve Doctor',
    message: `Approve Dr. ${name}? They will be able to receive appointments through the app.`,
    confirmText: 'Approve',
    type: 'success',
    onConfirm: async () => {
      try {
        await updateDoc(doc(db, 'doctorProfiles', id), { approvalStatus: 'approved' });
        await updateDoc(doc(db, 'doctors', id), { approvalStatus: 'approved' });
        await notifyDoctor(id, 'approved', `Dr. ${name}`);
        showToast(`Dr. ${name} has been approved.`, 'success');
      } catch (e) { showToast('Failed: ' + e.message, 'error'); }
    },
  });
};

window.rejectDoctor = async (id, name) => {
  confirmDialog({
    title: 'Reject Request',
    message: `Reject Dr. ${name}'s request? They will be notified and won't be able to join your hospital.`,
    confirmText: 'Reject',
    type: 'danger',
    onConfirm: async () => {
      try {
        await updateDoc(doc(db, 'doctorProfiles', id), { approvalStatus: 'rejected' });
        await updateDoc(doc(db, 'doctors', id), { approvalStatus: 'rejected' });
        await notifyDoctor(id, 'rejected', `Dr. ${name}`);
        showToast(`Dr. ${name}'s request has been rejected.`, 'info');
      } catch (e) { showToast('Failed: ' + e.message, 'error'); }
    },
  });
};

window.removeDoctor = async (id, name) => {
  confirmDialog({
    title: 'Remove Doctor',
    message: `Remove Dr. ${name} from your hospital? Their account will remain but they'll need to re-apply.`,
    confirmText: 'Remove',
    type: 'danger',
    onConfirm: async () => {
      try {
        const update = { approvalStatus: 'pending', hospitalId: '', hospitalName: '' };
        await updateDoc(doc(db, 'doctorProfiles', id), update);
        await updateDoc(doc(db, 'doctors', id), update);
        showToast(`Dr. ${name} removed from hospital.`, 'info');
      } catch (e) { showToast('Failed: ' + e.message, 'error'); }
    },
  });
};

window.deleteDoctor = async (id, name) => {
  confirmDialog({
    title: 'Delete Doctor Account',
    message: `Permanently delete Dr. ${name}'s account data? This action cannot be undone.`,
    confirmText: 'Delete',
    type: 'danger',
    onConfirm: async () => {
      try {
        const batch = writeBatch(db);
        batch.delete(doc(db, 'doctorProfiles', id));
        batch.delete(doc(db, 'doctors', id));
        batch.delete(doc(db, 'userRoles', id));
        await batch.commit();
        showToast(`Dr. ${name}'s account has been deleted.`, 'success');
      } catch (e) { showToast('Failed: ' + e.message, 'error'); }
    },
  });
};

window.viewDoctor = (id) => {
  const d = allDoctors.find(x => x.id === id);
  if (!d) return;
  const specialties = (d.specialties || [d.specialty]).filter(Boolean);
  const stars = d.rating > 0
    ? '★'.repeat(Math.round(d.rating)) + '☆'.repeat(5 - Math.round(d.rating))
    : 'No ratings yet';

  document.getElementById('detail-modal-body').innerHTML = `
    <div class="doctor-detail-header">
      ${avatarHtml(d.fullName, d.photoUrl, 64)}
      <div>
        <h3>Dr. ${escapeHtml(d.fullName)}</h3>
        <p style="margin:4px 0 8px">${escapeHtml(d.clinic || '—')}</p>
        ${statusBadge(d.approvalStatus)}
      </div>
    </div>
    <div class="divider"></div>
    <div class="detail-section">
      <h4>Personal Info</h4>
      <div class="detail-grid">
        <div class="detail-item"><label>Email</label><span>${escapeHtml(d.email || '—')}</span></div>
        <div class="detail-item"><label>Phone</label><span>${escapeHtml(d.phoneNumber || '—')}</span></div>
        <div class="detail-item"><label>Age</label><span>${escapeHtml(d.age || '—')}</span></div>
        <div class="detail-item"><label>Sex</label><span>${escapeHtml(d.sex || '—')}</span></div>
        <div class="detail-item"><label>Languages</label><span>${escapeHtml(d.languages || '—')}</span></div>
        <div class="detail-item"><label>Experience</label><span>${escapeHtml(d.experience || '—')}</span></div>
      </div>
    </div>
    <div class="detail-section">
      <h4>Specialties</h4>
      <div class="specialty-chips">
        ${specialties.map(s => `<span class="specialty-chip">${escapeHtml(s)}</span>`).join('') || '<span style="color:var(--text-muted)">—</span>'}
      </div>
    </div>
    ${d.about ? `<div class="detail-section"><h4>About</h4><p>${escapeHtml(d.about)}</p></div>` : ''}
    <div class="detail-section">
      <h4>Performance</h4>
      <div class="detail-grid">
        <div class="detail-item"><label>Rating</label><span class="rating-stars">${stars}</span></div>
        <div class="detail-item"><label>Reviews</label><span>${d.ratingCount || 0}</span></div>
        <div class="detail-item"><label>Status</label><span>${d.isAvailable ? 'Available' : 'Unavailable'}</span></div>
        <div class="detail-item"><label>Joined</label><span>${formatDate(d.createdAt)}</span></div>
      </div>
    </div>`;

  // Wire approve/reject/remove from detail modal
  const apprBtn = document.getElementById('modal-approve-btn');
  const rejtBtn = document.getElementById('modal-reject-btn');
  const deleBtn = document.getElementById('modal-delete-btn');
  if (apprBtn) { apprBtn.style.display = d.approvalStatus === 'pending' ? '' : 'none'; apprBtn.onclick = () => { closeDetailModal(); window.approveDoctor(id, d.fullName); }; }
  if (rejtBtn) { rejtBtn.style.display = d.approvalStatus === 'pending' ? '' : 'none'; rejtBtn.onclick = () => { closeDetailModal(); window.rejectDoctor(id, d.fullName); }; }
  if (deleBtn) { deleBtn.onclick = () => { closeDetailModal(); window.deleteDoctor(id, d.fullName); }; }

  document.getElementById('detail-modal').style.display = 'flex';
  document.body.style.overflow = 'hidden';
};

window.closeDetailModal = function () {
  document.getElementById('detail-modal').style.display = 'none';
  document.body.style.overflow = '';
};

// ── Notify doctor via the notifications collection ───────────────────────────
async function notifyDoctor(doctorId, status, name) {
  const { addDoc } = await import('https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js');
  const msg = status === 'approved'
    ? `Your account has been approved by ${hospitalData.name}. You can now receive appointments.`
    : `Your account request for ${hospitalData.name} was not approved. Please contact the hospital.`;
  await addDoc(collection(db, 'notifications'), {
    patientId: doctorId,
    category: 'appointment',
    title: status === 'approved' ? 'Account Approved' : 'Account Not Approved',
    message: msg,
    time: new Date().toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' }),
    isRead: false,
    createdAt: new Date().toISOString(),
  });
}

// ── Notification badge ───────────────────────────────────────────────────────
function subscribeNotifBadge() {
  const q = query(
    collection(db, 'hospitals', hospitalId, 'notifications'),
    where('isRead', '==', false),
  );
  unsubs.push(onSnapshot(q, snap => updateNavBadge(snap.size)));
}
