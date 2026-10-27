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

## Schedule

Who works when. The server works out every day from the person's work pattern, rota changes and holidays; the app only shows it. Times are given twice: on the wall clock of the person's work location (`shift.starts`, `shift.ends`, with `timezone`) and as UTC instants (`starts_at`, `ends_at`). An overnight shift (`overnight: true`) ends the day after `date`.

Needs the "View rotas and schedules" permission: everyone has it for themselves (Employee role); managers for their department.

### `GET /me/schedule`

The signed-in person's days.

| Field | Rule |
|---|---|
| `from` | optional, `YYYY-MM-DD`, 2000-01-01 to 2099-12-31; needed with `to` |
| `to` | optional, `YYYY-MM-DD`, not before `from`; at most 62 days after it |

Without `from` and `to`: the next 14 days from the person's today.

```json
{
  "data": [
    {
      "date": "2026-11-02",
      "type": "working",
      "label": "Day shift 09:00–17:00",
      "source": "pattern",
      "timezone": "Asia/Karachi",
      "shift": { "id": "01j…", "name": "Day shift", "code": "DAY", "colour": "sky", "kind": "fixed",
                 "starts": "09:00", "ends": "17:00", "overnight": false, "break_minutes": 60 },
      "starts_at": "2026-11-02T04:00:00Z",
      "ends_at": "2026-11-02T12:00:00Z",
      "planned_minutes": 420,
      "planned": "7:00",
      "holiday": null,
      "holiday_worked": false,
      "pattern": "Standard week"
    },
    { "date": "2026-11-07", "type": "off", "label": "Day off", "shift": null, "starts_at": null, "ends_at": null, "planned_minutes": 0, "…": "…" }
  ],
  "meta": { "employee": "01j…", "from": "2026-11-02", "to": "2026-11-08" }
}
```

`type`:

| Value | Meaning |
|---|---|
| `working` | A shift is planned (`shift` is set). With `holiday` set and `holiday_worked: true`, the rota gave a shift on a holiday. |
| `off` | Day off. |
| `holiday` | A holiday on a day the person would work (`holiday` is set). |
| `flexible` | No fixed plan (Bank Staff): any work counts. |
| `budget` | A working day on an hours budget (for example 4 hours a week): no fixed times. |
| `not_employed` | Before joining or after leaving. |

`source`: `pattern`, `default_pattern` (the company default, no own pattern), `override` (a rota change for that day), `holiday`, `employment`.

`colour` is one of `sky`, `indigo`, `violet`, `emerald`, `teal`, `amber`, `orange`, `rose`, `slate`.

Errors: `422` for a bad date; `409 conflict` for a range longer than 62 days; `404` if the signed-in user has no employee record.

### `GET /employees/{id}/schedule`

The same for one employee the user may see (managers: their department; HR: everyone). Same fields and errors; `403` outside the user's reach, `404` for an unknown id.

### `GET /holidays`

The holidays of a year that apply to the signed-in person.

| Field | Rule |
|---|---|
| `year` | optional, 2000–2099; default the person's current year |

```json
{
  "data": [
    { "id": "01j…", "name": "Iqbal Day", "kind": "public", "starts_on": "2026-11-09", "ends_on": "2026-11-09", "is_paid": true }
  ],
  "meta": { "year": 2026 }
}
```

`kind` is `public` or `company`.

## Attendance

Read-only in this phase, plus correction requests. Clocking in and out from the app comes in Phase 10, through the same rules: **the app never decides which buttons to show**; it shows exactly `state.allowed` from `GET /me/attendance/today`.

### `GET /me/attendance/today`

What the signed-in person can punch now, and today's day so far.

```json
{
  "data": {
    "state": {
      "checked_in": true,
      "on_break": false,
      "since": "09:02",
      "since_at": "2026-11-02T04:02:00Z",
      "date": "2026-11-02",
      "uses_breaks": true,
      "allowed": ["out", "break_start"],
      "refusals": {
        "in": { "code": "already_checked_in", "message": "You are already checked in." },
        "break_end": { "code": "no_open_break", "message": "You are not on a break." }
      }
    },
    "day": { "date": "2026-11-02", "status": "in_progress", "…": "same shape as GET /me/attendance" }
  }
}
```

