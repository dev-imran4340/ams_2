# AMS 2 — Complete Backend REST API & Integration Specifications (BRD / Enterprise Architecture Spec)

> **Document Version:** 2.1.0 (Synchronized with Phase 7 Live Engine & Phase 10–17 Roadmap)  
> **Application:** AMS 2 Mobile (Attendance Management System & Enterprise HR Suite)  
> **Target Audience:** Backend Developers, API Engineers, DevOps, QA Engineers, Flutter Mobile Engineers  
> **Source Ground Truth:** [`doc/api.md`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/doc/api.md) (Official AMS Mobile API v1 Specification)  
> **Base URL (Staging):** `https://laravel.ams-hrpayroll.com/api/v1`  
> **Standard Request Headers:**  
> - `Authorization: Bearer <token>` (Required on all requests except `/auth/login`, `/auth/two-factor`, and `/auth/forgot-password`)  
> - `Accept: application/json` (Mandatory on every request)  
> - `Content-Type: application/json` (or `multipart/form-data` where file uploads/photos are specified)  
> - `X-Device-Id: <UNIQUE_DEVICE_UUID>`  
> - `X-App-Version: 2.0.0`  
> - `X-Client-Platform: android | ios`  

---

# ⚠️ STRICT DEVELOPMENT INVARIANTS & ENFORCED ARCHITECTURAL POLICIES (سخت ترین اصول)

1. **The Golden Rule — The Server Decides Access:**
   - One mobile app for everyone: company users, HR managers, and employees. What each person sees comes **strictly from the server, never from hardcoded client-side roles**.
   - **Dynamic Menu Construction:** The app navigation drawer and tabs **MUST** be constructed dynamically from `GET /me` → `data.menu`. Show only those items, strictly in the returned order. Never hide or add menu items based on static client-side roles.
   - **Permission-Driven UI Controls:** Use `GET /me` → `data.permissions` strictly to show or hide action buttons inside a screen. Scopes include:
     * `own`: The employee themselves.
     * `department`: The departments they supervise.
     * `location`: Their assigned work locations.
     * `company`: Company-wide administrative access.
     * A missing permission key means **not allowed**.
   - **Server-Filtered Lists:** All listing queries (team members, colleagues, attendance logs) come pre-filtered by the server according to the viewer's security scopes.

2. **Error Handling Invariant — Code Over Message:**
   - The Flutter app **MUST** decide what action to take based on `error.code`, **NEVER by inspecting the human-readable `message` string**.
   - `message` is guaranteed safe to show to the end-user via `CustomSnackbar` or `CustomStateView`.
   - When `error.code == "validation_failed"`, the `error.fields` object contains input-keyed validation error arrays; each error string **MUST** be mapped directly below its respective form field.

3. **Identifier Invariant — 26-Character Opaque ULIDs:**
   - Every `id` in the system is an opaque 26-character string (e.g. `01jb2x9k4m7q8r3t5v6w8y0z1a`).
   - Never cast an ID to an integer, never guess an ID, and never construct one locally.

4. **Token Lifecycle & 401 Session Purge:**
   - Tokens are valid for **90 days**.
   - A logout, password change, or account disabling immediately invalidates all active tokens on the server.
   - Upon receiving `401 unauthenticated` or `403 account_unavailable`, the app **MUST** immediately execute `AppPreferences.clearAuth()` and route the user to `Routes.LOGIN`.

5. **Rate Limiting Resilience (`429 too_many_requests`):**
   - Login & Two-Factor: 5 requests / minute.
   - Forgot Password: 3 requests / minute.
   - General API Endpoints: 120 requests / minute per user.
   - When a `429` is encountered, the app **MUST** parse the `Retry-After` header and show a countdown timer to the user, disabling retry buttons until the window elapses.

6. **Input Whitelisting & Client-Side Sanitization:**
   - Even though the server rigorously validates every field, the mobile app **MUST** limit input characters in text fields:
     * **Phone numbers:** Digits, spaces, `+`, `(`, `)`, `-`; maximum 20 characters.
     * **Names:** Unicode letters (any language), spaces, `'`, `.`, `-`; maximum 80 characters.
     * **Postcodes:** Letters, digits, space, `-`; maximum 12 characters.
     * **Comments & Justifications:** Plain text; maximum 1000 characters.

7. **Universal Requests & Approvals Inbox Invariant:**
   - All employee requests (contact details changes, and future leave, attendance corrections, overtime, loans, and money requests) flow through a **single unified inbox** (`/approvals`).
   - Requests are segregated into 4 standard boxes:
     * `waiting`: Waiting for **my** decision.
     * `pending`: Everything waiting that I may decide for HR (empty for users without HR rights).
     * `mine`: Requests initiated by me.
     * `decided`: Requests I have already approved or rejected.
   - Visual status indicators **MUST** map to server `status_tone`: `amber` (warning/pending), `emerald` (approved), `rose` (rejected), `slate` (cancelled/neutral).

