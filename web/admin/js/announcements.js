import { db } from './firebase-config.js';
import { requireAdmin, logout } from './auth.js';
import { initSidebar, showToast, formatDate, escapeHtml } from './app.js';
import {
  collection, addDoc, query, orderBy, onSnapshot, doc, deleteDoc,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';

requireAdmin((_, admin) => {
  initSidebar();
  document.getElementById('logout-btn').addEventListener('click', logout);

  const form = document.getElementById('announce-form');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title   = document.getElementById('ann-title').value.trim();
    const message = document.getElementById('ann-message').value.trim();
    const target  = document.getElementById('ann-target').value;
    if (!title || !message) return;
    try {
      await addDoc(collection(db, 'announcements'), {
        title,
        message,
        target,         // 'all' | 'doctors' | 'patients'
        createdAt: new Date().toISOString(),
        createdBy: admin.email,
      });
      showToast('Announcement sent!', 'success');
      form.reset();
    } catch (e) { showToast('Failed: ' + e.message, 'error'); }
  });

  // List past announcements
  const q = query(collection(db, 'announcements'), orderBy('createdAt', 'desc'));
  onSnapshot(q, (snap) => {
    const list = document.getElementById('announcements-list');
    if (!list) return;
    if (snap.empty) {
      list.innerHTML = '<div class="empty-state"><p>No announcements yet</p></div>';
      return;
    }
    list.innerHTML = snap.docs.map((d) => {
      const a = d.data();
      return `<div class="announce-card">
        <div class="announce-header">
          <div>
            <h4>${escapeHtml(a.title)}</h4>
            <span class="badge badge-info">${escapeHtml(a.target || 'all')}</span>
          </div>
          <div style="display:flex;align-items:center;gap:8px">
            <span style="font-size:0.8rem;color:#64748b">${formatDate(a.createdAt)}</span>
            <button class="btn btn-sm btn-danger" onclick="deleteAnnouncement('${d.id}')">Delete</button>
          </div>
        </div>
        <p style="margin-top:8px">${escapeHtml(a.message)}</p>
      </div>`;
    }).join('');
  });
});

window.deleteAnnouncement = async function (id) {
  try {
    await deleteDoc(doc(db, 'announcements', id));
    showToast('Announcement deleted.', 'success');
  } catch (e) { showToast('Failed: ' + e.message, 'error'); }
};
