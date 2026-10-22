# AMS mobile API (v1)

The API for the AMS Flutter app. One app for everyone, company users and employees: what each person sees comes from the server, never from the app.

Up to date with Phase 7 (22 October 2026). New endpoints are added here as each phase ships.

## Basics

| | |
|---|---|
| Base URL (staging) | `https://laravel.ams-hrpayroll.com/api/v1` |
| Format | JSON in and out. Send `Accept: application/json` on every request. |
| Authentication | `Authorization: Bearer <token>` on every request except `auth/login`, `auth/two-factor` and `auth/forgot-password`. |
| Tokens | Valid for 90 days. Logging out, a password change or the account being disabled ends them all; the app then gets `401 unauthenticated` and must show the login screen. |
| IDs | Every `id` is an opaque 26-character string (for example `01jb2x9k4m7q8r3t5v6w8y0z1a`). Never a number; never build or guess one. |
| Dates | `YYYY-MM-DD`. Times are ISO 8601 in UTC (`2026-10-22T09:15:00+00:00`); show them in the phone's time zone. |
| Rate limits | Login and two-factor: 5 per minute. Forgot password: 3 per minute. Everything else: 120 per minute per user. Over the limit: `429 too_many_requests`. |

### Response format

Success:

```json
{ "data": { ... } }
```

Lists also have `meta`:

```json
{ "data": [ ... ], "meta": { "page": 1, "per_page": 25, "total": 42, "last_page": 2 } }
```

`204 No Content` has no body.

Error:

```json
{ "error": { "code": "validation_failed", "message": "The given data was invalid.", "fields": { "personal_phone": ["The personal phone field format is invalid."] } } }
```

- The app decides what to do from `code`, **never from `message`**.
- `message` is safe to show to the person.
- `fields` appears only with `validation_failed`, keyed by input name; show each message under its field.

| HTTP | `code` | Meaning, and what the app does |
|---|---|---|
| 400 | `bad_request` | The request cannot be handled. |
| 401 | `unauthenticated` | No token, or the token has ended. Go to login. |
| 401 | `invalid_credentials` | Wrong login or password (one message for both). |
| 401 | `invalid_two_factor_code` | Wrong or used two-factor code, or the challenge has expired. |
| 403 | `forbidden` | Signed in, but not allowed to do this. |
| 403 | `account_unavailable` | The account is disabled, the company is suspended or closed, or the email is not verified yet. Show `message`. |
| 404 | `not_found` | Not there, or belongs to another company. |
| 405 | `method_not_allowed` | Wrong HTTP method. |
| 409 | `conflict` | Refused by a business rule (for example "a request is already waiting"). Show `message`. |
| 422 | `validation_failed` | Input not valid; see `fields`. |
| 429 | `too_many_requests` | Wait and try again (see the `Retry-After` header). |
| 500 | `server_error` | Something went wrong on our side. |

### Inputs

The server checks every field and refuses values that make no sense. The app should still limit input to the same characters, so people cannot type them in the first place:

| Kind of field | Allowed |
|---|---|
| Phone numbers | Digits, spaces and `+ ( ) -`; up to 20 characters |
| Names | Letters (any language), spaces, `' . -` |
| Postcodes | Letters, digits, space and `-`; up to 12 characters |
| Comments | Plain text; up to 1000 characters |

## The golden rule: the server decides access

- **Build the app menu from `GET /me` → `menu`.** Show only those items, in that order. Never hide or add items based on roles in the app.
- Use `permissions` only to show or hide buttons inside a screen. The server checks again on every call: a `403` means "not allowed".
- What someone may see about other people (their team, their location, everyone) is decided by the server. Lists come back already filtered.

## Authentication

### `POST /auth/login`

Two ways to sign in, one field `login`:
- by email: `login` = the email;
- by employee number: `login` = the employee number, plus `company_code` (the 6-character code the company gives its staff).

| Field | Rules |
|---|---|
| `login` | required, up to 255 |
| `password` | required, up to 255 |
| `company_code` | only with an employee number; up to 12 |
| `device_name` | required, up to 100 (for example "Pixel 8 – Android 15"); shown on the person's list of app sign-ins |

```json
{ "login": "ayesha@acme.pk", "password": "••••••••", "device_name": "Pixel 8" }
```

Response, no two-factor:

