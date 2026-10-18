export function dialog(element, open) {
 if (open && !element.open) element.showModal();
 if (!open && element.open) element.close();
}
export function tabs(element) {
 element.addEventListener('keydown', event => {
  if (event.target.getAttribute('role') !== 'tab') return;
  const tabs = [...element.querySelectorAll('[role="tab"]')].filter(t => !t.disabled);
  const index = tabs.indexOf(event.target);
  let next;
  if (event.key === 'ArrowRight') next = (index + 1) % tabs.length;
  if (event.key === 'ArrowLeft') next = (index - 1 + tabs.length) % tabs.length;
  if (event.key === 'Home') next = 0;
  if (event.key === 'End') next = tabs.length - 1;
  if (next !== undefined) { event.preventDefault(); tabs[next].focus(); tabs[next].click(); }
 });
}
