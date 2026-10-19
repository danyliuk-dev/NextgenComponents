namespace NextgenComponents.Blazor;

public enum NgGridEditOperation { Create, Update, Delete }
public record NgGridEditField(string Key,string Label,bool Required=false);
/// <summary>Application-owned persistence. Return a safe validation message, or null on success.</summary>
public sealed class NgGridEditing<T> {
 public required IReadOnlyList<NgGridEditField> Fields {get;init;}
 public required Func<T?,IReadOnlyDictionary<string,string>> Draft {get;init;}
 public required Func<NgGridEditOperation,string?,IReadOnlyDictionary<string,string>,CancellationToken,Task<string?>> Commit {get;init;}
 public Func<IReadOnlyDictionary<string,string>,string?>? Validate {get;init;}
 public Func<T,bool>? CanUpdate {get;init;}
 public Func<T,bool>? CanDelete {get;init;}
 public bool AllowCreate {get;init;}=true;
 public bool ReadOnly {get;init;}
 public string CreateText {get;init;}="Create record";
 public string UpdateText {get;init;}="Edit";
 public string DeleteText {get;init;}="Delete";
 public string SaveText {get;init;}="Save";
 public string CancelText {get;init;}="Cancel";
 public string ConfirmDeleteText {get;init;}="Delete this record?";
 public string RequiredText {get;init;}="Complete all required fields.";
 public string ErrorText {get;init;}="Unable to save changes. Please retry.";
 public string SavingText {get;init;}="Saving changes…";
 public void Check(){if(Fields.Count==0 || Fields.Any(f=>string.IsNullOrWhiteSpace(f.Key)) || Fields.Select(f=>f.Key).Distinct().Count()!=Fields.Count)throw new ArgumentException("Editor fields must have unique nonempty keys.");}
}