```json
{ "data": { "two_factor_required": false, "token": "q8Vb…" } }
```

Response, two-factor on:

```json
{ "data": { "two_factor_required": true, "challenge": "64-character string" } }
```

Errors:
- `invalid_credentials`;
- `account_unavailable` (disabled, company suspended, email not verified);
- `validation_failed`;
- `too_many_requests`.

### `POST /auth/two-factor`

| Field | Rules |
|---|---|
| `challenge` | required, from login; valid 5 minutes, usable once |
| `code` | 6 digits from the authenticator app, or |
| `recovery_code` | one of the person's recovery codes (each works once) |

Response: `{ "data": { "token": "…" } }`. Error: `invalid_two_factor_code`.

### `POST /auth/forgot-password`

`{ "email": "…" }`. The reply is always the same whether or not the address exists, so nobody can probe for accounts:

`{ "data": { "message": "If the address has an account, a reset link has been sent." } }`

The person resets the password from the email link in the browser.

### `POST /auth/logout`

Ends this app sign-in. Its push token is removed with it. `204`.

## Who am I

### `GET /me`

Call it after login, when the app opens, and when it comes back to the foreground. It drives the menu and the badges.

```json
{
  "data": {
    "user": { "id": "01j…", "name": "Ayesha Khan", "email": "ayesha@acme.pk", "two_factor_enabled": false },
    "company": { "id": "01j…", "name": "Acme Textiles", "code": "K7MP2Q" },
    "permissions": {
      "employees.view": ["own"],
      "employees.sensitive.view": ["own"],
      "pay.view": ["own"],
      "support.view": ["own"],
      "support.raise": null
    },
    "modules": ["attendance", "leave", "payroll"],
    "menu": [
      { "key": "home", "label": "Home", "icon": "home", "module": "core" },
      { "key": "requests", "label": "Requests", "icon": "inbox-stack", "module": "core" },
      { "key": "employees", "label": "Employees", "icon": "identification", "module": "core" }
    ],
    "badges": { "requests": 2 }
  }
}
```

**`permissions`:** permission ⇒ the scopes held, or `null` for a permission without scopes.
- Scopes: `own` (themself), `department` (the departments they manage), `location` (their assigned work locations), `company` (everyone).
- A missing key means "not allowed".

**`modules`:** the paid modules the company has. `core` is always on and not listed.

**`menu`:** the items to show, in order.
- `key` is stable: map it to your screen. Keys so far: `home`, `requests`, `employees`, `organisation`, `company`, `users`, `roles`, `support`.
- `icon` is a Heroicons name; map it to your icon set.
- Items for web-only admin screens (`organisation`, `company`, `users`, `roles`) can be left out of the app or open a "use the website" message.

**`badges`:** menu item key ⇒ count. Only non-zero counts appear; `{}` when there is nothing. Show the number on that menu item.

## My profile and ID card

### `GET /me/profile`

The signed-in employee's own profile, in the same shape as `GET /employees/{id}` below. `404` for a company user who is not an employee (for example some owners).

### `GET /me/card`

The ID card to show on screen. The app draws the QR code from `qr_value`.

```json
{
  "data": {
    "company": { "name": "Acme Textiles (Pvt) Ltd", "short_name": "Acme", "phone": "+92 21 1234567", "address": "Plot 4, Korangi, Karachi" },
    "name": "Ayesha Khan",
    "designation": "Officer",
    "department": "Sales",
    "employee_number": "EMP-0001",
    "phone": "0300 1234567",
    "blood_group": "B+",
    "valid_until": null,
    "emergency_phone": "0300 7654321",
    "card_no": 2,
    "issued_on": "2026-10-22",
    "colour": "#dc2626",
    "orientation": "vertical",
    "qr_value": "opaque string"
  }
}
```

- `qr_value` is the person's card token. Treat it like a password: never log it or send it anywhere else.
- A new card (HR issues one) makes the old value stop working, so fetch the card again rather than caching it for long.
- Optional values come back as `null`.

## Employees (team and colleagues)

### `GET /employees`

The people this user may see: a manager sees their department, HR their locations or everyone. Someone allowed only their own record gets just themself.

