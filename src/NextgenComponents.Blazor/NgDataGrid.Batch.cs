namespace NextgenComponents.Blazor;

public partial class NgDataGrid<TItem> {
    private sealed record PendingChange(NgGridChange Change,TItem? Original);
    private readonly List<PendingChange> batchChanges=[];
    private string? editKey;
    private TItem? editRecord;
    private bool previousBatchMode;
    private bool IsBatch=>Editing?.CommitBatch is not null;
    private bool CanReviewBatch=>!disposed && !saving && editOperation is null;
    private bool CanSaveBatch=>CanReviewBatch && !loading && !error && Editing is {ReadOnly:false} && IsBatch && batchChanges.Count>0;
    private string ChangeLabel(NgGridChange change)=>change.Operation switch {NgGridEditOperation.Create=>Editing!.CreateText,NgGridEditOperation.Delete=>Editing!.DeleteText,_=>Editing!.UpdateText};
    private bool PendingAllowed(PendingChange entry){
        if(Editing is not {ReadOnly:false} config)return false;
        if(entry.Change.Operation==NgGridEditOperation.Create)return config.AllowCreate;
        var rows=(IsRemote?filtered:Items).Where(r=>RowId(r)==entry.Change.Id).ToArray();
        var row=rows.Length==1?rows[0]:IsRemote && rows.Length==0?entry.Original:default;
        return row is not null && (IsRemote || rows.Length==1) && Allowed(row,entry.Change.Operation==NgGridEditOperation.Delete);
    }
    private void StageChange(NgGridEditOperation operation,IReadOnlyDictionary<string,string> values){
        var index=batchChanges.FindIndex(e=>e.Change.Key==editKey);
        if(index<0 && batchChanges.Count>=Editing!.MaxPendingChanges){editError=Editing.BatchLimitText;return;}
        var entry=new PendingChange(new(editKey??Guid.NewGuid().ToString("N"),operation,editId,values),editRecord);
        if(index<0)batchChanges.Add(entry);else batchChanges[index]=entry;
        CloseEdit();
    }
    private void BeginQueued(string key){
        if(!CanReviewBatch || !IsBatch || loading || error)return;
        var entry=batchChanges.FirstOrDefault(e=>e.Change.Key==key);
        if(entry is null || entry.Change.Operation==NgGridEditOperation.Delete)return;
        try{if(!PendingAllowed(entry)){editError=Editing!.BatchConflictText;return;}}
        catch{editError=Editing!.ErrorText;return;}
        ++editRevision;editKey=key;editRecord=entry.Original;editId=entry.Change.Id;
        editOperation=entry.Change.Operation;editCell=null;editError=null;draft=new(entry.Change.Values);
    }
    private void UndoChange(string key){if(!CanReviewBatch)return;batchChanges.RemoveAll(e=>e.Change.Key==key);editError=null;}
    private void DiscardBatch(){if(!CanReviewBatch)return;batchChanges.Clear();editError=null;}
    private async Task SaveBatch(){
        if(!CanSaveBatch)return;
        var config=Editing!;
        try{
            editError=null;
            if(batchChanges.Count>config.MaxPendingChanges){editError=config.BatchLimitText;return;}
            foreach(var entry in batchChanges){
                if(!PendingAllowed(entry)){editError=config.BatchConflictText;return;}
                if(entry.Change.Operation==NgGridEditOperation.Delete)continue;
                var values=entry.Change.Values;
                editError=config.Fields.Any(f=>f.Required && string.IsNullOrWhiteSpace(values.GetValueOrDefault(f.Key)))?config.RequiredText:config.Validate?.Invoke(values);
                if(editError is not null)return;
            }
        }catch{editError=config.ErrorText;return;}
        var changes=Array.AsReadOnly(batchChanges.Select(e=>e.Change).ToArray());
        saving=true;var ticket=++editRevision;using var pending=new CancellationTokenSource();editPending=pending;
        try{
            var message=await config.CommitBatch!(changes,pending.Token);
            if(disposed || ticket!=editRevision)return;
            saving=false;editError=message;
            if(message is null){batchChanges.Clear();await ReloadAsync();}
        }catch{if(!disposed && ticket==editRevision)editError=config.ErrorText;}
        finally{if(!disposed && ticket==editRevision)saving=false;if(ReferenceEquals(editPending,pending))editPending=null;}
    }
}