`allowed` and the keys of `refusals` are `in`, `out`, `break_start`, `break_end`. Show a button for each `allowed` value; when nothing is allowed, show the `message` of `refusals.in`. The rules behind it:

| Button | When |
|---|---|
| `in` | Out, and from the shift's check-in window opening until the shift end. After the shift end, and on days off and holidays, only for people who may earn overtime and have allowance left this month. |
| `break_start` | Checked in, the person punches breaks, and (when the shift has a break time) inside it. |
| `break_end` | On a break. |
| `out` | Checked in (also closes an open break). |

Refusal codes: `not_employed`, `no_shift`, `shift_ended`, `too_early`, `not_checked_in`, `already_checked_in`, `checked_out`, `breaks_not_used`, `outside_break_window`, `no_open_break`, `on_break`, `day_locked`, `mode_not_allowed` (the person may not use the app to punch).

### `GET /me/attendance`

The signed-in person's days, newest first.

| Field | Rule |
|---|---|
| `from` | optional, `YYYY-MM-DD`, 2000-01-01 to 2099-12-31; needed with `to` |
| `to` | optional, `YYYY-MM-DD`, not before `from`; at most 62 days after it (longer: `409`) |

Without `from` and `to`: the last 14 days up to the person's today.

```json
{
  "data": [
    {
      "id": "01j…",
      "date": "2026-11-02",
      "date_label": "Mon 02/11/2026",
      "status": "present",
      "status_label": "Present",
      "status_code": "P",
      "tone": "emerald",
      "day_type": "working",
      "timezone": "Asia/Karachi",
      "shift": { "name": "Day shift", "code": "DAY", "starts": "09:00", "ends": "17:00", "overnight": false },
      "holiday": null,
      "planned_minutes": 420,
      "first_in": "09:00", "first_in_at": "2026-11-02T04:00:00Z",
      "last_out": "17:00", "last_out_at": "2026-11-02T12:00:00Z",
      "worked_minutes": 420, "worked": "7:00",
      "counted_minutes": 420, "counted": "7:00",
      "break_minutes": 60,
      "late_minutes": 0, "early_out_minutes": 0, "short_minutes": 0,
      "overtime_minutes": 0, "overtime": "0:00", "overtime_status": null,
      "flags": [],
      "locked": false,
      "segments": [
        { "kind": "work", "starts": "09:00", "ends": "17:00", "starts_at": "2026-11-02T04:00:00Z", "ends_at": "2026-11-02T12:00:00Z", "paid": false }
      ]
    }
  ],
  "meta": { "employee": "01j…", "from": "2026-10-20", "to": "2026-11-02" }
}
```

| Field | Meaning |
|---|---|
| `status` | `upcoming` (not in yet), `in_progress` (at work now), `present`, `half_day`, `absent`, `incomplete` (no check-out), `off`, `holiday`, `not_employed`, `leave` (Phase 11) |
| `worked_minutes` | Time at work less unpaid breaks |
| `counted_minutes` | Normal time inside the shift (what is paid as a normal day) |
| `overtime_minutes` | Overtime that counts (within the monthly allowance); `overtime_status` is `pending`, `approved` or `rejected` once the day is over |
| `flags` | Any of `late`, `early_out`, `half_day`, `missing_check_out`, `over_break`, `break_outside_window` |
| `locked` | Closed for payroll: cannot be corrected |
| `segments` | The day's timeline; an open segment has `ends` and `ends_at` null |

### `GET /me/attendance/summary`

A month's totals (the same figures payroll uses). `month` optional, `YYYY-MM`; default the current month.

