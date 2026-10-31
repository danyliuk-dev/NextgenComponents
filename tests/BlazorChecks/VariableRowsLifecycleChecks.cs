using Microsoft.JSInterop;
using NextgenComponents.Blazor;
using System.Reflection;

static class VariableRowsLifecycleChecks {
 public static async Task<int> Run(){
  var runtime=new DelayedRuntime();var component=new VariableRows<int>();
  var flags=BindingFlags.Instance|BindingFlags.NonPublic;
  typeof(VariableRows<int>).GetProperty("JS",flags)!.SetValue(component,runtime);
  var render=typeof(VariableRows<int>).GetMethod("OnAfterRenderAsync",flags)!;
  var first=(Task)render.Invoke(component,[true])!;
  var second=(Task)render.Invoke(component,[false])!;
  if(runtime.Imports!=1)throw new Exception("Repeated render started concurrent interop imports");
  runtime.Ready.SetResult(runtime.Module);
  await Task.WhenAll(first,second);
  if(runtime.Module.Creates!=1 || runtime.Module.View.Updates!=2)throw new Exception("Interop reentry installed duplicate controllers");
  await component.DisposeAsync();
  if(runtime.Module.View.Cleanups!=1 || runtime.Module.View.Disposals!=1)throw new Exception("Controller cleanup is not single-owner");
  Console.WriteLine("PASS delayed Server interop shares initialization and cleans up one controller");return 3;
 }
 private sealed class DelayedRuntime:IJSRuntime {
  public int Imports;public FakeModule Module=new();
  public TaskCompletionSource<IJSObjectReference> Ready=new(TaskCreationOptions.RunContinuationsAsynchronously);
  public async ValueTask<TValue> InvokeAsync<TValue>(string identifier,object?[]? args){Imports++;return (TValue)(object)await Ready.Task;}
  public ValueTask<TValue> InvokeAsync<TValue>(string identifier,CancellationToken token,object?[]? args)=>InvokeAsync<TValue>(identifier,args);
 }
 private sealed class FakeModule:IJSObjectReference {
  public int Creates;public FakeView View=new();
  public ValueTask<TValue> InvokeAsync<TValue>(string identifier,object?[]? args){Creates++;return ValueTask.FromResult((TValue)(object)View);}
  public ValueTask<TValue> InvokeAsync<TValue>(string identifier,CancellationToken token,object?[]? args)=>InvokeAsync<TValue>(identifier,args);
  public ValueTask DisposeAsync()=>ValueTask.CompletedTask;
 }
 private sealed class FakeView:IJSObjectReference {
  public int Updates,Cleanups,Disposals;
  public ValueTask<TValue> InvokeAsync<TValue>(string identifier,object?[]? args){if(identifier=="update")Updates++;if(identifier=="dispose")Cleanups++;return ValueTask.FromResult(default(TValue)!);}
  public ValueTask<TValue> InvokeAsync<TValue>(string identifier,CancellationToken token,object?[]? args)=>InvokeAsync<TValue>(identifier,args);
  public ValueTask DisposeAsync(){Disposals++;return ValueTask.CompletedTask;}
 }
}