| Query | Rules |
|---|---|
| `search` | name, number or email; up to 100 |
| `location`, `department`, `designation` | an `id` |
| `employment_type` | `full_time`, `part_time`, `bank_staff` |
| `stage` | `joining`, `probation`, `active`, `notice`, `left` |
| `per_page` | 1–100 (default 25) |
| `page` | 1+ |

```json
{
  "data": [
    { "id": "01j…", "employee_number": "EMP-0001", "name": "Ayesha Khan", "designation": "Officer", "department": "Sales", "work_location": "Head office", "stage": "active" }
  ],
  "meta": { "page": 1, "per_page": 25, "total": 1, "last_page": 1 }
}
```

### `GET /employees/{id}`

One profile, with only the parts this viewer may see.

```json
{
  "data": {
    "id": "01j…", "employee_number": "EMP-0001", "name": "Ayesha Khan", "designation": "Officer",
    "department": "Sales", "work_location": "Head office", "stage": "active",
    "first_name": "Ayesha", "last_name": "Khan", "preferred_name": null,
    "has_photo": false,
    "stage_label": "Active",
    "sections": [ { "key": "overview", "label": "Overview" }, { "key": "personal", "label": "Personal" } ],
    "job": {
      "legal_entity": "Acme Textiles (Pvt) Ltd", "work_location": "Head office", "department": "Sales",
      "sub_department": null, "designation": "Officer", "grade": null,
      "employment_type": "full_time", "contract_type": "permanent", "contract_ends_on": null,
      "joined_on": "2025-10-22", "probation_ends_on": null, "confirmed_on": null,
      "last_working_day": null, "left_on": null, "length_of_service": "1 year"
    },
    "contact": { "work_email": "ayesha@acme.pk", "work_phone": null },
    "personal": {
      "gender": "female", "date_of_birth": "1995-04-12", "blood_group": "B+", "marital_status": "single",
      "nationality": "PK", "personal_email": null, "personal_phone": "0300 1234567",
      "address": { "line1": "House 12", "line2": null, "city": "Karachi", "postcode": "75500", "country": "PK" }
    },
    "emergency_contacts": [
      { "id": "01j…", "name": "Bilal Khan", "relationship": "Brother", "phone": "0300 7654321", "alternative_phone": null, "is_primary": true }
    ],
    "documents": [ { "id": "01j…", "kind": "passport", "expires_on": "2026-11-30", "days_left": 39 } ]
  }
}
```

- `personal`, `emergency_contacts` and `documents` (only documents expiring soon) are present **only** when the viewer may see sensitive details. Otherwise the keys are missing.
- `sections` lists the profile tabs this viewer may open. Later modules add tabs here (attendance, leave, pay); show the ones you support.
- The photo is not available through the API yet (`has_photo` only); it comes in a later update.

## Requests and approvals

One inbox for every kind of request. Today the only kind is `employee_details_change` (an employee changing their own contact details). Leave, attendance corrections, overtime, loans and money requests will arrive in the same inbox with no new endpoints: only new `type` values.

### `GET /approvals`

| Query | Rules |
|---|---|
| `box` | `waiting` (default: waiting for **my** decision), `pending` (everything waiting that I may decide for HR; empty for people without that right), `mine` (what I asked for), `decided` (what I approved or rejected) |
| `type` | a request type, for example `employee_details_change` |
| `per_page` | 1–100 (default 25) |
| `page` | 1+ |

```json
{
  "data": [
    {
      "id": "01j…",
      "type": "employee_details_change",
      "type_label": "Change of my details",
      "title": "Change of my details: personal phone",
      "employee": { "id": "01j…", "name": "Ayesha Khan", "number": "EMP-0001", "department": "Sales" },
      "requested_by": "Ayesha Khan",
      "status": "pending",
      "status_label": "Waiting",
      "status_tone": "amber",
      "waiting_on": "Department manager",
      "submitted_at": "2026-10-22T09:15:00+00:00",
      "submitted_ago": "2 hours ago",
      "decided_at": null
    }
  ],
  "meta": { "page": 1, "per_page": 25, "total": 1, "last_page": 1 }
}
```

- `status`: `pending`, `approved`, `rejected`, `cancelled`.
- `status_tone`: a colour hint, one of `amber`, `emerald`, `rose`, `slate`.

### `GET /approvals/{id}`

The list row, plus:

