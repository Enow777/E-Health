// ── Toast ─────────────────────────────────────────────────────────────────────
export function showToast(message, type = 'info', duration = 3500) {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  const icons = { success: '✓', error: '✕', warning: '⚠', info: 'ℹ' };
  toast.innerHTML = `<span class="toast-icon">${icons[type] || 'ℹ'}</span><span>${message}</span>`;
  container.appendChild(toast);
  requestAnimationFrame(() => toast.classList.add('show'));
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, duration);
}

// ── Modal ─────────────────────────────────────────────────────────────────────
export function openModal(id) {
  const el = document.getElementById(id);
  if (el) { el.classList.add('open'); document.body.style.overflow = 'hidden'; }
}
export function closeModal(id) {
  const el = document.getElementById(id);
  if (el) { el.classList.remove('open'); document.body.style.overflow = ''; }
}

export function confirmDialog(title, message, confirmLabel = 'Confirm', danger = true) {
  return new Promise((resolve) => {
    const id = 'confirm-modal-' + Date.now();
    const modal = document.createElement('div');
    modal.className = 'modal-overlay open';
    modal.id = id;
    modal.innerHTML = `
      <div class="modal" style="max-width:420px">
        <div class="modal-header">
          <h3>${title}</h3>
          <button class="modal-close" onclick="document.getElementById('${id}').remove();document.body.style.overflow=''">✕</button>
        </div>
        <div class="modal-body"><p>${message}</p></div>
        <div class="modal-footer">
          <button class="btn btn-ghost" id="${id}-cancel">Cancel</button>
          <button class="btn ${danger ? 'btn-danger' : 'btn-primary'}" id="${id}-confirm">${confirmLabel}</button>
        </div>
      </div>`;
    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';
    document.getElementById(`${id}-cancel`).onclick = () => { modal.remove(); document.body.style.overflow = ''; resolve(false); };
    document.getElementById(`${id}-confirm`).onclick = () => { modal.remove(); document.body.style.overflow = ''; resolve(true); };
  });
}

// ── Sidebar ───────────────────────────────────────────────────────────────────
export function initSidebar() {
  const toggle = document.getElementById('sidebar-toggle');
  const sidebar = document.getElementById('sidebar');
  if (toggle && sidebar) {
    toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
    document.addEventListener('click', (e) => {
      if (window.innerWidth < 768 && !sidebar.contains(e.target) && !toggle.contains(e.target)) {
        sidebar.classList.remove('open');
      }
    });
  }
  // Active nav link
  const path = window.location.pathname.split('/').pop() || 'dashboard.html';
  document.querySelectorAll('.nav-link').forEach((link) => {
    if (link.getAttribute('href') === path) link.classList.add('active');
  });
}

// ── Tabs ──────────────────────────────────────────────────────────────────────
export function initTabs(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return;
  container.querySelectorAll('.tab-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      container.querySelectorAll('.tab-btn').forEach((b) => b.classList.remove('active'));
      container.querySelectorAll('.tab-panel').forEach((p) => p.classList.remove('active'));
      btn.classList.add('active');
      const panel = document.getElementById(btn.dataset.tab);
      if (panel) panel.classList.add('active');
    });
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────
export function formatDate(isoString) {
  if (!isoString) return '—';
  return new Date(isoString).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}
export function timeAgo(isoString) {
  if (!isoString) return '—';
  const diff = Date.now() - new Date(isoString).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1) return 'just now';
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}
export function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
export function initials(name) {
  if (!name) return '?';
  return name.trim().split(/\s+/).map((w) => w[0]).join('').toUpperCase().slice(0, 2);
}
export function avatarHtml(name, color = '#4F46E5') {
  return `<div class="avatar" style="background:${color}">${initials(name)}</div>`;
}
export function statusBadge(status) {
  const map = {
    pending:     ['badge-warning',  'Pending'],
    approved:    ['badge-success',  'Approved'],
    rejected:    ['badge-danger',   'Rejected'],
    independent: ['badge-info',     'Independent'],
    active:      ['badge-success',  'Active'],
    suspended:   ['badge-danger',   'Suspended'],
  };
  const [cls, label] = map[status] || ['badge-muted', status || 'Unknown'];
  return `<span class="badge ${cls}">${label}</span>`;
}
