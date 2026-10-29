# AMS 2 Mobile API Implementation Status & Endpoint Specifications

This document tracks the implementation status of all endpoints defined in `doc/api.md` (up to Phase 13 — 26 October 2026). It distinguishes between live implemented endpoints and remaining endpoints, providing exhaustive specifications for remaining request bodies, query parameters, validation rules, and response contracts.

---

## Executive Summary

| Category | Count | Status |
|---|---|---|
| **Total Documented Endpoints** | **62** | Full API Surface (Phases 7–13) |
| **Implemented / Done Endpoints** | **55** | Live in Codebase (`ApiClient` + Repos + Screens) |
| **Remaining Endpoints** | **7** | Pending Implementation (Phase 10) |

---

## Part 1: Implemented / Done Endpoints (55 Endpoints)

All endpoints listed below are connected with the central network engine (`ApiClient.request()`), mapped in `ApiEndpoints`, and wired to their respective GetX Repositories and Controllers.

| # | HTTP Method | Endpoint | Phase | Implementation File / Method |
|---|---|---|---|---|
| 1 | `POST` | `/auth/login` | Phase 7 | `AuthRepo.login()` |
| 2 | `POST` | `/auth/two-factor` | Phase 7 | `AuthRepo.verifyTwoFactor()` |
| 3 | `POST` | `/auth/forgot-password` | Phase 7 | `AuthRepo.requestPasswordReset()` |
| 4 | `POST` | `/auth/logout` | Phase 7 | `AuthRepo.logout()`, `IndexRepo.logout()`, `ProfileRepo.logout()` |
| 5 | `GET` | `/me` | Phase 7 | `IndexRepo.fetchMe()` (Drives dynamic menu & badges) |
| 6 | `GET` | `/me/profile` | Phase 7 | `ProfileRepo.fetchSelfProfile()`, `EditProfileRepo.fetchProfile()` |
| 7 | `GET` | `/me/card` | Phase 7 | `EmployeeCardRepo.fetchEmployeeCard()` (Digital QR ID Card) |
| 8 | `GET` | `/employees` | Phase 7 | `DepartmentEmployeesRepo.fetchEmployees()` |
| 9 | `GET` | `/employees/{id}` | Phase 7 | `ProfileRepo.fetchEmployeeById()` |
| 10 | `GET` | `/approvals` | Phase 7 | `LeaveRepo.fetchApprovalsBox()` |
| 11 | `GET` | `/approvals/{id}` | Phase 7 | `LeaveRepo.fetchApprovalDetails()` |
| 12 | `POST` | `/approvals/{id}/approve` | Phase 7 | `LeaveRepo.approveRequest()` |
| 13 | `POST` | `/approvals/{id}/reject` | Phase 7 | `LeaveRepo.rejectRequest()` |
| 14 | `POST` | `/approvals/{id}/cancel` | Phase 7 | `LeaveRepo.cancelRequest()` |
| 15 | `POST` | `/me/details-change` | Phase 7 | `EditProfileRepo.submitDetailsChange()` |
| 16 | `GET` | `/notifications` | Phase 7 | `NotificationRepo.fetchNotifications()` |
| 17 | `POST` | `/notifications/{id}/read` | Phase 7 | `NotificationRepo.markAsRead()` |
| 18 | `POST` | `/notifications/read-all` | Phase 7 | `NotificationRepo.markAllAsRead()` |
| 19 | `GET` | `/me/notification-preferences` | Phase 7 | `NotificationRepo.fetchPreferences()` |
| 20 | `PUT` | `/me/notification-preferences` | Phase 7 | `NotificationRepo.updatePreferenceCategory()` |
| 21 | `POST` | `/push-tokens` | Phase 7 | `NotificationRepo.registerPushToken()`, `PushNotificationService` |
| 22 | `DELETE` | `/push-tokens` | Phase 7 | `NotificationRepo.deletePushToken()` |
| 23 | `GET` | `/me/attendance/today` | Phase 9 | `DashboardRepo.fetchTodayAttendance()` (Live telemetry & punch decisions) |
| 24 | `GET` | `/me/attendance/summary` | Phase 9 | `DashboardRepo.fetchMonthlySummary()`, `AttendanceSummaryRepo.fetchSummary()` |
| 25 | `POST` | `/me/attendance/punches` | Phase 10 | `DashboardRepo.submitPunch()`, `FaceRecognitionRepo.submitAttendancePunch()` (Selfie & Biometric Punch) |
| 26 | `GET` | `/me/attendance` | Phase 9 | `AttendanceHistoryRepo.fetchAttendanceHistory()` (Daily timesheet logs with `from` & `to` query range, 62-day limit, and filter pills) |
| 27 | `POST` | `/me/attendance/corrections` | Phase 9 | `CorrectionRepo.submitAttendanceCorrection()` (Attendance regularization, missed punch addition/removal & conflict management) |
| 28 | `GET` | `/me/schedule` | Phase 8 | `ScheduleRepo.fetchMySchedule()` (Working shift rota, pattern hours, overnight shifts & rest days) |
| 29 | `GET` | `/employees/{id}/schedule` | Phase 8 | `ScheduleRepo.fetchEmployeeSchedule()` (Manager & HR employee schedule audit within scope) |
| 30 | `GET` | `/holidays` | Phase 8 | `ScheduleRepo.fetchHolidays()` (Annual company & public gazetted holidays calendar) |
| 31 | `GET` | `/leave/types` | Phase 11 | `LeaveRepo.fetchLeaveTypes()` (Company leave categories, rules & balances eligibility) |
| 32 | `GET` | `/me/leave/balances` | Phase 11 | `LeaveRepo.fetchLeaveBalances()` (Live quota entitlement & breakdown) |
| 33 | `GET` | `/me/leave/requests` | Phase 11 | `LeaveRepo.fetchLeaveRequests()` (Employee submitted leave applications) |
| 34 | `POST` | `/me/leave/requests/preview` | Phase 11 | `LeaveRepo.previewLeaveRequest()` (Live sandwich rule & deduction dry run) |
| 35 | `POST` | `/me/leave/requests` | Phase 11 | `LeaveRepo.submitLeaveApplication()` (Official leave application via JSON / Multipart) |
| 36 | `POST` | `/me/leave/requests/{id}/cancel` | Phase 11 | `LeaveRepo.cancelLeaveRequest()` (Withdraw / cancel leave application) |
| 37 | `GET` | `/leave/whos-off` | Phase 11 | `LeaveRepo.fetchWhosOff()` (Department colleagues who's off calendar) |
| 38 | `GET` | `/me/payslips` | Phase 12 | `PayrollRepo.fetchPayslips()` (Finalized monthly payslips list, newest first, max 36) |
| 39 | `GET` | `/me/payslips/{id}` | Phase 12 | `PayrollRepo.fetchPayslipDetails()` (Itemized earnings, deductions, taxes, and net pay) |
| 40 | `GET` | `/me/payslips/{id}/pdf` | Phase 12 | `PayrollRepo.downloadPayslipPdf()` (Official printable PDF download) |
| 41 | `GET` | `/me/salary` | Phase 12 | `PayrollRepo.fetchActiveSalary()` (Active salary structure & recurring formula lines) |
| 42 | `GET` | `/me/money-request-types` | Phase 13 | `MoneyRequestRepo.fetchMoneyRequestTypes()` (Eligible request types & expense categories) |
| 43 | `POST` | `/me/money-requests` | Phase 13 | `MoneyRequestRepo.submitMoneyRequest()` (Loan/advance application or multipart expense claim with receipts) |
| 44 | `GET` | `/me/money-requests` | Phase 13 | `MoneyRequestRepo.fetchMoneyRequests()` (List submitted employee money requests) |
| 45 | `GET` | `/me/money-requests/{id}` | Phase 13 | `MoneyRequestRepo.fetchMoneyRequestDetails()` (Itemized audit, payout metadata, schedule, and recovery history) |
| 46 | `POST` | `/me/money-requests/{id}/cancel` | Phase 13 | `MoneyRequestRepo.cancelMoneyRequest()` (Cancel/withdraw pending money request) |
| 47 | `GET` | `/support/tickets` | Phase 10 | `SupportTicketRepo.fetchTickets()` (Lists user support tickets, active or finished) |
| 48 | `POST` | `/support/tickets` | Phase 10 | `SupportTicketRepo.createTicket()` (Opens support ticket with optional attachments) |
| 49 | `GET` | `/support/tickets/{id}` | Phase 10 | `SupportTicketRepo.fetchTicketDetails()` (Full message thread and attachments) |
| 50 | `POST` | `/support/tickets/{id}/replies` | Phase 10 | `SupportTicketRepo.replyTicket()` (Appends message reply with optional attachments) |
| 51 | `POST` | `/support/tickets/{id}/close` | Phase 10 | `SupportTicketRepo.closeTicket()` (Marks active ticket as closed) |
| 52 | `POST` | `/support/tickets/{id}/reopen` | Phase 10 | `SupportTicketRepo.reopenTicket()` (Reopens resolved ticket) |
| 53 | `GET` | `/support/tickets/{id}/files/{file}` | Phase 10 | `SupportTicketRepo.downloadAttachment()` (Downloads attachment file) |
| 54 | `GET` | `/employees/{id}/attendance` | Phase 9 | `AttendanceHistoryRepo.fetchEmployeeAttendance()`, `DepartmentEmployeesRepo.fetchEmployeeAttendance()` (Manager & HR subordinate attendance audit with range & punch logs) |
| 55 | `GET` | `/employees/{id}/leave` | Phase 11 | `LeaveRepo.fetchEmployeeLeave()`, `DepartmentEmployeesRepo.fetchEmployeeLeave()` (Manager & HR subordinate leave balances quota & request history audit) |

---

## Part 2: Remaining Endpoints & Detailed Specifications (7 Endpoints)

---

### Module 1: Schedule & Rota (Phase 8 — 3 Endpoints) `[STATUS: IMPLEMENTED / LIVE]`

#### 1. `GET /me/schedule` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `ScheduleRepo.fetchMySchedule()` / `ScheduleController.loadSchedule()` / `ScheduleView`
* **Purpose:** Fetches the logged-in user's work schedule/rota calculated from work patterns, rota overrides, and holidays.
* **Authentication:** `Authorization: Bearer <token>`
* **Query Parameters:**
  | Parameter | Type | Required | Rules & Description |
  |---|---|---|---|
  | `from` | string | Optional | `YYYY-MM-DD` (2000-01-01 to 2099-12-31). Required if `to` is supplied. |
  | `to` | string | Optional | `YYYY-MM-DD`, cannot be before `from`, max 62 days after `from`. |
  * *Default behavior:* When omitted, returns the next 14 days starting from the user's current date.
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "date": "2026-11-02",
        "type": "working",
        "label": "Day shift 09:00–17:00",
        "source": "pattern",
        "timezone": "Asia/Karachi",
        "shift": {
          "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
          "name": "Day shift",
          "code": "DAY",
          "colour": "sky",
          "kind": "fixed",
          "starts": "09:00",
          "ends": "17:00",
          "overnight": false,
          "break_minutes": 60
        },
        "starts_at": "2026-11-02T04:00:00Z",
        "ends_at": "2026-11-02T12:00:00Z",
        "planned_minutes": 420,
        "planned": "7:00",
        "holiday": null,
        "holiday_worked": false,
        "pattern": "Standard week"
      }
    ],
    "meta": { "employee": "01jb2x9k4m7q8r3t5v6w8y0z1a", "from": "2026-11-02", "to": "2026-11-08" }
  }
  ```
* **Errors:** `404` (No employee record linked), `409` (Range > 62 days), `422` (Invalid date format).

#### 2. `GET /employees/{id}/schedule` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `ScheduleRepo.fetchEmployeeSchedule()` / `ScheduleController`
* **Purpose:** Manager or HR views the schedule for a specific employee within their scope.
* **Path Parameters:**
  * `id` *(required, string)*: 26-character opaque ULID of the employee.
* **Query Parameters:** `from`, `to` (Same rules as `/me/schedule`).
* **Request Body:** None.
* **Errors:** `403` (Outside user's department/company reach), `404` (Employee not found).

#### 3. `GET /holidays` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `ScheduleRepo.fetchHolidays()` / `HolidaysBottomSheet`
* **Purpose:** Lists public and company-specific holidays applicable to the authenticated employee.
* **Query Parameters:**
  | Parameter | Type | Required | Rules & Description |
  |---|---|---|---|
  | `year` | integer | Optional | `2000` to `2099`. Default is the user's current calendar year. |
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "name": "Iqbal Day",
        "kind": "public",
        "starts_on": "2026-11-09",
        "ends_on": "2026-11-09",
        "is_paid": true
      }
    ],
    "meta": { "year": 2026 }
  }
  ```