```json
{
  "data": {
    "...": "same fields as the list row",
    "changes": [ { "label": "Personal phone", "before": "0300 1111111", "after": "0300 2222222" } ],
    "facts": [],
    "steps": [
      { "position": 1, "approver": "Department manager", "status": "approved", "status_label": "Approved", "status_tone": "emerald", "skipped_reason": null, "approvers": [] },
      { "position": 2, "approver": "Role: HR officer", "status": "current", "status_label": "Waiting for approval", "status_tone": "amber", "skipped_reason": null, "approvers": ["Sara Ahmed", "Usman Ali"] }
    ],
    "decisions": [
      { "step": 1, "by": "Maryam Siddiqui", "decision": "approved", "decision_label": "Approved", "comment": "Fine", "was_override": false, "at": "2026-10-22T10:00:00+00:00", "ago": "1 hour ago" }
    ],
    "can": { "approve": true, "reject": true, "as_override": false, "cancel": false }
  }
}
```

The fields:
- `changes`: what the request changes. `before` and `after` are display text; `null` means empty.
- `facts`: other label / value pairs (later request types use it).
- `steps[].status`: `waiting` (still to come), `current`, `approved`, `rejected`, `skipped` (with `skipped_reason` in words), `not_reached`.
- `steps[].approvers`: the names it waits for, only on the current step.
- `can`: **which buttons to show.**
  - `as_override` = this person is not the step's approver but may decide for HR. Their decision ends the whole request; tell them so.
  - `cancel` = only the person who sent it, while it waits.
- Who may open a request: the person who sent it, the employee it is about, its approvers, and HR. Anyone else gets `403`; another company's request gets `404`.

### `POST /approvals/{id}/approve`

`{ "comment": "optional, up to 1000" }`. Returns the updated request (same shape as `GET /approvals/{id}`).

### `POST /approvals/{id}/reject`

`{ "comment": "required, up to 1000" }`. A rejection ends the request; the employee is told the reason. Returns the updated request.

### `POST /approvals/{id}/cancel`

Withdraws a waiting request (only the person who sent it). Returns the updated request.

Errors for these three:
- `403 forbidden`: not this person's turn, or the request is already decided;
- `409 conflict`: refused with a reason to show (for example "These details were changed by someone else after the request was sent…");
- `422`: missing reason on reject.

After any decision, refresh `GET /me` for the badge.

## Changing my own details

### `POST /me/details-change`

An employee asks to change their own contact details or an emergency contact. It goes through the company's approval chain, or is applied at once when the company needs no approval.

Details:

```json
{ "kind": "details", "personal_phone": "0300 2222222", "city_name": "Lahore" }
```

Fields allowed with `kind: details` (send only the ones that change; fields not sent stay as they are; send `null` or `""` to clear one):

| Field | Rules |
|---|---|
| `preferred_name` | name characters, up to 80 |
| `marital_status` | `single`, `married`, `divorced`, `widowed`, `separated` (or null) |
| `personal_phone` | phone characters, up to 20 |
| `personal_email` | an email, up to 255 |
| `address_line1`, `address_line2` | up to 255 |
| `city_name` | up to 100 |
| `postcode` | postcode characters, up to 12 |
| `country_code` | 2-letter ISO code (for example `PK`, `GB`) |

Name, date of birth, nationality, work phone and the job are changed by HR only.

Emergency contact. Add a new one:

```json
{ "kind": "emergency_contact", "name": "Bilal Khan", "relationship": "Brother", "phone": "0300 3333333", "alternative_phone": null, "address": null, "is_primary": true }
```

Change an existing one: add `"contact": "<emergency contact id>"` and send **all** its fields.

| Field | Rules |
|---|---|
| `name` | required, name characters, up to 80 |
| `relationship` | required, name characters, up to 40 |
| `phone` | required, phone characters, up to 20 |
| `alternative_phone` | phone characters, up to 20 |
| `address` | up to 255 |
| `is_primary` | true / false |

Response: `201` with the request (same shape as `GET /approvals/{id}`).
- `data.status` is `pending` (waiting for approval) or `approved` (no approval needed: already changed).
- Show "Sent for approval" or "Saved" accordingly.

Errors:
- `409 conflict`: a request is already waiting ("Wait for its answer or withdraw it first"), nothing changed, or the account is not an active employee;
- `422`: a field is not valid.

