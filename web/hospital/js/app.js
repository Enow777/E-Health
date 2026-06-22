/**
 * Shared utilities used by every page of the Hospital Admin Portal.
 */

// ── Toast notifications ─────────────────────────────────────────────────────
let toastContainer;
function getToastContainer() {
  if (!toastContainer) {
    toastContainer = document.createElement('div');
    toastContainer.className = 'toast-container';
    document.body.appendChild(toastContainer);
  }
  return toastContainer;
}

export function showToast(message, type = 'info', duration = 3500) {
  const icons = { success: 'check_circle', error: 'error', info: 'info', warning: 'warning' };
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <span class="toast-icon material-icons">${icons[type] || 'info'}</span>
    <span class="toast-msg">${escapeHtml(message)}</span>
    <button class="toast-close material-icons" onclick="this.parentElement.remove()">close</button>
  `;
  getToastContainer().appendChild(toast);
  setTimeout(() => toast.remove(), duration);
}

// ── Modal helpers ───────────────────────────────────────────────────────────
export function openModal(id) {
  const el = document.getElementById(id);
  if (el) { el.style.display = 'flex'; document.body.style.overflow = 'hidden'; }
}

export function closeModal(id) {
  const el = document.getElementById(id);
  if (el) { el.style.display = 'none'; document.body.style.overflow = ''; }
}

export function buildModal(id, title, bodyHtml, footerHtml = '') {
  return `
    <div id="${id}" class="modal-overlay" style="display:none" onclick="if(event.target===this)closeModalById('${id}')">
      <div class="modal">
        <div class="modal-header">
          <h3>${title}</h3>
          <button class="modal-close material-icons" onclick="closeModalById('${id}')">close</button>
        </div>
        <div class="modal-body">${bodyHtml}</div>
        ${footerHtml ? `<div class="modal-footer">${footerHtml}</div>` : ''}
      </div>
    </div>`;
}
// Expose for inline onclick
window.closeModalById = closeModal;

// ── Confirmation dialog ─────────────────────────────────────────────────────
export function confirmDialog({ title, message, confirmText = 'Confirm', type = 'danger', onConfirm }) {
  const id = 'confirm-modal-' + Date.now();
  const iconMap = { danger: 'delete', warning: 'warning', success: 'check_circle' };
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML = `
    <div class="modal" style="max-width:400px">
      <div class="modal-body">
        <div class="confirm-dialog">
          <div class="confirm-icon ${type}">
            <span class="material-icons">${iconMap[type] || 'warning'}</span>
          </div>
          <h3>${escapeHtml(title)}</h3>
          <p>${escapeHtml(message)}</p>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline" id="${id}-cancel">Cancel</button>
        <button class="btn btn-${type}" id="${id}-confirm">${escapeHtml(confirmText)}</button>
      </div>
    </div>`;
  document.body.appendChild(overlay);
  document.body.style.overflow = 'hidden';
  overlay.querySelector(`#${id}-cancel`).onclick = () => { overlay.remove(); document.body.style.overflow = ''; };
  overlay.querySelector(`#${id}-confirm`).onclick = async () => {
    overlay.remove(); document.body.style.overflow = '';
    await onConfirm();
  };
  overlay.onclick = (e) => { if (e.target === overlay) { overlay.remove(); document.body.style.overflow = ''; } };
}

// ── Sidebar / hamburger toggle ──────────────────────────────────────────────
export function initSidebar() {
  const sidebar = document.querySelector('.sidebar');
  const hamburger = document.querySelector('.hamburger');
  const overlay = document.querySelector('.overlay');
  if (!sidebar || !hamburger) return;

  hamburger.onclick = () => {
    sidebar.classList.toggle('open');
    if (overlay) overlay.classList.toggle('show');
  };
  if (overlay) {
    overlay.onclick = () => { sidebar.classList.remove('open'); overlay.classList.remove('show'); };
  }

  // Highlight active nav item
  const current = location.pathname.split('/').pop() || 'dashboard.html';
  document.querySelectorAll('.nav-item[data-page]').forEach(el => {
    if (el.dataset.page === current) el.classList.add('active');
  });
}

// ── Tabs ────────────────────────────────────────────────────────────────────
export function initTabs(containerId) {
  const container = document.getElementById(containerId) || document;
  container.querySelectorAll('.tab-btn').forEach(btn => {
    btn.onclick = () => {
      container.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      container.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      const panel = container.querySelector(`.tab-panel[data-tab="${btn.dataset.tab}"]`);
      if (panel) panel.classList.add('active');
    };
  });
}

// ── Search filter ───────────────────────────────────────────────────────────
export function initSearch(inputId, rowSelector) {
  const input = document.getElementById(inputId);
  if (!input) return;
  input.oninput = () => {
    const q = input.value.toLowerCase();
    document.querySelectorAll(rowSelector).forEach(el => {
      el.style.display = el.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  };
}

// ── Date/time helpers ───────────────────────────────────────────────────────
export function formatDate(isoString) {
  if (!isoString) return '—';
  const d = new Date(isoString);
  if (isNaN(d)) return isoString;
  return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

export function timeAgo(isoString) {
  if (!isoString) return '';
  const diff = Date.now() - new Date(isoString).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1)  return 'Just now';
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  const d = Math.floor(h / 24);
  return `${d}d ago`;
}

// ── String helpers ──────────────────────────────────────────────────────────
export function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

export function initials(name) {
  const parts = (name || '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return '?';
  if (parts.length === 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

export function avatarHtml(name, photoUrl, size = 52) {
  const style = `width:${size}px;height:${size}px;border-radius:${Math.round(size * .27)}px;
    background:var(--primary-light);color:var(--primary);
    display:flex;align-items:center;justify-content:center;
    font-size:${Math.round(size * .33)}px;font-weight:700;overflow:hidden;flex-shrink:0;`;
  if (photoUrl) return `<div style="${style}"><img src="${escapeHtml(photoUrl)}" style="width:100%;height:100%;object-fit:cover" onerror="this.parentElement.innerHTML='${initials(name)}'" /></div>`;
  return `<div style="${style}">${initials(name)}</div>`;
}

// ── Badge helper ────────────────────────────────────────────────────────────
export function statusBadge(status) {
  const map = {
    pending:   'badge-pending',
    approved:  'badge-approved',
    rejected:  'badge-rejected',
    upcoming:  'badge-upcoming',
    completed: 'badge-completed',
    cancelled: 'badge-cancelled',
  };
  const cls = map[status?.toLowerCase()] || 'badge-pending';
  return `<span class="badge ${cls}"><span class="badge-dot"></span>${escapeHtml(status || 'unknown')}</span>`;
}

// ── Unread notification badge updater ───────────────────────────────────────
export function updateNavBadge(count) {
  const badge = document.getElementById('notif-nav-badge');
  const dot   = document.getElementById('header-notif-dot');
  if (badge) { badge.textContent = count > 0 ? (count > 99 ? '99+' : count) : ''; badge.style.display = count > 0 ? 'flex' : 'none'; }
  if (dot)   { dot.style.display = count > 0 ? 'block' : 'none'; }
}
