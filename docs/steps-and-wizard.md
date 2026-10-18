# Stepper and Wizard 0.11.0

Original Blazor and Flutter Web implementations. Reviewed the public [Telerik Stepper](https://www.telerik.com/blazor-ui/documentation/components/stepper/overview), [step states](https://www.telerik.com/blazor-ui/documentation/components/stepper/steps/overview) and [Wizard](https://www.telerik.com/blazor-ui/documentation/components/wizard/overview) documentation on 2026-10-18. No proprietary source was imported and no API/feature parity is claimed.

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

Limits: 1–30 steps, nonempty labels up to 120 UTF-16 units, enabled in-range current index. No automatic focus movement, custom button/step templates, side/bottom layouts, animated transitions, roving arrow-key navigation or durable state. Native/mobile and full screen-reader audits remain separate.

See [NgStepper](manual/NgStepper.md), [NgWizard](manual/NgWizard.md), and the Steps and wizard gallery (`/steps` in Blazor). Both demos include Code examples generated from the same English manual source.