```json
{
  "data": {
    "days": { "present": 18, "half_day": 1, "absent": 1, "incomplete": 0, "off": 8, "holiday": 1, "…": 0 },
    "scheduled_days": 21,
    "planned_minutes": 8820,
    "worked_minutes": 8410,
    "counted_minutes": 8100,
    "late": { "count": 4, "minutes": 95 },
    "early_out": { "count": 1, "minutes": 30 },
    "short_minutes": 360,
    "missing_check_outs": 0,
    "overtime": { "approved_minutes": 240, "pending_minutes": 60 },
    "penalties": [ { "kind": "leave", "label": "Taken from leave", "days": 0.5 } ]
  },
  "meta": { "month": "2026-11" }
}
```

### `GET /employees/{id}/attendance`

A person's days for their manager or HR. Same fields and answer as `GET /me/attendance`. `403` outside the viewer's reach, `404` for another company.

### `POST /me/attendance/corrections`

Ask to correct one of my days. Goes to approval (department manager, then HR, unless the company changed it). Answers `201` with the request, as `GET /approvals/{id}`.

| Field | Rules |
|---|---|
| `date` | required, `YYYY-MM-DD`, not in the future, not a day closed for payroll |
| `add` | list of at most 10 punches to add: `time` (`HH:MM`, 00:00–23:59), `kind` (`in`, `out`, `break_start`, `break_end`), `next_day` (bool, for the morning end of a night shift) |
| `remove` | list of at most 10 punch `id`s of that day to remove |
| `reason` | required, up to 500 |

At least one punch to add or remove. `409` when a correction for that day is already waiting.

## Punching from the app (Phase 10)

The server decides every punch. Before showing the buttons, call `GET /me/attendance/today`: show only the kinds in `state.allowed`, and collect what `requires` asks for.

`GET /me/attendance/today` now also has:

```json
"requires": {
  "position": true,
  "photo": true,
  "face": "match",
  "face_saved": false,
  "consent_text": "Your photo will be saved as your face for attendance. …"
}
```

| Field | Meaning |
|---|---|
| `position` | Send `latitude`, `longitude`, `accuracy_m` (and `is_mocked`) with the punch. The company requires the geo-fence. |
| `photo` | Take a photo with each punch. |
| `face` | `off`, `photo` (photo only) or `match` (compare with the saved face on the phone). |
| `face_saved` | With `match`: `false` means this punch saves the face. Show `consent_text` and send `face_consent: true` only after the person agrees. `true` means: download `GET /me/face`, compare on the phone, and send the result. |

### `POST /me/attendance/punches`

JSON, or `multipart/form-data` when a photo is sent. Rate limit 20 a minute.

| Field | Rules |
|---|---|
| `kind` | required: `in`, `out`, `break_start`, `break_end` |
| `idempotency_key` | required, 8–64 characters `A-Z a-z 0-9 _ -`. Make a new UUID per button press and reuse it when retrying the same press: a retried request never makes a second punch. |
| `latitude`, `longitude` | together; −90…90 and −180…180, at most 6 decimals |
| `accuracy_m` | whole metres, 0–10000. Worse than 150 m is refused when the position is required. |
| `is_mocked` | bool: Android's mock-location flag. A mocked position is refused. |
| `break_type` | optional, a break type id (with `break_start`) |
| `photo` | image (jpg, png, webp), at most 2 MB, 160–4096 px each side |
| `face_match` | `matched` or `not_matched`: the phone's comparison with the saved face |
| `face_score` | 0–1, at most 4 decimals (kept for HR) |
| `face_consent` | bool, only for the punch that saves the face |

Answers `201`:

```json
{ "data": { "punch": { "id": "01j…", "time": "09:02", "role": "check_in", "source": "mobile_app", "…": "…" }, "state": { "…": "as today" }, "requires": { "…": "…" }, "day": { "…": "…" } } }
```

`409` with `error.message` when the punch is not allowed now. The reasons the app may meet besides Phase 9's: outside the geo-fence, no position, mocked position, position not accurate enough, not a way this person may punch, photo needed, consent needed, face did not match. `422` for bad fields.

### `GET /me/face`

The saved face as an image, for the comparison on the phone (`Cache-Control: no-store`; keep it only in memory). `404` when none is saved.

### `PUT /me/kiosk-pin`