---

### Module 2: Attendance Telemetry & History (Phase 9 — 5 Endpoints)

#### 4. `GET /me/attendance/today` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `DashboardRepo.fetchTodayAttendance()`
* **Purpose:** Returns the current day's punch state, allowed actions (`state.allowed`), refusal reasons, and (in Phase 10) hardware/biometric requirements.
* **Request Body:** None.
* **Response (200 OK):**
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
      "requires": {
        "position": true,
        "photo": true,
        "face": "match",
        "face_saved": false,
        "consent_text": "Your photo will be saved as your face for attendance."
      },
      "day": { "date": "2026-11-02", "status": "in_progress" }
    }
  }
  ```

#### 5. `GET /me/attendance` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `AttendanceHistoryRepo.fetchAttendanceHistory()` / `AttendanceHistoryController.loadTimesheet()` / `AttendanceHistoryView`
* **Purpose:** Fetches attendance day records (newest first) with interactive date-range selection and live telemetry.
* **Query Parameters:**
  | Parameter | Type | Required | Rules & Description |
  |---|---|---|---|
  | `from` | string | Optional | `YYYY-MM-DD` (2000-01-01 to 2099-12-31). Required if `to` is passed. |
  | `to` | string | Optional | `YYYY-MM-DD`, max 62 days range. |
  * *Default:* Past 14 days up to today.
* **Request Body:** None.

#### 6. `GET /me/attendance/summary` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `DashboardRepo.fetchMonthlySummary()`, `AttendanceSummaryRepo.fetchSummary()`
* **Purpose:** Month's totals (worked minutes, counted minutes, late occurrences, overtime status, deductions).
* **Query Parameters:**
  | Parameter | Type | Required | Rules & Description |
  |---|---|---|---|
  | `month` | string | Optional | `YYYY-MM` (Default: current month). |
* **Request Body:** None.

#### 7. `GET /employees/{id}/attendance` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `AttendanceHistoryRepo.fetchEmployeeAttendance()`, `DepartmentEmployeesRepo.fetchEmployeeAttendance()`, `AttendanceHistoryController.loadTimesheet()`
* **Purpose:** Team manager or HR retrieves attendance logs and punch timeline for an employee within scope (gated by `attendance.view` [department / company scope]).
* **Path Parameter:** `id` *(required, string)*: 26-character employee ULID.
* **Query Parameters:** `from`, `to` (Same as `/me/attendance`).
* **Request Body:** None.

#### 8. `POST /me/attendance/corrections` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `CorrectionRepo.submitAttendanceCorrection()` / `CorrectionController.submitCorrection()` / `CorrectionView`
* **Purpose:** Submits an attendance correction request (routed to universal approvals inbox).
* **Headers:** `Content-Type: application/json`
* **Request Body (JSON):**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `date` | string | Required | `YYYY-MM-DD`, cannot be in the future, cannot be payroll-locked. |
  | `add` | array | Optional | List of up to 10 punch objects to add: |
  | `add[].time` | string | Required | `HH:MM` (00:00 to 23:59). |
  | `add[].kind` | string | Required | `in` \| `out` \| `break_start` \| `break_end`. |
  | `add[].next_day` | boolean | Optional | `true` if this punch belongs to the morning end of an overnight shift. |
  | `remove` | array | Optional | List of up to 10 punch ID strings to remove. |
  | `reason` | string | Required | Plain text, up to 500 characters. |
  * *Constraint:* At least one item in `add` or `remove` must be provided.
* **Errors:** `409 Conflict` (Correction already pending for this date or day locked).

---

### Module 3: Punching & Biometrics (Phase 10 — 3 Endpoints)

#### 9. `POST /me/attendance/punches` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `DashboardRepo.submitPunch()`, `FaceRecognitionRepo.submitAttendancePunch()`
* **Purpose:** Mobile app attendance punch with geo-fencing and face verification.
* **Rate Limit:** 20 requests per minute.
* **Headers:** `Content-Type: application/json` or `multipart/form-data` (when `photo` is attached).
* **Request Body:**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `kind` | string | Required | `in` \| `out` \| `break_start` \| `break_end`. Must be present in `state.allowed`. |
  | `idempotency_key` | string | Required | 8–64 chars `[A-Za-z0-9_-]`. Client UUID generated per button press. |
  | `latitude` | double | Conditional | `-90` to `90`, max 6 decimals. Required if `requires.position: true`. |
  | `longitude` | double | Conditional | `-180` to `180`, max 6 decimals. Required if `requires.position: true`. |
  | `accuracy_m` | integer | Conditional | `0` to `10000` meters. Values > 150m are rejected if position required. |
  | `is_mocked` | boolean | Conditional | Android mock location flag. `true` causes immediate rejection (`409`). |
  | `break_type` | string | Optional | Break type ULID. Allowed only with `kind: break_start`. |
  | `photo` | file | Conditional | Camera capture (JPG, PNG, WEBP; max 2 MB; 160–4096 px per side). |
  | `face_match` | string | Conditional | Result of local face match: `matched` or `not_matched`. |
  | `face_score` | double | Conditional | Confidence score `0.0000` to `1.0000` (max 4 decimals). |
  | `face_consent` | boolean | Conditional | Required `true` when registering the baseline face (`requires.face_saved: false`). |
* **Response (201 Created):**
  ```json
  {
    "data": {
      "punch": { "id": "01jb2x9k4m7q8r3t5v6w8y0z1a", "time": "09:02", "role": "check_in", "source": "mobile_app" },
      "state": { "...": "updated punch state" },
      "requires": { "...": "updated requirements" },
      "day": { "...": "updated attendance day" }
    }
  }
  ```
* **Errors:** `409 Conflict` (Outside geo-fence, mocked location, inaccurate GPS, face did not match, punch not currently allowed), `422` (Validation failed).

#### 10. `GET /me/face`
* **Purpose:** Downloads the employee's registered face image for local on-device neural comparison.
* **Headers:** `Cache-Control: no-store` (Must only reside in volatile memory / RAM).
* **Request Body:** None.
* **Errors:** `404 Not Found` (No baseline face registered).

#### 11. `PUT /me/kiosk-pin`
* **Purpose:** Employee configures their self-service kiosk backup PIN for badge-less clocking.
* **Headers:** `Content-Type: application/json`
* **Request Body (JSON):**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `pin` | string | Required | 4 to 6 numeric digits. Cannot be all identical (`1111`) or sequential (`1234`, `4321`). |
  | `pin_confirmation` | string | Required | Must match `pin` exactly. |
* **Response (200 OK):** `{"data": {"kiosk_pin": true}}`

---

### Module 4: Tablet Kiosk Mode (Phase 10 — 5 Endpoints)

#### 12. `POST /kiosks`
* **Purpose:** Admin provisions a shared tablet kiosk. Authenticated via user token with kiosk management privileges.
* **Headers:** `Authorization: Bearer <user_token>`, `Content-Type: application/json`
* **Request Body (JSON):**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `name` | string | Required | 2 to 60 characters (e.g., "Main Reception Kiosk"). |
  | `location` | string | Required | 26-character work location ULID. |
  | `replace` | boolean | Optional | `true` to revoke existing secret and regenerate for an existing kiosk. |
* **Response (201 Created):**
  ```json
  {
    "data": {
      "kiosk": { "id": "01jb2x9k4m7q8r3t5v6w8y0z1a", "name": "Front desk", "pin_allowed": true },
      "token": "kiosk_secret_token_here"
    }
  }
  ```
* *Action:* Tablet stores `token` securely, then calls `POST /auth/logout` to terminate user session. Subsequent kiosk requests use `Authorization: Bearer <kiosk_token>`.

#### 13. `GET /kiosk`
* **Purpose:** Retrieves active kiosk configuration, location name, and `pin_allowed` flag.
* **Authentication:** `Authorization: Bearer <kiosk_token>`
* **Request Body:** None.

#### 14. `POST /kiosk/identify`
* **Purpose:** Identifies an employee at the kiosk via QR badge scan or employee number + PIN.
* **Authentication:** `Authorization: Bearer <kiosk_token>`
* **Request Body (JSON):**
  * *Option A (QR Badge):*
    ```json
    { "badge": "opaque_qr_card_string" }
    ```
  * *Option B (PIN Fallback):*
    ```json
    { "employee_number": "EMP-0001", "pin": "7492" }
    ```
* **Response (200 OK):**
  ```json
  {
    "data": {
      "person": { "id": "01jb...", "name": "Ayesha Khan", "employee_number": "EMP-0001" },
      "ticket": "eyJhbGciOi...",
      "expires_in": 120,
      "state": { "allowed": ["in"] },
      "requires": { "photo": true, "face": "match", "face_saved": true }
    }
  }
  ```
* **Errors:** `409` (Invalid card, wrong PIN, account locked after repeated failed attempts).

#### 15. `GET /kiosk/face`
* **Purpose:** Fetches the identified employee's face photo for local verification on the kiosk tablet.
* **Authentication:** `Authorization: Bearer <kiosk_token>`
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `ticket` | string | Required | Short-lived ticket obtained from `/kiosk/identify`. |
* **Request Body:** None.

#### 16. `POST /kiosk/punches`
* **Purpose:** Records attendance punch from kiosk.
* **Authentication:** `Authorization: Bearer <kiosk_token>`
* **Request Body:**
  * **Online Mode (Live):**
    | Field | Type | Required | Description |
    |---|---|---|---|
    | `ticket` | string | Required | Valid identify ticket (expires in 2 minutes). |
    | `kind` | string | Required | `in` \| `out` \| `break_start` \| `break_end`. |
    | `idempotency_key` | string | Required | UUID. |
    | `photo`, `face_match`, `face_score`, `face_consent` | Various | Conditional | Same biometric fields as mobile punch. |
  * **Offline Mode (Queued punches during connectivity loss):**
    | Field | Type | Required | Description |
    |---|---|---|---|
    | `badge` or (`employee_number` + `pin`) | string | Required | Employee identity credentials. |
    | `punched_at` | string | Required | ISO 8601 with timezone offset (at most 24 hours old). |
    | `kind`, `idempotency_key` | string | Required | Punch action and UUID. |
    | `photo`, `face_match`, `face_score` | Various | Conditional | Captured biometrics. |

---

### Module 5: Support Tickets (Phase 10 — 7 Endpoints) `[STATUS: IMPLEMENTED / LIVE]`

#### 17. `GET /support/tickets` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.fetchTickets()` / `SupportTicketController.loadTickets()` / `SupportTicketsView`
* **Purpose:** Lists support tickets visible to the user.
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `finished` | integer | Optional | Pass `1` to include resolved and closed tickets. |
  | `per_page` | integer | Optional | Pagination size. |
  | `page` | integer | Optional | Page number. |
