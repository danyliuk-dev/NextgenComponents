const editors = new WeakMap();
export function attach(element, receiver) {
    if (editors.has(element)) return;
    const state = { composing: false };
    state.start = () => {
        state.composing = true;
        receiver.invokeMethodAsync('StateChanged', true, element.value).catch(() => {});
    };
    state.end = () => {
        state.composing = false;
        receiver.invokeMethodAsync('StateChanged', false, element.value).catch(() => {});
    };
    element.addEventListener('compositionstart', state.start);
    element.addEventListener('compositionend', state.end);
    editors.set(element, state);
}
export function canNotify(element, value) {
    return element.isConnected && !editors.get(element)?.composing &&
        !element.disabled && !element.readOnly && element.value === value;
}
export function detach(element) {
    const state = editors.get(element);
    if (!state) return;
    element.removeEventListener('compositionstart', state.start);
    element.removeEventListener('compositionend', state.end);
    editors.delete(element);
}

export function reset(element) {
    const state = editors.get(element);
    if (state) state.composing = false;
}