The person sets their own kiosk PIN (for a forgotten card at the kiosk). `pin` 4–6 digits, `pin_confirmation` the same; not all one digit and not a straight run (1234, 4321). Answers `{"data": {"kiosk_pin": true}}`.

## Kiosk mode (Phase 10)

The same app on a tablet. The kiosk acts on **its own secret**, never on a user's token.

### Setting up: `POST /kiosks`

Called with a normal user token (someone with "Set up and remove kiosk tablets" signs in on the tablet). Body: `name` (2–60), `location` (work location id), `replace` (bool: give an existing kiosk of that name a new secret, for a reset tablet). Answers `201`:

```json
{ "data": { "kiosk": { "id": "01j…", "name": "Front desk", "location": { "id": "01j…", "name": "Head office", "timezone": "Asia/Karachi" }, "pin_allowed": true }, "token": "kiosk_…" } }
```

Store `token` securely on the tablet, then **log the user out** (`POST /auth/logout`). Every kiosk call sends `Authorization: Bearer <kiosk token>`. `401` on any kiosk call means the kiosk was stopped on the web: go back to set-up. Rate limit 60 a minute per kiosk.

### `GET /kiosk`

The kiosk's name, location and whether the PIN fallback is allowed (`pin_allowed`).

### `POST /kiosk/identify`

`badge` (the scanned QR value), or `employee_number` + `pin`. Answers:

```json
{ "data": { "person": { "id": "01j…", "name": "Ayesha Khan", "employee_number": "EMP-0001" }, "ticket": "eyJ…", "expires_in": 120, "state": { "allowed": ["in"], "…": "…" }, "requires": { "photo": true, "face": "match", "face_saved": true } } }
```

`409`: card not valid here (another company, a replaced card, a leaver), wrong number or PIN, too many wrong tries (locked 15 minutes), PIN not allowed by the company.

### `GET /kiosk/face?ticket=…`

The identified person's saved face, for the comparison on the tablet. `404` when none.

### `POST /kiosk/punches`

Live: `ticket` (from identify, valid 2 minutes), `kind`, `idempotency_key`, and the face fields as in the app (`photo`, `face_match`, `face_score`, `face_consent`). No position: the kiosk's location is the place.

Offline (queued while the tablet had no connection): no `ticket`; send `badge` (or `employee_number` + `pin`) and `punched_at` (ISO 8601 with offset, at most 24 hours old) with the same fields. An offline punch is stored and judged like a device punch: the answer is `201` even when the rules then exclude it, so send the queue in order and drop each item on `201`.

## Changes for Phase 10

- `GET /me/attendance/today` has `requires`.
- New: `POST /me/attendance/punches`, `GET /me/face`, `PUT /me/kiosk-pin`, `POST /kiosks`, and the kiosk endpoints under `/kiosk`.
- Notification kind `device_silent` (screen `devices`) is web-only for now; the app can ignore it.

## Support tickets (Phase 10)

Questions to us (the AMS team), the same tickets as the web's Support page. Who sees what follows the role: "Raise support tickets" to open and reply, "See support tickets" for the list (own or the whole company's). Internal notes of our team are never sent.

| Call | What |
|---|---|
| `GET /support/tickets?finished=1&per_page=` | The list, newest change first; `finished=1` includes closed ones. Each: `id`, `number`, `subject`, `status`, `status_tone`, `raised_by`, `updated_at`. `meta`: `current_page`, `last_page`, `total`. |
| `POST /support/tickets` | Open one (JSON, or multipart with files). Answers `201` with the thread. |
| `GET /support/tickets/{id}` | The thread: `id`, `number`, `subject`, `status`, `status_value` (`open`, `waiting_on_customer`, `resolved`, `closed`), `priority`, `category`, `opened_at`, `messages` (`from_us`, `author`, `body`, `at`, `attachments` with `id`, `name`, `size_kb`). |
| `POST /support/tickets/{id}/replies` | `body`, `attachments[]`. `201` with the thread. |
| `POST /support/tickets/{id}/close`, `/reopen` | `200` with the thread. Reopen only a `resolved` ticket; otherwise `403`. |
| `GET /support/tickets/{id}/files/{file}` | Download a file. |