* **Request Body:** None.

#### 18. `POST /support/tickets` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.createTicket()` / `SupportTicketController.submitNewTicket()` / `CreateTicketBottomSheet`
* **Purpose:** Opens a new support ticket with the AMS engineering and operations team.
* **Headers:** `Content-Type: application/json` or `multipart/form-data`.
* **Request Body:**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `subject` | string | Required | Up to 150 characters. |
  | `category` | string | Optional | `technical` \| `billing` \| `account` \| `feature_request` \| `other`. |
  | `priority` | string | Optional | `low` \| `normal` \| `high` \| `urgent`. |
  | `body` | string | Required | 2 to 10,000 characters. |
  | `page_url` | string | Optional | HTTP/HTTPS URL, up to 500 characters. |
  | `attachments[]` | file array | Optional | Up to 5 files (JPG, PNG, GIF, WEBP, PDF, TXT, CSV, XLSX, DOCX; max 5 MB each). |
* **Response (201 Created):** Returns full ticket thread structure.

#### 19. `GET /support/tickets/{id}` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.fetchTicketDetails()` / `SupportTicketController.openTicketThread()` / `TicketThreadBottomSheet`
* **Purpose:** Retrieves full message thread and attachments for a ticket.
* **Path Parameter:** `id` *(required, string)*: 26-character ticket ULID.
* **Request Body:** None.