8. **Strict Layer Flow Policy:**
   - `View -> Controller -> Repository -> ApiClient`.
   - Controllers **NEVER** make direct HTTP calls or touch local storage.
   - Repositories call `ApiClient.request()`, wrap responses in strongly-typed models, and pass mandatory origin tracer tags (`tag: 'FeatureRepo / Screen -> methodName()'`).

9. **Floating Card UI Invariant:**
   - Every primary card container **MUST** feature strictly `12.w` horizontal inside padding, `15.r` border radius, and signature `3.w` Modern Teal bottom accent border (`AppColors.secondary`), wrapped via `CustomCard`.

10. **Zero Memory Leaks Policy:**
    - Every controller allocating `TextEditingController`, `FocusNode`, `ScrollController`, `AnimationController`, or `StreamSubscription` **MUST** dispose them in `onClose()`.

---

# Table of Contents
1. [Global Response & Error Contract](#1-global-response--error-contract)
2. [Server-Driven Menu, Permissions & Scopes](#2-server-driven-menu-permissions--scopes)
3. [Module 1: Authentication & Two-Factor (`/auth`)](#module-1-authentication--two-factor)
4. [Module 2: Identity & Session Hydration (`/me`)](#module-2-identity--session-hydration)
5. [Module 3: My Profile & Digital ID Card (`/me/profile`, `/me/card`)](#module-3-my-profile--digital-id-card)
6. [Module 4: Employee Self-Service Details Change (`/me/details-change`)](#module-4-employee-self-service-details-change)
7. [Module 5: Team & Colleague Directory (`/employees`)](#module-5-team--colleague-directory)
8. [Module 6: Unified Requests & Approvals Inbox (`/approvals`)](#module-6-unified-requests--approvals-inbox)
9. [Module 7: In-App & Push Notifications (`/notifications`, `/push-tokens`)](#module-7-in-app--push-notifications)
10. [Roadmap Modules (Phases 10–17 Integration)](#roadmap-modules-phases-1017-integration)
    - [10.1 Attendance Actions, Geofencing & Breaks (Phase 10)](#101-attendance-actions-geofencing--breaks-phase-10)
    - [10.2 Facial Biometrics & Encrypted QR Engine (Phase 10)](#102-facial-biometrics--encrypted-qr-engine-phase-10)
    - [10.3 Leave Quotas & Leave Applications (Phase 11)](#103-leave-quotas--leave-applications-phase-11)
    - [10.4 Digital Payslips & Compensation (Phase 12)](#104-digital-payslips--compensation-phase-12)
    - [10.5 Loans, Advances & Money Requests (Phase 13)](#105-loans-advances--money-requests-phase-13)
    - [10.6 Enterprise Kiosk Terminal & Visitor Management](#106-enterprise-kiosk-terminal--visitor-management)
11. [Master Endpoint Index Table](#master-endpoint-index-table)
12. [Flutter Client Integration Blueprint & QA Checklist](#flutter-client-integration-blueprint--qa-checklist)

---

# 1. Global Response & Error Contract

All backend responses from `https://laravel.ams-hrpayroll.com/api/v1` conform to the official specification in [`doc/api.md`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/doc/api.md).

### 1.1 Single Object Success Response (`200 OK` / `201 Created`)
```json
{
  "data": {
    "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
    "name": "Ayesha Khan"
  }
}
```

### 1.2 Paginated List Success Response (`200 OK`)
```json
{
  "data": [
    {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "employee_number": "EMP-0001",
      "name": "Ayesha Khan"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 42,
    "last_page": 2
  }
}
```

### 1.3 Empty Success Response (`204 No Content`)
- HTTP Status `204` returns **no body** (e.g. `POST /auth/logout`, `POST /notifications/{id}/read`, `DELETE /push-tokens`).

### 1.4 Unified Error Envelope (`4xx` / `5xx`)
```json
{
  "error": {
    "code": "validation_failed",
    "message": "The given data was invalid.",
    "fields": {
      "personal_phone": [
        "The personal phone field format is invalid."
      ]
    }
  }
}
```

### 1.5 Standard HTTP & Error Code Mapping

| HTTP Code | Error `code` | Meaning & Mobile Client Action |
|:---:|:---|:---|
| `400` | `bad_request` | The request cannot be handled. Display `message`. |
| `401` | `unauthenticated` | No token or token expired (90 days). Purge storage and navigate to `Routes.LOGIN`. |
| `401` | `invalid_credentials` | Wrong login or password (single security-hardened message for both). |
| `401` | `invalid_two_factor_code` | Wrong or reused 2FA code, or challenge expired (5 min lifetime). |
| `403` | `forbidden` | Signed in, but not allowed to perform this action. |
| `403` | `account_unavailable` | Account disabled, company suspended/closed, or email not verified. Show `message`. |
| `404` | `not_found` | Resource missing or belongs to another company tenant. |
| `405` | `method_not_allowed` | Wrong HTTP verb used. |
| `409` | `conflict` | Refused by business rule (e.g. "a request is already waiting"). Show `message`. |
| `422` | `validation_failed` | Form input invalid. Read `fields` map and highlight form errors. |
| `429` | `too_many_requests` | Rate limit hit. Read `Retry-After` header and display countdown. |
| `500` | `server_error` | Internal server exception. Show safe retry banner via `CustomStateView.error()`. |

---

# 2. Server-Driven Menu, Permissions & Scopes

The AMS mobile app is designed around a zero-hardcoding philosophy. Everything shown in the primary interface is determined dynamically by `GET /me`.

### 2.1 The Dynamic Menu Schema
```json
"menu": [
  { "key": "home", "label": "Home", "icon": "home", "module": "core" },
  { "key": "requests", "label": "Requests", "icon": "inbox-stack", "module": "core" },
  { "key": "employees", "label": "Employees", "icon": "identification", "module": "core" },
  { "key": "organisation", "label": "Organisation", "icon": "building-office", "module": "core" },
  { "key": "support", "label": "Support", "icon": "lifebuoy", "module": "core" }
]
```
- **Key Mapping:**
  * `home` → `Routes.DASHBOARD`
  * `requests` → `Routes.REGULARIZATION` (Universal `/approvals` inbox)
  * `employees` → `Routes.INDEX` (Colleagues & Team directory)
  * `organisation` → `Routes.ORG_HUB` / Web Admin notice
  * `support` → In-app helpdesk / ticket creation
- **Icons:** The `icon` string corresponds to standard Heroicons identifiers.

### 2.2 Permissions with Hierarchical Scopes
```json
"permissions": {
  "employees.view": ["own", "department"],
  "employees.sensitive.view": ["own"],
  "pay.view": ["own"],
  "support.view": ["own"],
  "support.raise": null
}
```
- If a permission maps to `null`, it is a binary permission without scopes (e.g. `support.raise: null` allows submitting a ticket).
- If a permission maps to a string array (e.g. `["own", "department"]`), it defines the extent of visibility:
  * `own`: Self record only.
  * `department`: Subordinates within managed departments.
  * `location`: Staff assigned to the same physical workstation/branch.
  * `company`: Universal organization-wide visibility.

### 2.3 Badges Map
```json
"badges": {
  "requests": 2
}
```
- Keys correspond to `menu[].key`.
- Only non-zero badge counts appear. If count is 0, key is omitted or `{}` is returned.
- Mobile app binds these directly to bottom navigation bar or drawer badges.

---

# Module 1: Authentication & Two-Factor
**Screen References:**
- Login: [`lib/app/screens/auth/view/login_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/auth/view/login_view.dart)
- Forgot Password: [`lib/app/screens/auth/view/forgot_password_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/auth/view/forgot_password_view.dart)

---

### API 1.1: User Login (Credentials)
- **Endpoint:** `POST /api/v1/auth/login`
- **Purpose:** Dual-mode authentication supporting:
  1. Corporate Email: `login` = email address.
  2. Employee Number: `login` = employee ID + `company_code` (6-character company identifier).
- **Auth Required:** No
- **Rate Limit:** 5 requests / minute
- **Content-Type:** `application/json`

**Request Body (By Email):**
```json
{
  "login": "ayesha@acme.pk",
  "password": "SecurePassword123!",
  "device_name": "Pixel 8 – Android 15"
}
```

**Request Body (By Employee Number):**
```json
{
  "login": "EMP-0001",
  "company_code": "K7MP2Q",
  "password": "SecurePassword123!",
  "device_name": "iPhone 15 Pro – iOS 18"
}
```

**Success Response (Two-Factor Disabled — `200 OK`):**
```json
{
  "data": {
    "two_factor_required": false,
    "token": "01jb2x9k4m7q8r3t5v6w8y0z1a_jwt_token_sample..."
  }
}
```

**Success Response (Two-Factor Enabled — `200 OK`):**
```json
{
  "data": {
    "two_factor_required": true,
    "challenge": "a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0"
  }
}
```

**Error Responses:**
- `401 invalid_credentials`: Wrong login or password.
- `403 account_unavailable`: Account disabled, company suspended, or email unverified.
- `422 validation_failed`: Missing required parameters.
- `429 too_many_requests`: Exceeded 5 attempts/minute.

---

### API 1.2: Two-Factor Authentication Challenge
- **Endpoint:** `POST /api/v1/auth/two-factor`
- **Purpose:** Completes login when `two_factor_required: true`. Accepts 6-digit TOTP code or single-use recovery code.
- **Auth Required:** No
- **Rate Limit:** 5 requests / minute

**Request Body (6-Digit Authenticator Code):**
```json
{
  "challenge": "a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0",
  "code": "481920"
}
```

**Request Body (Recovery Code):**
```json
{
  "challenge": "a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0",
  "recovery_code": "A89F-22B1"
}
```

**Success Response (`200 OK`):**
```json
{
  "data": {
    "token": "01jb2x9k4m7q8r3t5v6w8y0z1a_jwt_token_sample..."
  }
}
```

**Error Response:**
- `401 invalid_two_factor_code`: Code incorrect or challenge expired (5-minute window).

---

### API 1.3: Forgot Password (Probing-Proof)
- **Endpoint:** `POST /api/v1/auth/forgot-password`
- **Purpose:** Dispatches password reset link to email. The reply is strictly identical whether the address exists or not, preventing account enumeration probing.
- **Auth Required:** No
- **Rate Limit:** 3 requests / minute

**Request Body:**
```json
{
  "email": "ayesha@acme.pk"
}
```

**Success Response (`200 OK`):**
```json
{
  "data": {
    "message": "If the address has an account, a reset link has been sent."
  }
}
```

---

### API 1.4: Logout Current Session
- **Endpoint:** `POST /api/v1/auth/logout`
- **Purpose:** Terminates the current mobile session on the server and removes its associated Firebase push token.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`204 No Content`):**
- *Empty response body.*

---

# Module 2: Identity & Session Hydration (`/me`)
**Screen Reference:** [`lib/app/screens/splash/view/splash_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/splash/view/splash_view.dart)

---

### API 2.1: Get Identity, Menu, Permissions & Badges
- **Endpoint:** `GET /api/v1/me`
- **Purpose:** Central session hydration call. Invoked:
  1. Immediately after login.
  2. When the app launches from cold start.
  3. When the app resumes from the background.
  4. After any approval decision to refresh badge counts.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`200 OK`):**
```json
{
  "data": {
    "user": {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "name": "Ayesha Khan",
      "email": "ayesha@acme.pk",
      "two_factor_enabled": false
    },
    "company": {
      "id": "01jb2x9m8n2p4q6r8s0t2u4v6w",
      "name": "Acme Textiles (Pvt) Ltd",
      "code": "K7MP2Q"
    },
    "permissions": {
      "employees.view": ["own"],
      "employees.sensitive.view": ["own"],
      "pay.view": ["own"],
      "support.view": ["own"],
      "support.raise": null
    },
    "modules": [
      "attendance",
      "leave",
      "payroll"
    ],
    "menu": [
      { "key": "home", "label": "Home", "icon": "home", "module": "core" },
      { "key": "requests", "label": "Requests", "icon": "inbox-stack", "module": "core" },
      { "key": "employees", "label": "Employees", "icon": "identification", "module": "core" }
    ],
    "badges": {
      "requests": 2
    }
  }
}
```

---

# Module 3: My Profile & Digital ID Card
**Screen References:**
- Profile Screen: [`lib/app/screens/profile/view/profile_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/profile/view/profile_view.dart)
- Digital Card: [`lib/app/screens/employee_card/view/employee_card_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/employee_card/view/employee_card_view.dart)

---

### API 3.1: Get My Employee Profile
- **Endpoint:** `GET /api/v1/me/profile`
- **Purpose:** Fetches the logged-in employee's complete profile. Shape is identical to `GET /employees/{id}`.
- **Auth Required:** Yes (Bearer Token)
- **Error:** `404 not_found` if signed in as a company user without an employee record (e.g. external auditor).

---

### API 3.2: Get Digital Employee ID Card
- **Endpoint:** `GET /api/v1/me/card`
- **Purpose:** Retrieves the digital ID badge details. The mobile app renders the live QR code using `qr_value`.
- **Security Invariant:** `qr_value` is an encrypted access token; never log or expose it in debug output.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`200 OK`):**
```json
{
  "data": {
    "company": {
      "name": "Acme Textiles (Pvt) Ltd",
      "short_name": "Acme",
      "phone": "+92 21 1234567",
      "address": "Plot 4, Korangi Industrial Area, Karachi"
    },
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
    "colour": "#012B43",
    "orientation": "vertical",
    "qr_value": "01jb2x9k4m7q8r3t5v6w8y0z1a_SECURE_TOKEN_VAL"
  }
}
```

---

# Module 4: Employee Self-Service Details Change
**Screen Reference:** [`lib/app/screens/edit_profile/view/edit_profile_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/edit_profile/view/edit_profile_view.dart)

---

### API 4.1: Submit Profile Details or Emergency Contact Change
- **Endpoint:** `POST /api/v1/me/details-change`
- **Purpose:** Submits an update to contact details or emergency contacts. Goes into the company approval chain, or applies immediately if company rules require no approval.
- **Auth Required:** Yes (Bearer Token)

**Request Body (Profile Details Change — `kind: "details"`):**
```json
{
  "kind": "details",
  "preferred_name": "Ayesha",
  "marital_status": "single",
  "personal_phone": "0300 2222222",
  "personal_email": "ayesha.personal@gmail.com",
  "address_line1": "House #42, Street 8",
  "address_line2": "Sector G-11/1",
  "city_name": "Islamabad",
  "postcode": "44000",
  "country_code": "PK"
}
```

**Request Body (Add New Emergency Contact — `kind: "emergency_contact"`):**
```json
{
  "kind": "emergency_contact",
  "name": "Bilal Khan",
  "relationship": "Brother",
  "phone": "0300 3333333",
  "alternative_phone": null,
  "address": "Islamabad",
  "is_primary": true
}
```

**Request Body (Update Existing Emergency Contact):**
```json
{
  "kind": "emergency_contact",
  "contact": "01jb2x9k4m7q8r3t5v6w8y0z1a",
  "name": "Bilal Khan",
  "relationship": "Brother",
  "phone": "0300 4444444",
  "alternative_phone": "051 1234567",
  "address": "Islamabad",
  "is_primary": true
}
```

**Success Response (`201 Created`):**
```json
{
  "data": {
    "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
    "type": "employee_details_change",
    "type_label": "Change of my details",
    "title": "Change of my details: personal phone",
    "status": "pending",
    "status_label": "Waiting",
    "status_tone": "amber",
    "submitted_at": "2026-10-22T09:15:00+00:00",
    "submitted_ago": "Just now"
  }
}
```

**Error Responses:**
- `409 conflict`: A request is already pending ("Wait for its answer or withdraw it first"), or no values were changed.
- `422 validation_failed`: Input format invalid.

---

# Module 5: Team & Colleague Directory
**Screen Reference:** [`lib/app/screens/index/view/index_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/index/view/index_view.dart)

---

### API 5.1: List Employees (Scoped Directory)
- **Endpoint:** `GET /api/v1/employees`
- **Purpose:** Fetches staff directory pre-filtered by the viewer's security scopes.
- **Auth Required:** Yes (Bearer Token)
- **Query Parameters:**
  * `search`: String (name, employee number, or email; up to 100 chars)
  * `department`: 26-char ULID
  * `designation`: 26-char ULID
  * `location`: 26-char ULID
  * `employment_type`: `full_time` | `part_time` | `bank_staff`
  * `stage`: `joining` | `probation` | `active` | `notice` | `left`
  * `per_page`: 1–100 (default: 25)
  * `page`: 1+

**Success Response (`200 OK`):**
```json
{
  "data": [
    {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "employee_number": "EMP-0001",
      "name": "Ayesha Khan",
      "designation": "Officer",
      "department": "Sales",
      "work_location": "Head office",
      "stage": "active"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 1,
    "last_page": 1
  }
}
```

---

### API 5.2: Get Single Employee Profile
- **Endpoint:** `GET /api/v1/employees/{id}`
- **Purpose:** Retrieves an employee's detailed profile. Sensitive sections (`personal`, `emergency_contacts`, `documents`) are present **only** if the viewer holds `employees.sensitive.view` permissions.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`200 OK`):**
```json
{
  "data": {
    "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
    "employee_number": "EMP-0001",
    "name": "Ayesha Khan",
    "designation": "Officer",
    "department": "Sales",
    "work_location": "Head office",
    "stage": "active",
    "first_name": "Ayesha",
    "last_name": "Khan",
    "preferred_name": null,
    "has_photo": false,
    "stage_label": "Active",
    "sections": [
      { "key": "overview", "label": "Overview" },
      { "key": "personal", "label": "Personal" }
    ],
    "job": {
      "legal_entity": "Acme Textiles (Pvt) Ltd",
      "work_location": "Head office",
      "department": "Sales",
      "sub_department": null,
      "designation": "Officer",
      "grade": null,
      "employment_type": "full_time",
      "contract_type": "permanent",
      "contract_ends_on": null,
      "joined_on": "2025-10-22",
      "probation_ends_on": null,
      "confirmed_on": null,
      "last_working_day": null,
      "left_on": null,
      "length_of_service": "1 year"
    },
    "contact": {
      "work_email": "ayesha@acme.pk",
      "work_phone": null
    },
    "personal": {
      "gender": "female",
      "date_of_birth": "1995-04-12",
      "blood_group": "B+",
      "marital_status": "single",
      "nationality": "PK",
      "personal_email": null,
      "personal_phone": "0300 1234567",
      "address": {
        "line1": "House 12",
        "line2": null,
        "city": "Karachi",
        "postcode": "75500",
        "country": "PK"
      }
    },
    "emergency_contacts": [
      {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "name": "Bilal Khan",
        "relationship": "Brother",
        "phone": "0300 7654321",
        "alternative_phone": null,
        "is_primary": true
      }
    ],
    "documents": [
      {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "kind": "passport",
        "expires_on": "2026-11-30",
        "days_left": 39
      }
    ]
  }
}
```

---

# Module 6: Unified Requests & Approvals Inbox
**Screen Reference:** [`lib/app/screens/regularization/view/regularization_view.dart`](file:///Users/rashid/Documents/Flutter%20Projects/ams_2/lib/app/screens/regularization/view/regularization_view.dart)

---

### API 6.1: List Approvals Inbox
- **Endpoint:** `GET /api/v1/approvals`
- **Purpose:** Fetches requests categorized by operational boxes.
- **Auth Required:** Yes (Bearer Token)
- **Query Parameters:**
  * `box`:
    - `waiting` (default: waiting for **my** personal approval)
    - `pending` (all requests waiting that I may decide as HR override)
    - `mine` (requests submitted by me)
    - `decided` (requests I have already approved or rejected)
  * `type`: Filter by request type (e.g. `employee_details_change`, `leave_application`, `missed_punch`)
  * `per_page`: 1–100 (default: 25)
  * `page`: 1+

**Success Response (`200 OK`):**
```json
{
  "data": [
    {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "type": "employee_details_change",
      "type_label": "Change of my details",
      "title": "Change of my details: personal phone",
      "employee": {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "name": "Ayesha Khan",
        "number": "EMP-0001",
        "department": "Sales"
      },
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
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 1,
    "last_page": 1
  }
}
```

---

### API 6.2: Get Single Approval Request Details
- **Endpoint:** `GET /api/v1/approvals/{id}`
- **Purpose:** Full audit view of request including proposed changes, workflow approval steps, previous decisions, and actionable capability flags.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`200 OK`):**
```json
{
  "data": {
    "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
    "type": "employee_details_change",
    "type_label": "Change of my details",
    "title": "Change of my details: personal phone",
    "employee": {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "name": "Ayesha Khan",
      "number": "EMP-0001",
      "department": "Sales"
    },
    "status": "pending",
    "status_label": "Waiting",
    "status_tone": "amber",
    "changes": [
      {
        "label": "Personal phone",
        "before": "0300 1111111",
        "after": "0300 2222222"
      }
    ],
    "facts": [],
    "steps": [
      {
        "position": 1,
        "approver": "Department manager",
        "status": "approved",
        "status_label": "Approved",
        "status_tone": "emerald",
        "skipped_reason": null,
        "approvers": []
      },
      {
        "position": 2,
        "approver": "Role: HR officer",
        "status": "current",
        "status_label": "Waiting for approval",
        "status_tone": "amber",
        "skipped_reason": null,
        "approvers": ["Sara Ahmed", "Usman Ali"]
      }
    ],
    "decisions": [
      {
        "step": 1,
        "by": "Maryam Siddiqui",
        "decision": "approved",
        "decision_label": "Approved",
        "comment": "Fine",
        "was_override": false,
        "at": "2026-10-22T10:00:00+00:00",
        "ago": "1 hour ago"
      }
    ],
    "can": {
      "approve": true,
      "reject": true,
      "as_override": false,
      "cancel": false
    }
  }
}
```

---

### API 6.3: Approve Request
- **Endpoint:** `POST /api/v1/approvals/{id}/approve`
- **Purpose:** Grants approval on the current step.
- **Auth Required:** Yes (Bearer Token)

**Request Body:**
```json
{
  "comment": "Approved as per department budget"
}
```

**Success Response (`200 OK`):**
- Returns the updated request payload (same shape as `GET /approvals/{id}`).

---

### API 6.4: Reject Request
- **Endpoint:** `POST /api/v1/approvals/{id}/reject`
- **Purpose:** Rejects the request. Rejection terminates the entire workflow and notifies the employee.
- **Rule:** `comment` is **mandatory**; max 1000 characters.
- **Auth Required:** Yes (Bearer Token)

**Request Body:**
```json
{
  "comment": "Requested phone number does not match corporate SIM register"
}
```

**Success Response (`200 OK`):**
- Returns the updated request payload with `status: "rejected"` and `status_tone: "rose"`.

---

### API 6.5: Cancel / Withdraw Request
- **Endpoint:** `POST /api/v1/approvals/{id}/cancel`
- **Purpose:** Allows the initiator to withdraw a pending request.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`200 OK`):**
- Returns updated request payload with `status: "cancelled"` and `status_tone: "slate"`.

---

# Module 7: In-App & Push Notifications
**Screen Reference:** In-app Notification Bell Modal & System Notifications

---

### API 7.1: Get Notifications List
- **Endpoint:** `GET /api/v1/notifications`
- **Purpose:** Returns in-app notifications. Entries are retained for 90 days.
- **Auth Required:** Yes (Bearer Token)
- **Query Parameters:** `unread=1` (filter unread only), `per_page=25`, `page=1`

**Success Response (`200 OK`):**
```json
{
  "data": [
    {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "kind": "approval_needed",
      "title": "Request to approve",
      "body": "Ayesha Khan: Change of my details: personal phone",
      "link": "https://laravel.ams-hrpayroll.com/requests/01jb2x9k4m7q8r3t5v6w8y0z1a",
      "target": {
        "screen": "request",
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a"
      },
      "read": false,
      "created_at": "2026-10-22T09:15:00+00:00",
      "created_ago": "5 minutes ago"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 1,
    "last_page": 1,
    "unread": 1
  }
}
```

---

### API 7.2: Mark Notification Read
- **Endpoint:** `POST /api/v1/notifications/{id}/read`
- **Purpose:** Marks an individual notification as read.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`204 No Content`):**
- *Empty response body.*

---

### API 7.3: Mark All Notifications Read
- **Endpoint:** `POST /api/v1/notifications/read-all`
- **Purpose:** Marks all unread bell notifications as read.
- **Auth Required:** Yes (Bearer Token)

**Success Response (`204 No Content`):**
- *Empty response body.*

---

### API 7.4: Get & Update Notification Preferences
- **Endpoint:** `GET /api/v1/me/notification-preferences` & `PUT /api/v1/me/notification-preferences`
- **Purpose:** Configures delivery channels (`mail`, `bell`, `push`) for each notification kind.
- **Strict Invariant:** `bell` (in-app notification) **CANNOT** be disabled. Attempting to set `bell: false` returns `422 validation_failed`.

**Success Response (`200 OK`):**
```json
{
  "data": {
    "approval_needed":   { "mail": true, "bell": true, "push": true },
    "request_approved":  { "mail": true, "bell": true, "push": true },
    "request_rejected":  { "mail": true, "bell": true, "push": true },
    "approval_reminder": { "mail": true, "bell": true, "push": false }
  }
}
```

---

### API 7.5: Register Push Token (FCM HTTP v1)
- **Endpoint:** `POST /api/v1/push-tokens`
- **Purpose:** Registers Firebase Cloud Messaging registration token after login and on `onTokenRefresh`.
- **Auth Required:** Yes (Bearer Token)

**Request Body:**
```json
{
  "token": "fcm_token_sample_4096_bytes...",
  "platform": "android",
  "app_version": "2.0.0"
}
```

**Success Response (`204 No Content`):**
- *Empty response body.*

---

# Roadmap Modules (Phases 10–17 Integration)

The upcoming phases from `doc/api.md` slot directly into AMS 2's architecture:

### 10.1 Attendance Actions, Geofencing & Breaks (Phase 10)
- `POST /api/v1/attendance/punch-in`: Records arrival with geofence coordinates (`latitude`, `longitude`, `accuracy_meters`).
- `POST /api/v1/attendance/punch-out`: Records departure and computes workday length and overtime.
- `POST /api/v1/attendance/break-start` & `POST /api/v1/attendance/break-end`: Tracks meal and tea breaks against daily allowed limit.

### 10.2 Facial Biometrics & Encrypted QR Engine (Phase 10)
- `POST /api/v1/biometrics/face-verify`: Multipart camera frame analysis for anti-spoofing liveness and 512-dim ISO/IEC match.
- `POST /api/v1/biometrics/qr-verify`: Validates dynamic time-expiring AES-256 tokens from physical gate turnstiles.

### 10.3 Leave Quotas & Leave Applications (Phase 11)
- `GET /api/v1/leaves/balances`: Casual, Annual, and Medical balances.
- `POST /api/v1/leaves/apply`: Submits leave application. Automatically routes to the `/approvals` inbox with `type: "leave_application"`.

### 10.4 Digital Payslips & Compensation (Phase 12)
- `GET /api/v1/payroll/payslips`: Monthly salary slips with basic pay, allowances, deductions, and tax withholdings.

### 10.5 Loans, Advances & Money Requests (Phase 13)
- `POST /api/v1/attendance/money-requests`: Salary advances and personal emergency loans. Automatically routes to the `/approvals` inbox with `type: "money_request"`.

### 10.6 Enterprise Kiosk Terminal & Visitor Management
- `GET /api/v1/organization/terminal/telemetry`: Headcount telemetry for kiosk tablet stations.
- `POST /api/v1/organization/visitors/entry`: Issues visitor pass with photo and automatically alerts host employee via FCM push notification.

---

# Master Endpoint Index Table

| # | Live Phase | Feature | Method | Endpoint Path | Auth Req |
|:---:|:---:|:---|:---:|:---|:---:|
| 1 | **Phase 7** | **Login (Credentials)** | `POST` | `/api/v1/auth/login` | No |
| 2 | **Phase 7** | **Two-Factor Challenge** | `POST` | `/api/v1/auth/two-factor` | No |
| 3 | **Phase 7** | **Forgot Password** | `POST` | `/api/v1/auth/forgot-password` | No |
| 4 | **Phase 7** | **Logout Session** | `POST` | `/api/v1/auth/logout` | Yes |
| 5 | **Phase 7** | **Session Hydration & Menu** | `GET` | `/api/v1/me` | Yes |
| 6 | **Phase 7** | **My Profile** | `GET` | `/api/v1/me/profile` | Yes |
| 7 | **Phase 7** | **My Digital ID Card** | `GET` | `/api/v1/me/card` | Yes |
| 8 | **Phase 7** | **Self-Service Details Change**| `POST` | `/api/v1/me/details-change` | Yes |
| 9 | **Phase 7** | **Employees Directory** | `GET` | `/api/v1/employees` | Yes |
| 10 | **Phase 7** | **Single Employee Profile** | `GET` | `/api/v1/employees/{id}` | Yes |
| 11 | **Phase 7** | **Universal Approvals Inbox** | `GET` | `/api/v1/approvals` | Yes |
| 12 | **Phase 7** | **Approval Request Details** | `GET` | `/api/v1/approvals/{id}` | Yes |
| 13 | **Phase 7** | **Approve Request** | `POST` | `/api/v1/approvals/{id}/approve` | Yes |
| 14 | **Phase 7** | **Reject Request** | `POST` | `/api/v1/approvals/{id}/reject` | Yes |
| 15 | **Phase 7** | **Cancel / Withdraw Request** | `POST` | `/api/v1/approvals/{id}/cancel` | Yes |
| 16 | **Phase 7** | **In-App Notifications List** | `GET` | `/api/v1/notifications` | Yes |
| 17 | **Phase 7** | **Mark Notification Read** | `POST` | `/api/v1/notifications/{id}/read` | Yes |
| 18 | **Phase 7** | **Mark All Read** | `POST` | `/api/v1/notifications/read-all` | Yes |
| 19 | **Phase 7** | **Get Notification Preferences**| `GET` | `/api/v1/me/notification-preferences` | Yes |
| 20 | **Phase 7** | **Set Notification Preferences**| `PUT` | `/api/v1/me/notification-preferences` | Yes |
| 21 | **Phase 7** | **Register Push Token (FCM)** | `POST` | `/api/v1/push-tokens` | Yes |
| 22 | **Phase 7** | **Delete Push Token** | `DELETE`| `/api/v1/push-tokens` | Yes |
| 23 | **Phase 10** | **Punch Clock-In** | `POST` | `/api/v1/attendance/punch-in` | Yes |
| 24 | **Phase 10** | **Punch Clock-Out** | `POST` | `/api/v1/attendance/punch-out` | Yes |
| 25 | **Phase 10** | **Start Break** | `POST` | `/api/v1/attendance/break-start` | Yes |
| 26 | **Phase 10** | **End Break** | `POST` | `/api/v1/attendance/break-end` | Yes |
| 27 | **Phase 10** | **Facial Match Biometrics** | `POST` | `/api/v1/biometrics/face-verify` | Yes |
| 28 | **Phase 10** | **Encrypted QR Verify** | `POST` | `/api/v1/biometrics/qr-verify` | Yes |
| 29 | **Phase 11** | **Leave Balances** | `GET` | `/api/v1/leaves/balances` | Yes |
| 30 | **Phase 11** | **Apply Leave (via Approvals)**| `POST` | `/api/v1/leaves/apply` | Yes |
| 31 | **Phase 12** | **Payslips List** | `GET` | `/api/v1/payroll/payslips` | Yes |
| 32 | **Phase 13** | **Money & Loan Requests** | `POST` | `/api/v1/attendance/money-requests` | Yes |
| 33 | **Phase 14** | **Visitor Entry Pass** | `POST` | `/api/v1/organization/visitors/entry` | Yes |
| 34 | **Phase 14** | **Visitor Checkout** | `POST` | `/api/v1/organization/visitors/{id}/exit`| Yes |

---

# Flutter Client Integration Blueprint & QA Checklist

### Standard Feature Repository Implementation Pattern
```dart
import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/approvals_model.dart';

class ApprovalsRepo {
  final String _tag = 'ApprovalsRepo / RegularizationScreen';

  Future<List<ApprovalItemModel>?> fetchApprovalsBox({
    String box = 'waiting',
    int page = 1,
  }) async {
    try {
      final response = await ApiClient.request(
        method: HttpMethod.get,
        endpoint: ApiEndpoints.approvals,
        queryParameters: {
          'box': box,
          'page': page,
        },
        tag: '$_tag -> fetchApprovalsBox($box)',
        showToastOnError: true,
      );

      // In accordance with api.md, success payload is wrapped in {"data": [...]}
      if (response == null || response is! Map<String, dynamic> || response['data'] is! List) {
        ExceptionHandler.handle(
          ApiException(
            message: 'Invalid response format from approvals API.',
            errorCode: 'INVALID_PAYLOAD',
          ),
          tag: '$_tag -> fetchApprovalsBox($box)',
        );
        return null;
      }

      final list = response['data'] as List;
      return list.map((item) => ApprovalItemModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Mapping approvals failed: $e'),
        tag: '$_tag -> fetchApprovalsBox($box) [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
```

### QA & Architectural Acceptance Criteria
1. **Dynamic Navigation Drawer:** All menu entries build directly from `GET /me` → `menu`. No client-side hardcoded role switching.
2. **Double-Tap Immunity:** All interactive submit buttons disable when `isLoading.value == true`.
3. **Error Handling Integrity:** Status and actions evaluate `error.code`; error message dialogs render the human-readable `message`.
4. **401 Session Purge:** Simulated 401 unauthenticated response causes instantaneous storage reset and immediate route replacement to `Routes.LOGIN`.
5. **90-Day Token Persistence:** Auth token is preserved across app terminations in `AppPreferences`.
6. **Card UI Compliance:** All cards strictly feature the `12.w` inside horizontal padding and `3.w` Modern Teal bottom accent border (`AppColors.secondary`).