| Field | Rules |
|---|---|
| `subject` | required, up to 150 |
| `category` | `technical`, `billing`, `account`, `feature_request`, `other` |
| `priority` | `low`, `normal`, `high`, `urgent` |
| `body` | required, 2 to 10000 |
| `page_url` | optional, an http(s) address, up to 500 |
| `attachments[]` | at most 5 files (jpg, png, gif, webp, pdf, txt, csv, xlsx, docx), at most 5 MB each |

`403` without the permission, `404` for a ticket outside the user's reach or another company's.

## Leave (Phase 11)

Amounts are numbers in the type's unit: **days with decimals** (`1.5`) for `unit: day`, **minutes** for `unit: hour`. Every balance also has a `text` block ready to show ("1.5 days", "7 h 30 min").

Leave decisions go through the approvals endpoints (type `leave`). A leave request's summary shows the cost, the balance before and after, and who else in the department is off.

### `GET /leave/types`

The types the person may use: `id`, `name`, `code`, `colour`, `category` (`annual`, `sick`, `unpaid`, `compensatory`, `other`), `is_paid`, `unit` (`day` / `hour`), `allow_half_days`, `min_notice_days`, `max_days_in_row`, `attachment_after_days`, `allow_past_days`, `has_balance` (false: unpaid leave, no limit).

### `GET /me/leave/balances?on=YYYY-MM-DD`

Balances of the leave year containing `on` (default today), one per type. `meta.year` = `{starts_on, ends_on}`.

```json
{"data": [{"type": {"id": "01j…", "name": "Annual leave", "code": "AL", "unit": "day", "has_balance": true, …},
  "entitlement": 24, "earned": 19.5, "adjusted": 0, "carried": 5, "carried_left": 3, "expired": 0,
  "taken": 6, "booked": 2, "pending": 1, "holidays": 0, "unpaid": 0, "available": 20, "total": 29,
  "text": {"available": "20 days", "earned": "19.5 days", …}}],
 "meta": {"year": {"starts_on": "2026-01-01", "ends_on": "2026-12-31"}}}
```

`available` is null for unpaid leave. `earned` grows through the year; whether only that much can be booked is the company's choice (the server checks).

### `GET /me/leave/requests`

The person's requests, newest first, 25 a page (`meta.page`, `last_page`, `total`). Each: `id`, `type`, `starts_on`, `ends_on`, `start_part` / `end_part` (`full`, `first_half`, `second_half`), `starts_at` and `minutes` (hour types), `amount`, `amount_text`, `summary`, `reason`, `has_attachment`, `status` (`pending`, `approved`, `rejected`, `cancelled`), `status_label`, `source` (`self` / `hr`), `cancel_reason`, `days` (`date`, `portion`, `kind` = `leave` / `sandwich`, `amount`, `is_paid`).

### `POST /me/leave/requests/preview`

The same fields as sending a request. Answers `200` with `ok`, `message` (the refusal it would get), `fields` (input errors), `days`, `amount`, `amount_text`, `available_text`, `after_text`. Call it as the form changes; nothing is stored.

### `POST /me/leave/requests`

| Field | Rule |
|---|---|
| `leave_type` | required, a type id from `/leave/types` |
| `starts_on`, `ends_on` | required, `YYYY-MM-DD`, 2000–2099, end not before start, one leave year, at most 92 days (hour types: `ends_on` = `starts_on`) |
| `start_part`, `end_part` | optional, `full` (default), `first_half`, `second_half`; one day: `start_part` only; several days: start `full`/`second_half`, end `full`/`first_half` |
| `starts_at`, `duration` | hour types: `HH:MM` and `H:MM`, inside that day's shift |
| `reason` | optional, up to 500 |
| `attachment` | optional file (pdf, jpg, png, up to 5 MB); send multipart. Required above the type's `attachment_after_days` |

`201` with the request. `409 conflict` with the reason for a rule refusal (overlap, a worked day, notice, balance, probation, past days…), `422` for bad input.

### `POST /me/leave/requests/{id}/cancel`