#### 20. `POST /support/tickets/{id}/replies` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.replyTicket()` / `SupportTicketController.sendReply()` / `TicketThreadBottomSheet`
* **Purpose:** Appends a reply message to an open support ticket.
* **Path Parameter:** `id` *(required, string)*: Ticket ULID.
* **Headers:** `Content-Type: application/json` or `multipart/form-data`.
* **Request Body:**
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `body` | string | Required | 2 to 10,000 characters. |
  | `attachments[]` | file array | Optional | Up to 5 files (max 5 MB each). |
* **Response (201 Created):** Returns updated ticket thread.

#### 21. `POST /support/tickets/{id}/close` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.closeTicket()` / `SupportTicketController.closeTicket()` / `TicketThreadBottomSheet`
* **Purpose:** Marks an active ticket as closed.
* **Path Parameter:** `id` *(required, string)*: Ticket ULID.
* **Request Body:** None.

#### 22. `POST /support/tickets/{id}/reopen` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.reopenTicket()` / `SupportTicketController.reopenTicket()` / `TicketThreadBottomSheet`
* **Purpose:** Reopens a previously resolved ticket.
* **Path Parameter:** `id` *(required, string)*: Ticket ULID.
* **Rules:** Only tickets in `resolved` status can be reopened (`403` otherwise).
* **Request Body:** None.

