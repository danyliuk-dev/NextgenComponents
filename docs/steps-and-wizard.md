# Stepper and Wizard 0.28.0

Original Blazor and Flutter Web implementations. Reviewed the public [Telerik Stepper](https://www.telerik.com/blazor-ui/documentation/components/stepper/overview), [step states](https://www.telerik.com/blazor-ui/documentation/components/stepper/steps/overview) and [Wizard](https://www.telerik.com/blazor-ui/documentation/components/wizard/overview) documentation on 2026-10-19. No proprietary source was imported and no API/feature parity is claimed.

| Capability | Implemented on both Web platforms |
|---|---|
| Stepper | Controlled index, disabled/optional/valid indicators, horizontal wrapping and vertical orientation |
| Linear flow | Any earlier enabled step, or the next enabled step; disabled steps are skipped |
| Wizard | Current-step content, Back/Next/Finish and header navigation |
| Validation | Async application callback before forward movement and Finish; message blocks transition |
| Busy/error state | Duplicate actions blocked, recoverable generic exception message, stale validation ignored after reset |
| Completion | Async handler; successful completion prevents duplicate local submission until reset |
| Keyboard | Standard Tab and Enter/Space button behavior |
| Accessibility | Current/selected step semantics, labeled content and live status/error messages |

Optional and Valid are presentation, not automatic validation or skip commands. The application owns form models, validation and persistence. Only active content is rendered; preserve drafts in the parent. Completion is not a backend idempotency guarantee. Reset does not undo external side effects of an already-running save handler.

Limits: 1–30 steps, nonempty labels up to 120 UTF-16 units, enabled in-range current index. No automatic focus movement, animated transitions, roving arrow-key navigation or durable state. Native/mobile and full screen-reader audits remain separate.

See [NgStepper](manual/NgStepper.md), [NgWizard](manual/NgWizard.md), and the Steps and wizard gallery (`/steps` in Blazor). Both demos include Code examples generated from the same English manual source.

## Stepper/Wizard workbench (0.28)

Both Web implementations add indicator/label templates, all/labels/indicators display modes and RTL while retaining complete accessible step names. Wizard adds top/bottom/start/end stepper placement (logical side positions mirror in RTL and stack on narrow layouts), custom action templates/builders, editable built-in button captions, an async cancellable BeforeChange guard and ResetKey.

The guard runs before forward validation and before backward changes or Finish. All navigation entry points, including custom action callbacks, share the same busy/completion guards. ResetKey invalidates stale async results at the same step without reconstructing the component. External network work and save side effects remain application-owned. The NgWizardActions context distinguishes IsLast from CanNext so a pending check does not incorrectly show a Finish action.

Reference audit includes [Stepper display and steps](https://www.telerik.com/blazor-ui/documentation/components/stepper/steps/overview), [step templates](https://www.telerik.com/blazor-ui/documentation/components/stepper/step-template), [Wizard layout](https://www.telerik.com/blazor-ui/documentation/components/wizard/layout), [Wizard buttons](https://www.telerik.com/blazor-ui/documentation/components/wizard/structure/buttons), [Wizard events](https://www.telerik.com/blazor-ui/documentation/components/wizard/events) and [Wizard templates](https://www.telerik.com/blazor-ui/documentation/components/wizard/templates). The implementation provides an original unified transition callback contract rather than Telerik event argument/API compatibility. Remaining scope includes automatic form integration/validation icons, per-step event/template overrides, full localization, focus management/arrow navigation, animations and native-platform/screen-reader certification.
