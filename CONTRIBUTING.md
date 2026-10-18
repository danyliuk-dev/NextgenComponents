# Component changes

Every public component must have a detailed Russian manual page with Blazor and Flutter examples, parameter/event documentation, state/validation rules and current limitations. Add reviewed content to `scripts/manual_content.py`, then run `python3 scripts/generate_manual.py`. The generator fails if a public Blazor component lacks curated content; both platforms must remain aligned.

Compile/analyze examples with `python3 scripts/check_manual_examples.py` (optional `--dotnet` / `--dart` executable paths). It uses existing Flutter dependency resolution, creates ignored Razor build fixtures and cleans up the temporary Dart file. Validate examples whenever API or examples change. Generated declarations supplement the prose; they do not replace an explanation of behavior.

Update the capability matrix, catalogue, gallery and verification evidence with each feature. Do not mark full Telerik parity for a limited subset. Run appropriate library tests and review interactions in visible local Chrome on Linux iMac. Coordinate browser use before opening an isolated profile; preserve unrelated sessions. Native mobile testing remains a separate phase.