#### 23. `GET /support/tickets/{id}/files/{file}` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `SupportTicketRepo.downloadAttachment()` / `SupportTicketController.openAttachment()` / `TicketThreadBottomSheet`
* **Purpose:** Downloads a file attachment from a support ticket message.
* **Path Parameters:** `id` (Ticket ULID), `file` (Attachment ID).
* **Request Body:** None.

---

### Module 6: Leave System (Phase 11 — 8 Endpoints) `[STATUS: IMPLEMENTED / LIVE]`

#### 24. `GET /leave/types` `[STATUS: IMPLEMENTED / LIVE]`
* **Purpose:** Fetches all available leave categories, rules, and balances eligibility.
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "name": "Annual leave",
        "code": "AL",
        "colour": "emerald",
        "category": "annual",
        "is_paid": true,
        "unit": "day",
        "allow_half_days": true,
        "min_notice_days": 2,
        "max_days_in_row": 14,
        "attachment_after_days": 3,
        "allow_past_days": false,
        "has_balance": true
      }
    ]
  }
  ```

#### 25. `GET /me/leave/balances`
* **Purpose:** Quota, earned, taken, pending, and remaining balance breakdown for the current leave year.
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `on` | string | Optional | `YYYY-MM-DD` (Default: today). Determines the leave year. |
* **Request Body:** None.

#### 26. `GET /me/leave/requests`
* **Purpose:** Lists the employee's submitted leave requests (newest first).
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `per_page` | integer | Optional | Items per page (default: 25). |
  | `page` | integer | Optional | Page index (1+). |
* **Request Body:** None.

#### 27. `POST /me/leave/requests/preview`
* **Purpose:** Live non-persisting dry run of leave calculations (sandwich rule, deduction amounts, remaining balance preview) as user edits the form.
* **Request Body (JSON):** Identical structure to `POST /me/leave/requests`.
* **Response (200 OK):**
  ```json
  {
    "data": {
      "ok": true,
      "message": null,
      "fields": {},
      "days": 2.0,
      "amount": 2.0,
      "amount_text": "2 days",
      "available_text": "18 days",
      "after_text": "16 days"
    }
  }
  ```

#### 28. `POST /me/leave/requests`
* **Purpose:** Submits an official leave request into the universal approvals inbox.
* **Headers:** `Content-Type: application/json` or `multipart/form-data`.
* **Request Body:**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `leave_type` | string | Required | Valid Leave Type ULID from `/leave/types`. |
  | `starts_on` | string | Required | `YYYY-MM-DD` (2000–2099, within a single leave year). |
  | `ends_on` | string | Required | `YYYY-MM-DD`, cannot be before `starts_on`, max 92 days. (For hourly leave: `ends_on == starts_on`). |
  | `start_part` | string | Optional | `full` (default) \| `first_half` \| `second_half`. |
  | `end_part` | string | Optional | `full` (default) \| `first_half` \| `second_half`. |
  | `starts_at` | string | Conditional | `HH:MM` (Required for hourly leave types, must fall within shift). |
  | `duration` | string | Conditional | `H:MM` (Required for hourly leave types). |
  | `reason` | string | Optional | Plain text, up to 500 characters. |
  | `attachment` | file | Conditional | PDF, JPG, PNG (max 5 MB). Mandatory if requested days exceed `attachment_after_days`. |
* **Response (201 Created):** Full approval request object (`status: pending`).
* **Errors:** `409 Conflict` (Overlap with existing leave, worked day conflict, insufficient balance, probation restriction).

#### 29. `POST /me/leave/requests/{id}/cancel`
* **Purpose:** Cancels/withdraws a leave request (while waiting, or approved before commencement).
* **Path Parameter:** `id` *(required, string)*: Leave Request ULID.
* **Request Body (JSON):**
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `reason` | string | Required | Plain text, up to 500 characters. |

#### 30. `GET /leave/whos-off`
* **Purpose:** Calendar query showing which team/department members are on approved leave.
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `from` | string | Optional | `YYYY-MM-DD` (Default: today). |
  | `to` | string | Optional | `YYYY-MM-DD` (Max 92 days range). |
* **Request Body:** None.

#### 31. `GET /employees/{id}/leave` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `LeaveRepo.fetchEmployeeLeave()`, `DepartmentEmployeesRepo.fetchEmployeeLeave()`, `DepartmentEmployeesController.fetchEmployeeLeaveAudit()`, `EmployeeLeaveAuditSheet`
* **Purpose:** Manager / HR audit of subordinate employee's leave quota balances and submitted request history (gated by `leave.view` [department / company scope]).
* **Path Parameter:** `id` *(required, string)*: Employee ULID.
* **Request Body:** None.
* **Errors:** `403` (Outside scope), `404` (Not found).

---

### Module 7: Payroll & Payslips (Phase 12 — 4 Endpoints) `[STATUS: IMPLEMENTED / LIVE]`

#### 32. `GET /me/payslips` `[STATUS: IMPLEMENTED / LIVE]`
* **Purpose:** Lists finalized historical payslips for the authenticated employee (newest first, max 36).
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": [
      {
        "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
        "period": "July 2026",
        "pays_on": "2026-07-31",
        "employer": "Acme Textiles (Pvt) Ltd",
        "currency": "PKR",
        "net": 14918000,
        "net_text": "Rs 149,180.00",
        "gross_text": "Rs 155,000.00"
      }
    ]
  }
  ```

