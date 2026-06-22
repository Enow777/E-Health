import { db } from './firebase-config.js';
import { requireAdmin, logout } from './auth.js';
import { initSidebar, initTabs, showToast, confirmDialog, formatDate, escapeHtml, avatarHtml, statusBadge } from './app.js';
import {
  collection, query, onSnapshot, orderBy, doc, updateDoc, deleteDoc, writeBatch, getDocs, where,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

let _allHospitals = [];

requireAdmin(() => {
  initSidebar();
  initTabs('tabs-container');
  document.getElementById('logout-btn').addEventListener('click', logout);
  document.getElementById('search-input').addEventListener('input', renderAll);

  const q = query(collection(db, 'hospitals'), orderBy('createdAt', 'desc'));
  onSnapshot(q, (snap) => {
    _allHospitals = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    renderAll();
  });
});

function renderAll() {
  const search = (document.getElementById('search-input')?.value || '').toLowerCase();
  const all = _allHospitals.filter((h) => !search || (h.name || '').toLowerCase().includes(search));

  renderTab('tab-all',       all);
  renderTab('tab-active',    all.filter((h) => h.status !== 'suspended'));
  renderTab('tab-suspended', all.filter((h) => h.status === 'suspended'));
}

function renderTab(panelId, hospitals) {
  const tbody = document.querySelector(`#${panelId} tbody`);
  if (!tbody) return;
  if (!hospitals.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-cell">No hospitals found</td></tr>';
    return;
  }
  tbody.innerHTML = hospitals.map((h) => `
    <tr>
      <td style="display:flex;align-items:center;gap:10px">
        ${avatarHtml(h.name, '#059669')}
        <div>
          <div style="font-weight:600">${escapeHtml(h.name || '—')}</div>
          <div style="font-size:0.8rem;color:#64748b">${escapeHtml(h.email || '—')}</div>
        </div>
      </td>
      <td>${escapeHtml(h.type || '—')}</td>
      <td>${escapeHtml(h.address || '—')}</td>
      <td>${escapeHtml(h.phone || '—')}</td>
      <td>${statusBadge(h.status === 'suspended' ? 'suspended' : 'active')}</td>
      <td>
        <div class="action-btns">
          <button class="btn btn-sm btn-ghost" onclick="viewHospital('${h.id}')">View</button>
          ${h.status === 'suspended'
            ? `<button class="btn btn-sm btn-success" onclick="unsuspendHospital('${h.id}','${escapeHtml(h.name)}')">Restore</button>`
            : `<button class="btn btn-sm btn-warning" onclick="suspendHospital('${h.id}','${escapeHtml(h.name)}')">Suspend</button>`}
          <button class="btn btn-sm btn-danger" onclick="deleteHospital('${h.id}','${escapeHtml(h.name)}')">Delete</button>
        </div>
      </td>
    </tr>`).join('');
}

window.viewHospital = function (id) {
  const h = _allHospitals.find((x) => x.id === id);
  if (!h) return;
  const overlay = document.getElementById('detail-modal');
  document.getElementById('detail-modal-body').innerHTML = `
    <div class="detail-grid">
      <div class="detail-item"><label>Name</label><p>${escapeHtml(h.name)}</p></div>
      <div class="detail-item"><label>Email</label><p>${escapeHtml(h.email || '—')}</p></div>
      <div class="detail-item"><label>Phone</label><p>${escapeHtml(h.phone || '—')}</p></div>
      <div class="detail-item"><label>Type</label><p>${escapeHtml(h.type || '—')}</p></div>
      <div class="detail-item"><label>Address</label><p>${escapeHtml(h.address || '—')}</p></div>
      <div class="detail-item"><label>Status</label><p>${statusBadge(h.status === 'suspended' ? 'suspended' : 'active')}</p></div>
      <div class="detail-item"><label>Registered</label><p>${formatDate(h.createdAt)}</p></div>
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

window.suspendHospital = async function (id, name) {
  if (!await confirmDialog('Suspend Hospital', `Suspend <strong>${name}</strong>? Their portal access will be blocked.`, 'Suspend')) return;
  try {
    await updateDoc(doc(db, 'hospitals', id), { status: 'suspended' });
    showToast(`${name} has been suspended.`, 'warning');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};

window.unsuspendHospital = async function (id, name) {
  if (!await confirmDialog('Restore Hospital', `Restore access for <strong>${name}</strong>?`, 'Restore', false)) return;
  try {
    await updateDoc(doc(db, 'hospitals', id), { status: 'active' });
    showToast(`${name} has been restored.`, 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};

window.deleteHospital = async function (id, name) {
  if (!await confirmDialog('Delete Hospital', `Permanently delete <strong>${name}</strong>? This cannot be undone. All associated doctors will be set to independent.`, 'Delete')) return;
  try {
    const batch = writeBatch(db);
    // Reset all doctors affiliated with this hospital
    const doctorsSnap = await getDocs(query(collection(db, 'doctorProfiles'), where('hospitalId', '==', id)));
    doctorsSnap.forEach((d) => {
      batch.update(doc(db, 'doctorProfiles', d.id), { hospitalId: '', hospitalName: '', approvalStatus: 'independent' });
      batch.update(doc(db, 'doctors', d.id), { hospitalId: '', hospitalName: '', approvalStatus: 'independent' });
    });
    batch.delete(doc(db, 'hospitals', id));
    batch.delete(doc(db, 'userRoles', id));
    await batch.commit();
    showToast(`${name} deleted.`, 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};
