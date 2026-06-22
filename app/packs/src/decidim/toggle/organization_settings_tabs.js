/**
 * Self-contained settings tabs (no Decidim accordion).
 * Keeps tab selection in the URL hash (#panel-toggle-<id>) so it survives save redirects.
 */
const CONTAINER_SELECTOR = ".js-decidim-toggle-settings-tabs";
const PANEL_PREFIX = "panel-toggle-";

function getContainers() {
  return document.querySelectorAll(CONTAINER_SELECTOR);
}

function getTriggerForPanel(container, panelId) {
  return container.querySelector(`[data-controls="${panelId}"]`);
}

function getDefaultTrigger(container) {
  return (
    container.querySelector('.tab-x[data-controls][data-open="true"]') ||
    container.querySelector(".tab-x[data-controls]")
  );
}

function activateTab(container, trigger) {
  const panelId = trigger.dataset.controls;
  if (!panelId) return;

  container.querySelectorAll(".tab-x[data-controls]").forEach((button) => {
    const isActive = button === trigger;
    button.setAttribute("aria-expanded", isActive ? "true" : "false");
    if (isActive) {
      button.dataset.open = "true";
    } else {
      delete button.dataset.open;
    }
  });

  container.querySelectorAll(`[id^="${PANEL_PREFIX}"]`).forEach((panel) => {
    panel.setAttribute("aria-hidden", panel.id === panelId ? "false" : "true");
  });
}

function activateTabFromHash(container) {
  const raw = window.location.hash.replace(/^#/, "");
  if (!raw || !raw.startsWith(PANEL_PREFIX)) return;

  const panel = document.getElementById(raw);
  if (!panel || !container.contains(panel)) return;

  const trigger = getTriggerForPanel(container, raw);
  if (!trigger || trigger.getAttribute("aria-expanded") === "true") return;

  activateTab(container, trigger);
}

function initialTrigger(container) {
  const raw = window.location.hash.replace(/^#/, "");
  if (raw && raw.startsWith(PANEL_PREFIX)) {
    const panel = document.getElementById(raw);
    const trigger = getTriggerForPanel(container, raw);
    if (panel && container.contains(panel) && trigger) return trigger;
  }

  return getDefaultTrigger(container);
}

function syncHash(panelId) {
  const newHash = `#${panelId}`;
  if (window.location.hash === newHash) return;

  const url = `${window.location.pathname}${window.location.search}${newHash}`;
  window.history.replaceState(null, "", url);
}

function initContainer(container) {
  const trigger = initialTrigger(container);
  if (trigger) activateTab(container, trigger);

  container.addEventListener("click", (event) => {
    const button = event.target.closest(".tab-x[data-controls]");
    if (!button || !container.contains(button)) return;

    activateTab(container, button);

    const panelId = button.dataset.controls;
    if (panelId && panelId.startsWith(PANEL_PREFIX)) {
      syncHash(panelId);
    }
  });
}

function init() {
  getContainers().forEach(initContainer);
  window.addEventListener("hashchange", () => {
    getContainers().forEach(activateTabFromHash);
  });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
