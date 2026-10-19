# Nextgen public websites

**Publication status: unpublished at the owner's request.** Both custom-domain bindings were removed from Cloudflare. Workers.dev and preview URLs remain disabled. Workers, assets, server secrets and saved enquiries are preserved. Configuration contains no public routes; restoring publication requires explicitly adding the intended custom-domain routes again.

Two Cloudflare Workers serve curated English documentation, landing pages and real application screenshots:

- https://components.softwarenextgen.com (48 documentation pages)
- https://reports.softwarenextgen.com (12 documentation pages)

No installers, packages or public demo binaries are distributed. Reports sources are read from the sibling `NextgenReportEngine` checkout. Build dependencies: Python 3, markdown-it-py and Pygments. Worker checks use Node 24's built-in SQLite.

```sh
python3 sites/build.py
python3 sites/check_build.py
node sites/check_worker.mjs
wrangler deploy --config sites/wrangler.components.json
wrangler deploy --config sites/wrangler.reports.json
```

## Private form processing

Each Worker requires server secrets `FORM_SECRET` (independent random signing key) and `NOTIFY_EMAIL` (verified Cloudflare destination). Never place these in the build, repository or client JavaScript. Configure secrets with Wrangler secret commands before deployment. D1 database IDs and domain names in Wrangler configuration are not secrets.

Forms require a signed, one-hour HttpOnly/Secure/SameSite cookie, matching token and same-origin POST. Input lengths, consent, a honeypot and an atomic per-IP-hash hourly rate limit are checked. Requests are stored before notification. Repeated submissions with the same token are idempotent. Notification recipients are fixed by the server secret, never by form input. The request email is only Reply-To.

The shared private D1 `requests` table records `notified`, `attempts` and `lease_until`. Cron retries every 15 minutes, up to 20 attempts. Operators must inspect rows with `notified=0 AND attempts>=20` and resolve delivery configuration before resetting attempts/lease for those specific rows. Notification success means Cloudflare accepted the send; inbox placement is not guaranteed. A process crash after sending but before marking success can produce a duplicate notification.

Cron removes requests after 365 days and clears IP hashes after one day. Database access is restricted to the Cloudflare account and Worker bindings; no public request-list endpoint exists.

## Verification — 2026-10-19

- 66 generated HTML pages checked for valid local links/assets/anchors, no private destination address and no installer/download links.
- 16 Worker checks cover real SQLite storage, idempotency, validation, CSRF, rate limits, failed delivery persistence and retry.
- 28 visible Chrome local checks cover desktop/mobile layouts, images, documentation navigation/search/highlighting and forms.
- Both custom domains deployed and opened over HTTPS in the user's Chrome. Published Grid and template documentation rendered with highlighted examples.
- One clearly labelled test enquiry per site submitted through the live browser form. D1 console confirmed both stored with `notified=1, attempts=1`: Cloudflare accepted both emails. Gmail inbox receipt remains unverified.
- Root-domain Email Routing activation was blocked by approval review and was NOT applied. Successful send verification means the proposed root MX/SPF/DKIM changes are not required for the current deployment.
- Automated urllib live-page comparison received HTTP 403; browser access and submissions succeeded. No security rules were weakened.

Screenshots and check logs are retained in ignored `artifacts/sites/` and `artifacts/sites-local-qa.log`. Source screenshots used by the public sites are tracked under `sites/screenshots/`.
