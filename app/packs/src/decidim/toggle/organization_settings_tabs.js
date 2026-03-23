/**
 * Keeps organization settings tab selection in the URL hash (#panel-toggle-<id>)
 * so it survives save redirects and can be linked.
 */
const CONTAINER_ID = "decidim-toggle-settings-tabs";
const PANEL_PREFIX = "panel-toggle-";

function getContainer() {
  return document.getElementById(CONTAINER_ID);
}

function activateTabFromHash() {
  const container = getContainer();
  if (!container) return;

  const raw = window.location.hash.replace(/^#/, "");
  if (!raw || !raw.startsWith(PANEL_PREFIX)) return;

  const panel = document.getElementById(raw);
  if (!panel || !container.contains(panel)) return;

  const trigger = container.querySelector(`[data-controls="${raw}"]`);
  if (!trigger || trigger.getAttribute("aria-expanded") === "true") return;

  trigger.click();
}

function syncHashOnTabClick() {
  const container = getContainer();
  if (!container) return;

  container.addEventListener("click", (event) => {
    const trigger = event.target.closest(".tab-x[data-controls]");
    if (!trigger || !container.contains(trigger)) return;

    const panelId = trigger.dataset.controls;
    if (!panelId || !panelId.startsWith(PANEL_PREFIX)) return;

    const newHash = `#${panelId}`;
    if (window.location.hash !== newHash) {
      const url = `${window.location.pathname}${window.location.search}${newHash}`;
      window.history.replaceState(null, "", url);
    }
  });
}

function init() {
  syncHashOnTabClick();
  window.addEventListener("hashchange", activateTabFromHash);

  const run = () => activateTabFromHash();
  setTimeout(run, 0);
  setTimeout(run, 50);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
