import { db } from './firebase-config.js';
import { requireAdmin, logout } from './auth.js';
import { initSidebar, showToast, confirmDialog, formatDate, escapeHtml, avatarHtml } from './app.js';
import {
  collection, query, onSnapshot, orderBy, doc, writeBatch, getDocs, where,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

let _allPatients = [];

requireAdmin(() => {
  initSidebar();
  document.getElementById('logout-btn').addEventListener('click', logout);
  document.getElementById('search-input').addEventListener('input', render);

  const q = query(collection(db, 'patients'), orderBy('name'));
  onSnapshot(q, (snap) => {
    _allPatients = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    render();
    document.getElementById('total-count').textContent = _allPatients.length;
  });
});

function render() {
  const search = (document.getElementById('search-input')?.value || '').toLowerCase();
  const list = _allPatients.filter((p) =>
    !search ||
    (p.name || '').toLowerCase().includes(search) ||
    (p.email || '').toLowerCase().includes(search) ||
    (p.patientCode || '').toLowerCase().includes(search),
  );
  const tbody = document.getElementById('patients-tbody');
  if (!tbody) return;
  if (!list.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="empty-cell">No patients found</td></tr>';
    return;
  }
  tbody.innerHTML = list.map((p) => `
    <tr>
      <td style="display:flex;align-items:center;gap:10px">
        ${avatarHtml(p.name, '#7C3AED')}
        <div>
          <div style="font-weight:600">${escapeHtml(p.name || '—')}</div>
          <div style="font-size:0.8rem;color:#64748b">${escapeHtml(p.patientCode || '—')}</div>
        </div>
      </td>
      <td>${escapeHtml(p.email || '—')}</td>
      <td>${escapeHtml(p.phoneNumber || '—')}</td>
      <td>${formatDate(p.createdAt)}</td>
      <td>
        <div class="action-btns">
          <button class="btn btn-sm btn-ghost" onclick="viewPatient('${p.id}')">View</button>
          <button class="btn btn-sm btn-danger" onclick="deletePatient('${p.id}','${escapeHtml(p.name)}')">Delete</button>
        </div>
      </td>
    </tr>`).join('');
}

window.viewPatient = function (id) {
  const p = _allPatients.find((x) => x.id === id);
  if (!p) return;
  const overlay = document.getElementById('detail-modal');
  document.getElementById('detail-modal-body').innerHTML = `
    <div class="detail-grid">
      <div class="detail-item"><label>Full Name</label><p>${escapeHtml(p.name)}</p></div>
      <div class="detail-item"><label>Patient Code</label><p>${escapeHtml(p.patientCode || '—')}</p></div>
      <div class="detail-item"><label>Email</label><p>${escapeHtml(p.email || '—')}</p></div>
      <div class="detail-item"><label>Phone</label><p>${escapeHtml(p.phoneNumber || '—')}</p></div>
      <div class="detail-item"><label>Date of Birth</label><p>${escapeHtml(p.dateOfBirth || '—')}</p></div>
      <div class="detail-item"><label>Blood Type</label><p>${escapeHtml(p.bloodType || '—')}</p></div>
      <div class="detail-item"><label>Joined</label><p>${formatDate(p.createdAt)}</p></div>
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

window.deletePatient = async function (id, name) {
  if (!await confirmDialog('Delete Patient', `Permanently delete <strong>${name}</strong>? All their records and appointments will remain but their account will be gone.`, 'Delete')) return;
  try {
    const batch = writeBatch(db);
    batch.delete(doc(db, 'patients', id));
    batch.delete(doc(db, 'userRoles', id));
    await batch.commit();
    showToast(`${name} deleted.`, 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};