`reason` required (up to 500). Waiting: withdraws it. Approved: only before its first day; after that ask the manager. Answers the request.

### `GET /leave/whos-off?from=&to=`

Approved leave of the people the user may see (only themself for an employee), default today, at most 92 days: `date`, `employee` (`id`, `name`, `department`), `type`, `portion`.

### `GET /employees/{id}/leave`

For managers and HR in reach: `balances` and `requests` as above. `403` outside reach, `404` for another company's.

Notifications: `leave_recorded` (HR entered leave for you), `leave_cancelled`, `leave_expiring`, all with screen `leave`.

## Payroll (Phase 12)

The person's own pay. Only payslips of **finalised** runs reach the app; a draft never does, and anyone else's payslip answers `404`. All need `pay.view` for themselves (the Employee role has it). Money is given twice: `amount` in minor units (paisa, pence) and `text` ready to show, for example `"Rs 149,180.00"`. Days are decimals (`2.5`).

### `GET /me/payslips`

Newest first, at most 36.

```json
{ "data": [ { "id": "01jb…", "period": "July 2025", "pays_on": "2025-07-31", "employer": "Acme Textiles (Pvt) Ltd",
  "currency": "PKR", "net": 14918000, "net_text": "Rs 149,180.00", "gross_text": "Rs 155,000.00" } ] }
```

### `GET /me/payslips/{id}`

```json
{ "data": {
  "id": "01jb…",
  "period": { "label": "July 2025", "starts_on": "2025-07-01", "ends_on": "2025-07-31", "pays_on": "2025-07-31", "attendance_from": "2025-07-01", "attendance_to": "2025-07-31" },
  "employer": "Acme Textiles (Pvt) Ltd", "run_status": "finalised", "status": "included",
  "employee": { "id": "01ja…", "name": "Bilal Khan", "number": "EMP-0002", "department": "Sales", "designation": "Officer", "location": "Head office" },
  "currency": "PKR", "payment_method": "Bank transfer",
  "days": { "period": 31, "paid": 31, "unpaid": 0, "worked_minutes": 9660, "overtime_minutes": 0 },
  "earnings": [ { "code": "BASIC", "name": "Basic salary", "amount": 10000000, "amount_text": "Rs 100,000.00", "explanation": "Full period" } ],
  "deductions": [ { "code": "TAX", "name": "Income tax", "amount": 545000, "amount_text": "Rs 5,450.00", "explanation": "Yearly tax … over 12 period(s)" } ],
  "employer_contributions": [ { "code": "SSER", "name": "EOBI (employer)", "amount": 185000, "amount_text": "Rs 1,850.00", "explanation": "5% of Rs 37,000.00" } ],
  "totals": { "gross": { "amount": 15500000, "text": "Rs 155,000.00" }, "deductions": { "amount": 582000, "text": "…" }, "net": { "amount": 14918000, "text": "…" },
              "employer_cost": { "amount": 15685000, "text": "…" }, "taxable": { "amount": 14500000, "text": "…" }, "tax": { "amount": 545000, "text": "…" } },
  "year_to_date": { "gross": { "amount": 15500000, "text": "…" }, "taxable": { "amount": 14500000, "text": "…" }, "tax": { "amount": 545000, "text": "…" } },
  "problem": null, "stale": false
} }
```

Show `earnings` and `deductions` as two lists with their totals, then `net`. `explanation` is one line of how a line was worked out ("2.5 unpaid days × Rs 6,739.13 a day"). `employer_contributions` are paid by the employer, not taken from pay. Errors: `404`.

### `GET /me/payslips/{id}/pdf`

The same payslip as a PDF (`application/pdf`), for download or sharing. Errors: `404`.

### `GET /me/salary`

The salary in force today, or `"data": null`.

```json
{ "data": { "id": "01jc…", "effective_from": "2025-01-01", "basis": "period", "basis_label": "Per pay period", "schedule": "Monthly",
  "payment_method": "Bank transfer", "currency": "PKR", "social_security_enrolled": true, "reason": null,
  "lines": [ { "code": "BASIC", "name": "Basic salary", "kind": "earning", "amount": 10000000, "amount_text": "Rs 100,000.00", "percent": null },
             { "code": "HRA", "name": "House rent allowance", "kind": "earning", "amount": null, "amount_text": null, "percent": "45" } ] } }
```