#### 33. `GET /me/payslips/{id}`
* **Purpose:** Comprehensive payslip audit breakdown: gross pay, itemized earnings, deductions, tax, net pay, and employer contributions.
* **Path Parameter:** `id` *(required, string)*: Payslip ULID.
* **Request Body:** None.
* **Errors:** `404 Not Found` (Draft runs or payslips of other employees never return).

#### 34. `GET /me/payslips/{id}/pdf`
* **Purpose:** Downloads official printable payslip PDF.
* **Path Parameter:** `id` *(required, string)*: Payslip ULID.
* **Response:** Binary stream with header `Content-Type: application/pdf`.
* **Request Body:** None.

#### 35. `GET /me/salary`
* **Purpose:** Retrieves the current active salary structure and recurring formula lines.
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": {
      "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
      "effective_from": "2026-01-01",
      "basis": "period",
      "basis_label": "Per pay period",
      "schedule": "Monthly",
      "payment_method": "Bank transfer",
      "currency": "PKR",
      "social_security_enrolled": true,
      "lines": [
        { "code": "BASIC", "name": "Basic salary", "kind": "earning", "amount": 10000000, "amount_text": "Rs 100,000.00", "percent": null },
        { "code": "HRA", "name": "House rent allowance", "kind": "earning", "amount": null, "amount_text": null, "percent": "45" }
      ]
    }
  }
  ```

---

### Module 8: Loans, Advances & Expenses (Money Requests) (Phase 13 — 5 Endpoints) `[STATUS: IMPLEMENTED / LIVE]`

#### 36. `GET /me/money-request-types` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `MoneyRequestRepo.fetchMoneyRequestTypes()` / `MoneyRequestController.loadData()` / `ApplyMoneyRequestBottomSheet`
* **Purpose:** Returns the eligible money request types (`loan`, `advance`, `payment`, `expense`) and expense categories.
* **Request Body:** None.
* **Response (200 OK):**
  ```json
  {
    "data": {
      "types": [
        {
          "id": "01jb2x9k4m7q8r3t5v6w8y0z1a",
          "name": "Staff loan",
          "kind": "loan",
          "kind_label": "Loan",
          "repayable": true,
          "has_lines": false,
          "max_instalments": 24,
          "max_per_request": "Rs 200,000.00",
          "max_outstanding": null,
          "receipt_required": false
        }
      ],
      "categories": [
        { "id": "01jb2x9k4m7q8r3t5v6w8y0z1b", "name": "Travel & Fuel" }
      ]
    }
  }
  ```

#### 37. `POST /me/money-requests` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `MoneyRequestRepo.submitMoneyRequest()` / `MoneyRequestController.submitRequest()` / `ApplyMoneyRequestBottomSheet`
* **Purpose:** Submits an advance, staff loan, or expense reimbursement request. Supports standard JSON and multipart form data for expense claims with receipts.
* **Headers:** `Content-Type: application/json` or `multipart/form-data` (when receipts are attached).
* **Request Body:**
  | Field | Type | Required | Rules & Constraints |
  |---|---|---|---|
  | `type` | string | Required | Valid Type ULID from `/me/money-request-types`. |
  | `amount` | string/number | Conditional | Major units (`"30000"`, `"1250.50"`). Required for non-line types (`loan`, `advance`, `payment`). Forbidden for `expense` (which uses itemized lines). |
  | `instalments` | integer | Conditional | `1` to `120` (cannot exceed `max_instalments`). Required for `loan` & `advance`. Not allowed for `expense` or `payment`. |
  | `reason` | string | Optional | Plain text, up to 500 characters. |
  | `lines[]` | array | Conditional | Required for expense claims (1 to 30 lines): |
  | `lines[].category` | string | Required | Expense category ULID. |
  | `lines[].spent_on` | string | Required | `YYYY-MM-DD` (cannot be in the future). |
  | `lines[].amount` | string/number | Required | Positive value up to currency decimal precision. |
  | `lines[].note` | string | Optional | Plain text, up to 255 characters. |
  | `receipts[]` | file array | Conditional | PDF, JPG, PNG (max 5 MB each). Exactly matches index of `lines[]`. Required on every line if `receipt_required: true`. |
* **Response (201 Created):** Full money request entity with status `pending`.
* **Errors:** `409 Conflict` (Policy limits exceeded, missing receipt, invalid type for employee), `422` (Validation failed).

#### 38. `GET /me/money-requests` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `MoneyRequestRepo.fetchMoneyRequests()` / `MoneyRequestController.loadData()` / `MoneyRequestsView`
* **Purpose:** Lists employee's submitted money requests with filter pills (`All`, `Loans`, `Advances`, `Expenses`).
* **Query Parameters:**
  | Parameter | Type | Required | Description |
  |---|---|---|---|
  | `per_page` | integer | Optional | Items per page (default: 25). |
  | `page` | integer | Optional | Page index (1+). |
* **Request Body:** None.

#### 39. `GET /me/money-requests/{id}` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `MoneyRequestRepo.fetchMoneyRequestDetails()` / `MoneyRequestController.openDetails()` / `MoneyRequestDetailsBottomSheet`
* **Purpose:** Audit details of a money request, repayment schedule, itemized expense lines, and payroll recovery records.
* **Path Parameter:** `id` *(required, string)*: Money Request ULID.
* **Request Body:** None.

#### 40. `POST /me/money-requests/{id}/cancel` `[STATUS: IMPLEMENTED / LIVE]`
* **Implementation:** `MoneyRequestRepo.cancelMoneyRequest()` / `MoneyRequestController.cancelRequest()` / `MoneyRequestDetailsBottomSheet`
* **Purpose:** Cancels a pending money request with optional cancellation reason.
* **Path Parameter:** `id` *(required, string)*: Money Request ULID.
* **Request Body (JSON):**
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `reason` | string | Optional | Plain text, up to 500 characters. |
* **Errors:** `409 Conflict` (Request is no longer `pending`).
