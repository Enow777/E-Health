import { db }                from './firebase-config.js';
import { requireAuth, logout } from './auth.js';
import {
  collection, query, where, onSnapshot, doc,
  updateDoc, writeBatch, getDocs, orderBy,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import {
  initSidebar, showToast, escapeHtml, timeAgo, updateNavBadge,
} from './app.js';

let hospitalId, hospitalData;
let allNotifs = [];
const unsubs  = [];

requireAuth((user, hospital) => {
  hospitalId   = user.uid;
  hospitalData = hospital;
  init();
});

function init() {
  initSidebar();
  setHospitalName();
  wireLogout();
  subscribeNotifications();

  document.getElementById('mark-all-read')?.addEventListener('click', markAllRead);
  document.getElementById('filter-notif')?.addEventListener('change', render);
}

function setHospitalName() {
  document.querySelectorAll('.hospital-name').forEach(el => el.textContent = hospitalData.name || 'Hospital');
  const av = document.getElementById('sidebar-avatar');
  if (av) av.textContent = (hospitalData.name || 'H')[0].toUpperCase();
}
function wireLogout() { document.getElementById('logout-btn')?.addEventListener('click', logout); }

function subscribeNotifications() {
  const q = query(
    collection(db, 'hospitals', hospitalId, 'notifications'),
    orderBy('createdAt', 'desc'),
  );
  unsubs.push(onSnapshot(q, snap => {
    allNotifs = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    render();
    updateNavBadge(allNotifs.filter(n => !n.isRead).length);
    updateUnreadCount();
  }));
}

function render() {
  const filter = document.getElementById('filter-notif')?.value || 'all';
  const filtered = filter === 'all'   ? allNotifs
    : filter === 'unread' ? allNotifs.filter(n => !n.isRead)
    : allNotifs.filter(n => n.type === filter);

  const container = document.getElementById('notif-list');
  if (!container) return;

  if (!filtered.length) {
    container.innerHTML = `<div class="empty-state" style="padding:60px">
      <span class="empty-icon material-icons">notifications_none</span>
      <h3>No notifications</h3>
      <p>You're all caught up!</p>
    </div>`;
    return;
  }

  container.innerHTML = filtered.map(n => notifItem(n)).join('');
}

function notifItem(n) {
  const iconMap = {
    doctor_request: { icon: 'person_add', cls: 'doctor' },
    approval:       { icon: 'check_circle', cls: 'approval' },
    system:         { icon: 'settings', cls: 'system' },
  };
  const { icon, cls } = iconMap[n.type] || { icon: 'notifications', cls: 'alert' };

  return `<div class="notif-item ${n.isRead ? '' : 'unread'}" onclick="markRead('${n.id}')">
    <div class="notif-icon ${cls}"><span class="material-icons">${icon}</span></div>
    <div class="notif-content">
      <div class="notif-title">${escapeHtml(n.title || 'Notification')}</div>
      <div class="notif-msg">${escapeHtml(n.message || '')}</div>
      <div class="notif-time">${timeAgo(n.createdAt)}</div>
    </div>
    ${!n.isRead ? '<div class="unread-dot"></div>' : ''}
    ${n.type === 'doctor_request' && n.doctorId ? `
      <div style="display:flex;gap:6px;flex-shrink:0">
        <a href="doctors.html" class="btn btn-sm btn-primary">Review</a>
      </div>` : ''}
  </div>`;
}

function updateUnreadCount() {
  const unread = allNotifs.filter(n => !n.isRead).length;
  const el = document.getElementById('unread-count');
  if (el) el.textContent = unread > 0 ? `${unread} unread` : 'All read';
  const btn = document.getElementById('mark-all-read');
  if (btn) btn.disabled = unread === 0;
}

window.markRead = async (id) => {
  try {
    await updateDoc(doc(db, 'hospitals', hospitalId, 'notifications', id), { isRead: true });
  } catch (e) { /* silent */ }
};

async function markAllRead() {
  try {
    const unread = allNotifs.filter(n => !n.isRead);
    if (!unread.length) return;
    const batch = writeBatch(db);
    unread.forEach(n => batch.update(doc(db, 'hospitals', hospitalId, 'notifications', n.id), { isRead: true }));
    await batch.commit();
    showToast('All notifications marked as read', 'success');
  } catch (e) {
    showToast('Failed: ' + e.message, 'error');
  }
}