A percentage line (`percent`) is a share of other components; its amount is on each payslip.

Notification: `payslip_ready` (a run with you in it was finalised), screen `payslips`.

## Loans, advances and expenses (Phase 13)

The person's own money requests. All need `money.view` for themselves (the Employee role has it); someone else's request answers `404`. Approvals go through the approval endpoints (request type `money_request`). Amounts are typed in major units (`"30000"`, `"1250.50"`, at most the currency's decimals, never negative) and returned twice: minor units (`amount`) and text (`amount_text`). The currency is the person's employer's. Loans are interest-free.

Kinds: `loan` (paid back in instalments from pay), `advance` (part of the salary early, usually 1 instalment), `payment` (not paid back, for example a bonus asked for), `expense` (a refund of money spent, with dated lines and receipts).

### `GET /me/money-request-types`

The types the person may ask for, and the expense categories.

```json
{ "data": {
  "types": [ { "id": "01jd…", "name": "Staff loan", "kind": "loan", "kind_label": "Loan", "description": null, "repayable": true, "has_lines": false,
               "max_instalments": 24, "max_per_request": "Rs 200,000.00", "max_outstanding": null, "receipt_required": false } ],
  "categories": [ { "id": "01je…", "name": "Travel" } ] } }
```

`max_per_request` / `max_outstanding` are the company's limits (null: no limit). Show `instalments` only when `repayable`, and lines instead of an amount when `has_lines`.

### `POST /me/money-requests`

JSON, or `multipart/form-data` when sending receipts.

| Field | Rule |
|---|---|
| `type` | required, a type id from above |
| `amount` | required unless the type has lines; > 0, at most the currency's decimals |
| `instalments` | required for `loan` / `advance` (1–120, at most the type's `max_instalments`); not allowed for others |
| `reason` | optional, up to 500 characters |
| `lines[]` | expense claims only, 1–30: `category` (id), `spent_on` (`YYYY-MM-DD`, not in the future), `amount`, `note` (up to 255) |
| `receipts[]` | expense claims: one file per line, same index as `lines[]`; PDF, JPG or PNG up to 5 MB; required on every line when the type says `receipt_required` |

Answers `201` with the request (as `GET /me/money-requests/{id}`). Errors: `422` (fields), `409` (a rule: limits, HR-only type, receipt missing; the message says which).

### `GET /me/money-requests`

Newest first, 25 a page (`meta.page`, `meta.last_page`, `meta.total`).

```json
{ "data": [ { "id": "01jf…", "employee": { "id": "01ja…", "name": "Bilal Khan" },
  "type": { "id": "01jd…", "name": "Staff loan", "kind": "loan", "kind_label": "Loan" },
  "amount": 3000000, "currency": "PKR", "amount_text": "Rs 30,000.00",
  "status": "repaying", "status_label": "Being paid back", "tone": "brand", "source": "self", "source_label": "Asked by the person",
  "reason": "Family needs", "requested_at": "2025-08-05T07:00:00+00:00", "repayable": true,
  "instalments": 3, "instalment_amount": 1000000, "instalment_text": "Rs 10,000.00", "balance": 2000000, "balance_text": "Rs 20,000.00",
  "payout": { "method": "outside", "method_label": "Outside payroll (cash or transfer)", "period": null, "paid_out_on": "2025-08-04",
              "reference": "TRX-1", "first_period": "August 2025" },
  "closed_on": null, "cancel_reason": null } ] }
```

Statuses: `pending` (waiting for approval), `approved` (to be paid), `repaying`, `closed`, `rejected`, `cancelled`. `balance` is what is still owed (null for kinds that are not paid back).

### `GET /me/money-requests/{id}`

The request as above plus `lines` (`position`, `category`, `spent_on`, `amount`, `amount_text`, `note`, `has_receipt`), `schedule` (each pay period: `period`, `amount_text`, `state` = `recovered` / `missed` / `skipped` / `planned`, `state_label`, `owed_after_text`) and `recoveries` (`amount_text`, `source_label`, `period`, `recorded_on`, `note`). Errors: `404`.

### `POST /me/money-requests/{id}/cancel`

Withdraws a request while it is `pending`. Body: `reason` (optional, up to 500). Answers the request. Errors: `404`, `409` (no longer waiting).

Notifications: `money_recorded` (HR entered one for you, already approved) and `money_paid_out` (it is being paid), both with screen `money_request` and `id`. Decisions arrive as the usual `request_approved` / `request_rejected`.

## Opening a screen from a notification

The same `screen` / `id` comes in a push's `data` and in a bell entry's `target`:

| `screen` | Open | With |
|---|---|---|
| `request` | The request page | `GET /approvals/{id}` |
| `requests` | The Requests inbox, box "Waiting for me" | `GET /approvals?box=waiting` |
| `schedule` | My schedule (sent when my schedule changes in the next two weeks; no `id`) | `GET /me/schedule` |
| `attendance` | My attendance on `date` (sent when a day has no check-out; no `id`) | `GET /me/attendance?from={date}&to={date}` |
| `leave` | My leave; with `id`, that request (from `GET /me/leave/requests`) | `GET /me/leave/balances` |
| `payslips` | My payslips (sent when a payslip is ready; no `id`) | `GET /me/payslips` |
| `money_request` | That loan, advance or expense | `GET /me/money-requests/{id}` |

Unknown `screen` values (from a newer server) should open the notifications list.

## Coming next

| Phase | What the app gets |
|---|---|
| 17 | Documents, letters, announcements; expiry reminders in the bell |

## Changes

| Date | Change |
|---|---|
| 2026-10-26 | Loans and expenses (Phase 13): `GET /me/money-request-types`, `GET /me/money-requests`, `POST /me/money-requests` (multipart with receipts), `GET /me/money-requests/{id}`, `POST /me/money-requests/{id}/cancel`; request type `money_request` in the inbox; notification kinds `money_recorded`, `money_paid_out` with screen `money_request`; the menu has `money`. |
| 2026-10-26 | Payroll (Phase 12): `GET /me/payslips`, `GET /me/payslips/{id}`, `GET /me/payslips/{id}/pdf`, `GET /me/salary`; notification kind `payslip_ready` with screen `payslips`; the menu has `payroll` and `payslips`. |
| 2026-10-24 | Leave (Phase 11): `GET /leave/types`, `GET /me/leave/balances`, `GET /me/leave/requests`, `POST /me/leave/requests/preview`, `POST /me/leave/requests`, `POST /me/leave/requests/{id}/cancel`, `GET /leave/whos-off`, `GET /employees/{id}/leave`; request type `leave` in the inbox; notification kinds `leave_recorded`, `leave_cancelled`, `leave_expiring` with screen `leave`; skipped step reason `approver_away`. |
| 2026-10-23 | Attendance channels (Phase 10): app punch `POST /me/attendance/punches` with position and face fields, `requires` on `GET /me/attendance/today`, `GET /me/face`, `PUT /me/kiosk-pin`; kiosk mode `POST /kiosks` and `/kiosk` (`GET`, `identify`, `face`, `punches`, offline punches); support tickets `/support/tickets`. |
| 2026-10-23 | Attendance (Phase 9): `GET /me/attendance/today` (punch buttons), `GET /me/attendance`, `GET /me/attendance/summary`, `GET /employees/{id}/attendance`, `POST /me/attendance/corrections`; request types `overtime` and `attendance_correction` in the inbox; notification kind `missing_check_out` with screen `attendance`. |
| 2026-10-22 | Schedule (Phase 8): `GET /me/schedule`, `GET /employees/{id}/schedule`, `GET /holidays`; notification kind `schedule_changed` with screen `schedule`. |
| 2026-10-22 | First edition: authentication, `me`, profile, ID card, employees, requests and approvals, details change, notifications, push. |



