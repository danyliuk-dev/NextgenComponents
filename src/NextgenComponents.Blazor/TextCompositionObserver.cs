using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;

namespace NextgenComponents.Blazor;

// Keeps native composition state beside the DOM element, including composition
// that starts while a server-side debounce callback is already queued.
internal sealed class TextCompositionObserver(IJSRuntime js, Func<bool, string?, Task> changed) : IAsyncDisposable
{
    private Task? attachment;
    private IJSObjectReference? module;
    private DotNetObjectReference<TextCompositionObserver>? reference;
    private ElementReference element;
    private bool disposed;

    public Task AttachAsync(ElementReference target) => attachment ??= AttachCoreAsync(target);
    private async Task AttachCoreAsync(ElementReference target)
    {
        element = target;
        var imported = await js.InvokeAsync<IJSObjectReference>("import", "./_content/NextgenComponents.Blazor/text-composition.js");
        module = imported;
        if (disposed) return;
        reference = DotNetObjectReference.Create(this);
        await imported.InvokeVoidAsync("attach", element, reference);
    }

    [JSInvokable]
    public Task StateChanged(bool active, string? value) => disposed ? Task.CompletedTask : changed(active, value);

    public async Task<bool> CanNotifyAsync(string? value)
    {
        if (attachment is not null) await attachment;
        return !disposed && module is not null && await module.InvokeAsync<bool>("canNotify", element, value ?? "");
    }

    public async Task ResetAsync()
    {
        if (attachment is not null) await attachment;
        if (!disposed && module is not null) await module.InvokeVoidAsync("reset", element);
    }

    public async ValueTask DisposeAsync()
    {
        if (disposed) return;
        disposed = true;
        try
        {
            if (attachment is not null) await attachment;
            if (module is not null)
            {
                await module.InvokeVoidAsync("detach", element);
                await module.DisposeAsync();
            }
        }
        catch (JSDisconnectedException) { }
        catch (TaskCanceledException) { }
        finally { reference?.Dispose(); }
    }
}