## Notifications

Every notification goes to the in-app list (the "bell"). Depending on the person's choices it may also go by email and as a phone notification.

### `GET /notifications`

| Query | Rules |
|---|---|
| `unread` | `1` for unread only |
| `per_page` | 1–100 (default 25) |
| `page` | 1+ |

```json
{
  "data": [
    {
      "id": "01j…",
      "kind": "approval_needed",
      "title": "Request to approve",
      "body": "Ayesha Khan: Change of my details: personal phone",
      "link": "https://laravel.ams-hrpayroll.com/requests/01j…",
      "target": { "screen": "request", "id": "01j…" },
      "read": false,
      "created_at": "2026-10-22T09:15:00+00:00",
      "created_ago": "5 minutes ago"
    }
  ],
  "meta": { "page": 1, "per_page": 25, "total": 1, "last_page": 1, "unread": 1 }
}
```

- `kind`:
  - `approval_needed` (a request waits for me);
  - `request_approved`, `request_rejected` (my request was decided);
  - `approval_reminder` (daily, requests still waiting for me).
- **`target` tells the app where to go** (see "Opening a screen" below). `link` is the web address of the same thing.
- Entries are kept 90 days.

### `POST /notifications/{id}/read`

Marks one read. `204`, also when it was already read.

### `POST /notifications/read-all`

`204`.

### `GET /me/notification-preferences`

```json
{ "data": {
  "approval_needed":   { "mail": true, "bell": true, "push": true },
  "request_approved":  { "mail": true, "bell": true, "push": true },
  "request_rejected":  { "mail": true, "bell": true, "push": true },
  "approval_reminder": { "mail": true, "bell": true, "push": false }
} }
```

### `PUT /me/notification-preferences`

```json
{ "preferences": { "approval_needed": { "push": false } } }
```

Send only what changed. Returns the whole grid.
- `bell` cannot be switched off: `422` if you try. Show it as always on.
- Unknown kinds or channels: `422`.

Use the kind's text from the grid keys with your own labels, or these:

| Key | Label |
|---|---|
| `approval_needed` | A request needs my approval |
| `request_approved` | My request was approved |
| `request_rejected` | My request was rejected |
| `approval_reminder` | Daily reminder of requests still waiting for me |

## Push notifications (Firebase Cloud Messaging)

The app uses the company's Firebase project; we send through FCM HTTP v1.

### `POST /push-tokens`

Register the phone after every login, and whenever Firebase gives the app a new token (`onTokenRefresh`).

| Field | Rules |
|---|---|
| `token` | required, the FCM registration token, up to 4096 |
| `platform` | `android` or `ios` |
| `app_version` | optional, for example `2.4.1` or `2.4.1+57` |

`204`. Registering the same token again is fine (it just updates it). If someone else signs in on the same phone, the token moves to them.

### `DELETE /push-tokens`

`{ "token": "…" }`. Stop push to this phone (for example the person turns notifications off in the app). `204`.

Logout removes the phone's push token automatically, so no extra call is needed.

### What a push contains

```json
{
  "notification": { "title": "Request to approve", "body": "Ayesha Khan: Change of my details: personal phone" },
  "data": { "kind": "approval_needed", "screen": "request", "id": "01j…", "link": "https://laravel.ams-hrpayroll.com/requests/01j…" }
}
```

All `data` values are strings. On Android the message has high priority.

## Opening a screen from a notification

The same `screen` / `id` comes in a push's `data` and in a bell entry's `target`:

| `screen` | Open | With |
|---|---|---|
| `request` | The request page | `GET /approvals/{id}` |
| `requests` | The Requests inbox, box "Waiting for me" | `GET /approvals?box=waiting` |

Unknown `screen` values (from a newer server) should open the notifications list.

## Coming next

| Phase | What the app gets |
|---|---|
| 10 | Clock in and out, breaks, location check, face check; support tickets from the app |
| 11 | Leave balances and leave requests (approval through the same inbox) |
| 12 | Payslips |
| 13 | Loans, advances, expenses and money requests |
| 17 | Documents, letters, announcements; expiry reminders in the bell |

## Changes

| Date | Change |
|---|---|
| 2026-10-22 | First edition: authentication, `me`, profile, ID card, employees, requests and approvals, details change, notifications, push. |
