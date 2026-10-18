namespace NextgenComponents.Blazor;

public sealed record NgPromptResponse(int Id, string Prompt, string Text);
public sealed record NgPromptFeedback(NgPromptResponse Response, bool? Helpful);

/// <summary>UI-thread session. Cancellation invalidates late results even if the provider ignores its token.</summary>
public sealed class NgPromptSession : IDisposable {
 public const int MaxPromptLength=8000, MaxResponseLength=32000, HistoryLimit=20;
 private readonly List<NgPromptResponse> responses=[];
 private CancellationTokenSource? cancellation;
 private int revision, sequence;
 private bool disposed;
 public IReadOnlyList<NgPromptResponse> Responses=>responses.AsReadOnly();
 public NgPromptResponse? Selected {get;private set;}
 public bool IsBusy {get;private set;}
 public string? Error {get;private set;}
 public string Status {get;private set;}="Ready";
 public event Action? Changed;
 private void Notify(){if(!disposed)Changed?.Invoke();}
 public async Task<NgPromptResponse?> RunAsync(string prompt,Func<string,CancellationToken,Task<string>> generate){
  ObjectDisposedException.ThrowIf(disposed,this);ArgumentNullException.ThrowIfNull(generate);
  prompt=prompt.Trim();if(prompt.Length is 0 or >MaxPromptLength)throw new ArgumentException("Prompt must contain 1–8000 characters.",nameof(prompt));
  if(IsBusy)return null;
  var version=++revision;var source=new CancellationTokenSource();cancellation=source;IsBusy=true;Error=null;Status="Generating…";Notify();
  try {
   var text=await generate(prompt,source.Token);
   if(version!=revision||disposed)return null;
   if(string.IsNullOrWhiteSpace(text)||text.Length>MaxResponseLength)throw new ArgumentException("Invalid response.");
   var response=new NgPromptResponse(++sequence,prompt,text);responses.Add(response);if(responses.Count>HistoryLimit)responses.RemoveAt(0);
   Selected=response;Status="Response ready.";return response;
  }catch(OperationCanceledException){if(version==revision&&!disposed)Status="Cancelled.";return null;}
  catch(Exception){if(version==revision&&!disposed){Error="Generation failed. Try again.";Status="Request failed.";}return null;}
  finally{if(version==revision&&!disposed){IsBusy=false;cancellation=null;Notify();}source.Dispose();}
 }
 public void Cancel(){if(!IsBusy)return;++revision;var source=cancellation;cancellation=null;IsBusy=false;Error=null;Status="Cancelled.";try{source?.Cancel();}catch(AggregateException){}Notify();}
 public void Select(int id){Selected=responses.FirstOrDefault(r=>r.Id==id)??Selected;Notify();}
 public void Clear(){Cancel();responses.Clear();Selected=null;Error=null;Status="History cleared.";Notify();}
 public void Dispose(){disposed=true;Cancel();Changed=null;}
}
