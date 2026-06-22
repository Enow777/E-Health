import { db } from './firebase-config.js';
import { requireAdmin, logout } from './auth.js';
import { initSidebar, initTabs, showToast, confirmDialog, formatDate, escapeHtml, avatarHtml, statusBadge } from './app.js';
import {
  collection, query, onSnapshot, orderBy, doc, updateDoc, deleteDoc, writeBatch,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

let _allDoctors = [];

requireAdmin(() => {
  initSidebar();
  initTabs('tabs-container');
  document.getElementById('logout-btn').addEventListener('click', logout);
  document.getElementById('search-input').addEventListener('input', renderAll);

  const q = query(collection(db, 'doctorProfiles'), orderBy('createdAt', 'desc'));
  onSnapshot(q, (snap) => {
    _allDoctors = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    renderAll();
    document.getElementById('total-count').textContent = _allDoctors.length;
  });
});

function renderAll() {
  const search = (document.getElementById('search-input')?.value || '').toLowerCase();
  const filtered = _allDoctors.filter((d) =>
    !search ||
    (d.fullName || '').toLowerCase().includes(search) ||
    (d.specialty || '').toLowerCase().includes(search) ||
    (d.hospitalName || '').toLowerCase().includes(search),
  );

  renderTab('tab-all',         filtered);
  renderTab('tab-pending',     filtered.filter((d) => d.approvalStatus === 'pending'));
  renderTab('tab-approved',    filtered.filter((d) => d.approvalStatus === 'approved'));
  renderTab('tab-independent', filtered.filter((d) => d.approvalStatus === 'independent'));
  renderTab('tab-rejected',    filtered.filter((d) => d.approvalStatus === 'rejected'));
}

function renderTab(panelId, doctors) {
  const tbody = document.querySelector(`#${panelId} tbody`);
  if (!tbody) return;
  if (!doctors.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-cell">No doctors found</td></tr>';
    return;
  }
  tbody.innerHTML = doctors.map((d) => `
    <tr>
      <td style="display:flex;align-items:center;gap:10px">
        ${avatarHtml(d.fullName)}
        <div>
          <div style="font-weight:600">${escapeHtml(d.fullName || '—')}</div>
          <div style="font-size:0.8rem;color:#64748b">${escapeHtml(d.specialty || '—')}</div>
        </div>
      </td>
      <td>${escapeHtml(d.hospitalName || 'Independent')}</td>
      <td>${statusBadge(d.approvalStatus || 'pending')}</td>
      <td>${formatDate(d.createdAt)}</td>
      <td>
        <div class="action-btns">
          <button class="btn btn-sm btn-ghost" onclick="viewDoctor('${d.id}')">View</button>
          ${d.approvalStatus !== 'approved' && d.approvalStatus !== 'independent'
            ? `<button class="btn btn-sm btn-success" onclick="forceApprove('${d.id}','${escapeHtml(d.fullName)}')">Force Approve</button>`
            : ''}
          <button class="btn btn-sm btn-danger" onclick="deleteDoctor('${d.id}','${escapeHtml(d.fullName)}')">Delete</button>
        </div>
      </td>
    </tr>`).join('');
}

window.viewDoctor = function (id) {
  const d = _allDoctors.find((x) => x.id === id);
  if (!d) return;
  const overlay = document.getElementById('detail-modal');
  document.getElementById('detail-modal-body').innerHTML = `
    <div class="detail-grid">
      <div class="detail-item"><label>Full Name</label><p>${escapeHtml(d.fullName)}</p></div>
      <div class="detail-item"><label>Specialty</label><p>${escapeHtml(d.specialty || '—')}</p></div>
      <div class="detail-item"><label>Phone</label><p>${escapeHtml(d.phoneNumber || '—')}</p></div>
      <div class="detail-item"><label>License No.</label><p>${escapeHtml(d.licenseNumber || '—')}</p></div>
      <div class="detail-item"><label>Hospital</label><p>${escapeHtml(d.hospitalName || 'Independent')}</p></div>
      <div class="detail-item"><label>Status</label><p>${statusBadge(d.approvalStatus || 'pending')}</p></div>
      <div class="detail-item"><label>Experience</label><p>${escapeHtml(d.yearsOfExperience ? d.yearsOfExperience + ' years' : '—')}</p></div>
      <div class="detail-item"><label>Bio</label><p>${escapeHtml(d.bio || '—')}</p></div>
      <div class="detail-item"><label>Joined</label><p>${formatDate(d.createdAt)}</p></div>
    </div>`;
  overlay.classList.add('open');
  document.body.style.overflow = 'hidden';
};

document.addEventListener('click', (e) => {
  if (e.target.id === 'detail-modal' || e.target.classList.contains('modal-close')) {
    document.getElementById('detail-modal').classList.remove('open');
    document.body.style.overflow = '';
  }
});

window.forceApprove = async function (id, name) {
  if (!await confirmDialog('Force Approve Doctor', `Approve <strong>Dr. ${name}</strong> without hospital confirmation?`, 'Approve', false)) return;
  try {
    const update = { approvalStatus: 'approved' };
    await updateDoc(doc(db, 'doctorProfiles', id), update);
    await updateDoc(doc(db, 'doctors', id), update);
    showToast(`Dr. ${name} approved.`, 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};

window.deleteDoctor = async function (id, name) {
  if (!await confirmDialog('Delete Doctor', `Permanently delete <strong>Dr. ${name}</strong>? This removes their account entirely.`, 'Delete')) return;
  try {
    const batch = writeBatch(db);
    batch.delete(doc(db, 'doctorProfiles', id));
    batch.delete(doc(db, 'doctors', id));
    batch.delete(doc(db, 'userRoles', id));
    await batch.commit();
    showToast(`Dr. ${name} deleted.`, 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};
