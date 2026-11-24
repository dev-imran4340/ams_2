# AMS 2 — Comprehensive Developer Architecture & System Specification Report

> **Project Name:** AMS 2 (Attendance Management System & Enterprise HR Suite)  
> **Client / Organization:** Softech Business Services (SMC-PVT) Limited  
> **Platform:** Flutter (iOS & Android)  
> **Target SDKs:** Dart 3.x, Flutter 3.x (ScreenUtil Responsive Architecture)  
> **Architecture Pattern:** Strict MVVM with Repository Pattern powered by GetX  
> **Base API URL:** `https://laravel.ams-hrpayroll.com/api/v1`  
> **Documentation Version:** 2.0.0 (Production Master)  

---

## Table of Contents
1. [Executive Summary & Architectural Invariants](#1-executive-summary--architectural-invariants)
2. [Design System & Corporate Navy / Teal Invariants](#2-design-system--corporate-navy--teal-invariants)
3. [Network Engine, Authentication & Security Protocol](#3-network-engine-authentication--security-protocol)
4. [Session Hydration, Permission Matrix & Dynamic Menu System (`GET /me`)](#4-session-hydration-permission-matrix--dynamic-menu-system-get-me)
5. [Universal Screen Directory, Navigation & Route Registry](#5-universal-screen-directory-navigation--route-registry)
   - [5.1 Splash & Authentication Hub](#51-splash--authentication-hub)
   - [5.2 Main Shell & Adaptive Dashboard](#52-main-shell--adaptive-dashboard)
   - [5.3 Attendance Actions, Biometrics & Geofencing](#53-attendance-actions-biometrics--geofencing)
   - [5.4 Enterprise Kiosk Terminal & Backup PIN](#54-enterprise-kiosk-terminal--backup-pin)
   - [5.5 Employee Directory & Digital ID Card](#55-employee-directory--digital-id-card)
   - [5.6 Unified Requests & Approvals Governance Inbox](#56-unified-requests--approvals-governance-inbox)
   - [5.7 Leave Management System](#57-leave-management-system)
   - [5.8 Payroll & Itemized Payslips](#58-payroll--itemized-payslips)
   - [5.9 Loans, Advances & Expense Claims](#59-loans-advances--expense-claims)
   - [5.10 Shift Schedules, Rotas & Holidays](#510-shift-schedules-rotas--holidays)
   - [5.11 Performance Reviews, Goals & Peer Nominations](#511-performance-reviews-goals--peer-nominations)
   - [5.12 Documents, Policies, Letters & Corporate News](#512-documents-policies-letters--corporate-news)
   - [5.13 Enterprise Onboarding Suite (Assets, Training, Checklists, JD)](#513-enterprise-onboarding-suite-assets-training-checklists-jd)
   - [5.14 Helpdesk & Technical Support Ticketing](#514-helpdesk--technical-support-ticketing)
   - [5.15 In-App Notifications & Preference Channels](#515-in-app-notifications--preference-channels)
   - [5.16 Profile Management & Account Security](#516-profile-management--account-security)
6. [Master API Endpoints Integration Matrix](#6-master-api-endpoints-integration-matrix)
7. [State Management, Storage Isolation & Lifecycle Protocols](#7-state-management-storage-isolation--lifecycle-protocols)
8. [Developer Pre-Flight Verification Checklist](#8-developer-pre-flight-verification-checklist)

---

# 1. Executive Summary & Architectural Invariants

AMS 2 is an enterprise-grade mobile human resource and attendance automation application built on an adaptive single-app architecture. It dynamically reconfigures its UI, operational permissions, navigation tabs, and approval workflows according to the permissions matrix returned by the server upon authentication.

### 1.1 Architectural Pattern
The codebase strictly adheres to **MVVM (Model-View-ViewModel) with the Repository Pattern**, powered by **GetX**:

```
View (Widget)
    │
    ▼ (User actions & Obx reactive bindings)
Controller (GetxController)
    │
    ▼ (Business logic & origin-tagged calls)
Repository (FeatureRepo)
    │
    ▼ (JSON serialization & origin tracer)
ApiClient (Central Network Engine)
    │
    ▼ (HTTP Request with Bearer Token & Device Headers)
Backend REST API (Laravel v1)
```

### 1.2 Strict Invariants
1. **Zero Client-Side Roles:** Hardcoding `if (role == 'admin')` is strictly banned. Access is governed dynamically by `GET /me -> permissions` and `data.menu`.
2. **Zero Direct Network Calls from Controllers/Views:** Views communicate exclusively with Controllers; Controllers communicate exclusively with Repositories; Repositories communicate exclusively with `ApiClient.request()` or `ApiClient.requestMultipart()`.
3. **Storage Isolation:** `GetStorage` is completely encapsulated within `AppPreferences`. No controller or view accesses raw storage keys.
4. **Zero Fallback / Zero Dummy Data Policy:** No fake counters, fallback arrays, or mock punch records are injected into live endpoints. When network fails, the view renders centered `CustomStateView.error(...)` or `CustomStateView.empty(...)`.
5. **Mandatory Origin Tracing:** Direct `print()` is banned. Every network call and exception logs an origin tag:
   ```dart
   tag: 'FeatureRepo / FeatureScreen -> methodName()'
   ```
6. **Route Dependency Injection via `BindingsBuilder`:** Separate `binding/` folders are prohibited. All dependency bindings are registered inline in `app_pages.dart` using `fenix: true`.

---

# 2. Design System & Corporate Navy / Teal Invariants

The design system enforces a sleek corporate aesthetic with responsive sizing via `flutter_screenutil`.

### 2.1 Centralized Palette (`AppColors`)
* **Primary Brand Navy:** `AppColors.primary` (`0xFF012B43`)
* **Accent Modern Teal:** `AppColors.secondary` (`0xFF0DA6A3`)
* **Lite Primary Tint:** `AppColors.litePrimary` (`0xFF99BBD6`)
* **Lite Secondary Tint:** `AppColors.liteSecondary` (`0xFFB4E3E4`)
* **Intermediate Navy:** `AppColors.accentNavy` (`0xFF023E61`)
* **Dynamic Theme Getters:** `AppColors.backgroundColor`, `AppColors.cardBackground`, `AppColors.textColor`, `AppColors.subTextColor`, `AppColors.borderColor`, `AppColors.error`, `AppColors.success`.

> [!CAUTION]
> Hardcoding hex colors (`Color(0xFF...)`) or raw ternary themes in UI files is strictly prohibited. All colors must resolve from `AppColors`.

### 2.2 Signature Floating Card Blueprint
Every main card container must adhere to the exact floating card blueprint:
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
  decoration: BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(15.r),
    border: Border(
      bottom: BorderSide(color: AppColors.secondary, width: 3.w),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.06),
        blurRadius: 10.r,
        offset: Offset(0, 4.h),
      ),
    ],
  ),
  child: ...,
)
```

### 2.3 Visual Invariants
* **Responsiveness:** All dimensions, padding, margins, radiuses, and font sizes must use `.w`, `.h`, `.sp`, `.r`.
* **Curved Header:** Main module screens feature `EmployeeAmbientHeader(height: 220.h - 240.h)` inside a `Stack`.
* **Primary Buttons:** Built with `CustomButton(isGradient: true, text: '...')` featuring Corporate Navy to Teal gradient.
* **Centered Empty / Error States:** `CustomStateView.empty(...)` and `CustomStateView.error(...)` must be centered horizontally and vertically using `Center(child: ...)`.
* **Form Validation & Auto-Scroll:** All user forms require `GlobalKey<FormState>()`. On validation failure, the view automatically scrolls to the first invalid field (`Scrollable.ensureVisible()`) and requests focus (`FocusNode.requestFocus()`).

---

# 3. Network Engine, Authentication & Security Protocol

### 3.1 Network Engine (`ApiClient`)
Located at `lib/app/api/api_client.dart`, `ApiClient` handles all HTTP traffic:
* **JSON Requests:** `ApiClient.request({required HttpMethod method, required String endpoint, dynamic body, ...})`
* **Multipart / File Uploads:** `ApiClient.requestMultipart({required HttpMethod method, required String endpoint, Map<String, String>? fields, List<http.MultipartFile>? files, ...})`
* **Default Timeout:** 30 seconds with automatic DNS / handshake retry.

### 3.2 Standard Request Headers
```http
Authorization: Bearer <token>
Accept: application/json
Content-Type: application/json (or multipart/form-data)
X-Device-Id: <UUID>
X-App-Version: 2.0.0
X-Client-Platform: android | ios
```

### 3.3 Token Dual-Architecture
1. **User Personal Token (`ams_...`):** Saved in `AppPreferences.token`. Used for all personal employee and manager operations (`/me/...`, `/approvals`, `/employees`, `/tasks`).
2. **Kiosk Secret Token (`kiosk_...`):** Saved in `AppPreferences.kioskToken`. Provisioned via `POST /kiosks`. Used exclusively on shared reception tablet terminals (`/kiosk`, `/kiosk/identify`, `/kiosk/face`, `/kiosk/punches`).

### 3.4 Exception Handling & Status Code Protocol (`ExceptionHandler`)
Located at `lib/app/api/exception_handler.dart`:
* **200 / 201:** Success envelope deserialization.
* **204:** Success with empty body (`No Content`).
* **401 `unauthenticated`:**
  * **User Token Request:** Automatically invokes `AppPreferences.clearAuth()` and redirects to `Routes.LOGIN`.
  * **Kiosk Terminal Request:** Revokes only local kiosk credentials via `AppPreferences.clearKioskToken()`. Does **NOT** logout the mobile user session.
* **403 `account_unavailable`:** Clears auth and forces user redirect to login.
* **409 `conflict`:** Business rule conflict (e.g. punch not allowed outside geofence, invalid Kiosk PIN). Displays `error.message`.
* **422 `validation_failed`:** Backend validation error. Form fields receive error strings from `error.fields`.
* **429 `too_many_requests`:** Extracts `Retry-After` header value and locks retry buttons with a countdown timer.

### 3.5 26-Character Opaque ULIDs
All database primary keys are 26-character alphanumeric ULIDs (e.g., `01jb2x9k4m7q8r3t5v6w8y0z1a`). Integer parsing (`int.parse()`) is strictly prohibited.

---

# 4. Session Hydration, Permission Matrix & Dynamic Menu System (`GET /me`)

Whenever the app launches, returns to the foreground, or authenticates, it calls `GET /api/v1/me`. This single endpoint drives the entire app's navigation and permissions.

### 4.1 Master Session Payload
```json
{
  "data": {
    "user": {
      "id": "01m6jjx5a2f1hrxfbbdtrd59cz",
      "name": "Malik Muhammad Imran",
      "email": "imran.dev4340@gmail.com",
      "two_factor_enabled": false,
      "must_change_password": false
    },
    "company": {
      "id": "01m6jjtd54skpxc1tkjrhy2zp4",
      "name": "Softech Business Services (SMC-PVT) Limited",
      "code": "DN8VF3"
    },
    "permissions": {
      "employees.view": ["own"],
      "employees.sensitive.view": ["own"],
      "pay.view": ["own"],
      "schedules.view": ["own"],
      "attendance.view": ["own"],
      "leave.view": ["own"],
      "money.view": ["own"],
      "performance.view": ["own"],
      "documents.view": ["own"],
      "assets.view": ["own"],
      "training.view": ["own"],
      "support.view": ["own"],
      "support.raise": null,
      "kiosks.manage": null
    },
    "modules": [
      "core", "attendance", "devices", "leave", "payroll",
      "loans_expenses", "performance", "documents", "onboarding", "reports"
    ],
    "menu": [
      { "key": "home", "label": "Home", "icon": "home", "module": "core" },
      { "key": "requests", "label": "Requests", "icon": "inbox-stack", "module": "core" },
      { "key": "employees", "label": "Employees", "icon": "identification", "module": "core" },
      { "key": "attendance", "label": "Attendance", "icon": "finger-print", "module": "attendance" },
      { "key": "schedule", "label": "Schedule", "icon": "calendar-days", "module": "attendance" },
      { "key": "leave", "label": "Leave", "icon": "sun", "module": "leave" },
      { "key": "payslips", "label": "My payslips", "icon": "document-text", "module": "payroll" },
      { "key": "money", "label": "Loans and expenses", "icon": "wallet", "module": "loans_expenses" },
      { "key": "performance", "label": "Performance", "icon": "star", "module": "performance" },
      { "key": "documents", "label": "Documents and letters", "icon": "folder", "module": "documents" },
      { "key": "news", "label": "News and events", "icon": "megaphone", "module": "documents" },
      { "key": "tasks", "label": "Tasks", "icon": "check-circle", "module": "onboarding" },
      { "key": "assets", "label": "Assets", "icon": "computer-desktop", "module": "onboarding" },
      { "key": "training", "label": "Training", "icon": "academic-cap", "module": "onboarding" },
      { "key": "helpdesk", "label": "HR helpdesk", "icon": "chat-bubble-left-right", "module": "onboarding" },
      { "key": "support", "label": "Support", "icon": "lifebuoy", "module": "core" }
    ],
    "badges": { "requests": 2, "documents": 1 }
  }
}
```

### 4.2 Permission Scopes & Evaluation Logic
Permissions follow a mathematical scope superset hierarchy:
$$\text{Whole company (company)} \supset \text{Assigned locations (location)} \supset \text{Own department (department)} \supset \text{Own records (own)}$$

* If an employee has `["company"]` scope for `employees.view`, checking `AppPreferences.hasPermission('employees.view', 'department')` evaluates to `true`.
* **Binary Permissions (`Type A`):** Key with `null` value grants permission (e.g. `"support.raise": null`, `"kiosks.manage": null`). A missing key denies access.

### 4.3 Dynamic Menu & Drawer Rendering
`SessionMeController` maintains reactive observables for `menu`, `badges`, and `permissions`. The app drawer and navigation bars iterate over `data.menu` in exact server order. If a module is inactive or a menu item is omitted by the server, the card automatically disappears from the client.

---

# 5. Universal Screen Directory, Navigation & Route Registry

All 37 registered application routes are mapped in `lib/app/routes/app_routes.dart` and instantiated in `lib/app/routes/app_pages.dart`.

```
lib/app/screens/
├── approvals/            # Unified Manager & Employee Approvals Inbox
├── assets/               # Company Hardware & Software Assets Catalog
├── attendance_actions/   # Manual Punches & Geofence Break Tracking
├── attendance_history/   # Monthly Worked Hours & Punch Audit Logs
├── attendance_summary/   # Year-to-Date Attendance Summary Metrics
├── auth/                 # Credentials Login, 2FA & Password Reset
├── checklists/           # Onboarding & Offboarding Task Checklists
├── correction/           # Missed Punch Correction Submissions
├── dashboard/            # Executive Ambient Dashboard & Quick Services
├── documents/            # Personal Contracts, Right to Work & Policies
├── edit_profile/         # Personal Details Change Request Form
├── employee_card/        # Digital 3D Flip RFID Badge & Official PDF
├── employees/            # Team & Company Directory
├── evaluation/           # Performance Reviews, Goals & Peer Feedback
├── helpdesk/             # Real-Time HR & IT Ticket Service Desk
├── index/                # Main Shell Container with Bottom Navigation
├── job_description/      # Employee Role Overview & Key Duties
├── kiosk/                # Enterprise Kiosk Station & Backup PIN Hub
├── leaves/               # Annual Quota, Sandwich Calculations & Requests
├── loans/                # Emergency Loans & Expense Reimbursements
├── main_shell/           # Drawer, Top Bar & Persistent Session Controller
├── news/                 # Pinned Announcements & Milestone Celebrations
├── notifications/        # Push Notifications Inbox & Channel Preferences
├── payroll/              # Monthly Itemized Payslips & PDF Exporter
├── profile/              # Employee Profile Overview & Biometrics
├── schedule/             # 7-Day Shift Duty Rotas & Public Holidays
├── splash/               # Animated Bootloader & Session Hydration Gate
├── support_tickets/      # App Technical Support & Video Guides
├── tasks/                # Personal & Delegated Todo Task Board
├── training/             # Mandatory LMS Courses & Video Player
└── verification/         # Biometric Facial Recognition & QR Scanner
```

---

### 5.1 Splash & Authentication Hub

#### `Routes.SPLASH` (`/splash`)
* **Files:** `SplashView`, `SplashController`
* **Flow:** Boots the app, triggers device biometric hardware checks, verifies local auth token in `AppPreferences`.
* **Transition:** If token is present, initiates `GET /me` hydration and navigates to `Routes.INDEX`. If absent or unauthenticated, routes to `Routes.LOGIN`.

#### `Routes.LOGIN` (`/login`)
* **Files:** `LoginView`, `AuthController`, `AuthRepo`, `AuthModel`
* **APIs:** `POST /api/v1/auth/login`
* **Features:** Dual-mode sign in:
  1. **By Email:** Email + Password.
  2. **By Employee Number:** Emp No + Company Code (6 alphanumeric chars) + Password.
  3. Sends `device_name` (e.g., "Pixel 8 – Android 15").
* **2FA Challenge:** If `data.two_factor_required == true`, displays interactive 6-digit authenticator challenge modal (`POST /api/v1/auth/two-factor`).

#### `Routes.FORGOT_PASSWORD` (`/forgot-password`)
* **Files:** `ForgotPasswordView`, `AuthController`, `AuthRepo`
* **APIs:** `POST /api/v1/auth/forgot-password`
* **Behavior:** Submits email. Backend returns generic success response to prevent account enumeration. Password reset link is processed via browser.

---

### 5.2 Main Shell & Adaptive Dashboard

#### `Routes.INDEX` (`/index`)
* **Files:** `IndexView`, `IndexController`, `AppDrawer`, `SessionMeController`
* **APIs:** `GET /api/v1/me`
* **Architecture:** Persistent shell housing the bottom navigation bar and sliding `AppDrawer`. Manages bottom tab navigation between Dashboard, Attendance, Directory, and Profile.

#### `Routes.DASHBOARD` (`/dashboard`)
* **Files:** `DashboardView`, `DashboardController`, `DashboardRepo`
* **APIs:** `GET /api/v1/me/attendance/today`, `GET /api/v1/me/attendance/summary`
* **Components:**
  * `LiveShiftClockCard`: Real-time pulsing second ticker displaying current shift status, time elapsed, and punch action buttons.
  * `DashboardQuickActions`: Quick navigation shortcuts to Leave, Correction, Payslips, and ID Card.
  * `TodayStatsGrid`: 4-card metric strip (Total Hours, Clock In Time, Overtime, Break Time).
  * `RecentActivityTimeline`: Linear chronological audit trail of today's punch actions.

---

### 5.3 Attendance Actions, Biometrics & Geofencing

#### `Routes.ATTENDANCE_ACTIONS` (`/attendance-actions`)
* **Files:** `AttendanceActionsView`, `AttendanceHistoryController`, `AttendanceHistoryRepo`
* **APIs:** `POST /api/v1/me/attendance/punches`
* **Features:** Allows logging `in`, `out`, `break_start`, and `break_end`.
* **Geofencing & Biometrics Guard:** Obtains GPS position via `LocationService` (checks mock location and accuracy). Captures photo and computes FaceNet embeddings before transmitting punch payload.

#### `Routes.ATTENDANCE_HISTORY` (`/attendance-history`)
* **Files:** `AttendanceHistoryView`, `AttendanceHistoryController`, `AttendanceHistoryRepo`
* **APIs:** `GET /api/v1/me/attendance?from=YYYY-MM-DD&to=YYYY-MM-DD`, `GET /api/v1/employees/{id}/attendance`
* **Features:** Monthly calendar picker, daily working hours, late arrivals, overtime breakdown, and punch audit list.

#### `Routes.ATTENDANCE_SUMMARY` (`/attendance-summary`)
* **Files:** `AttendanceSummaryView`, `AttendanceSummaryController`, `AttendanceSummaryRepo`
* **APIs:** `GET /api/v1/me/attendance/summary`
* **Features:** Year-to-date total days present, absent, leaves taken, overtime hours, and average working hours.

#### `Routes.CORRECTION` (`/correction`)
* **Files:** `CorrectionView`, `CorrectionController`, `CorrectionRepo`
* **APIs:** `POST /api/v1/me/attendance/corrections`
* **Features:** Form to request missed punch entry or void erroneous punch with reason. Routes directly to `/approvals` inbox.

#### `Routes.QR_SCANNER` & `Routes.FACE_RECOGNITION`
* **Files:** `QrScannerView`, `FaceRecognitionView`, `FaceRecognitionController`, `FaceNetService`
* **APIs:** `GET /api/v1/me/face`
* **Features:** Camera viewfinder with oval biometric overlay. Runs local TensorFlow Lite FaceNet model to compare live facial embedding vector against enrolled server template with cosine similarity scoring.

---

### 5.4 Enterprise Kiosk Terminal & Backup PIN

#### `Routes.KIOSK` (`/kiosk`)
* **Files:** `KioskView`, `KioskController`, `KioskRepo`, `KioskModel`
* **APIs:**
  * `PUT /api/v1/me/kiosk-pin`
  * `POST /api/v1/kiosks`
  * `GET /api/v1/kiosk`
  * `POST /api/v1/kiosk/identify`
  * `GET /api/v1/kiosk/face?ticket=...`
  * `POST /api/v1/kiosk/punches`
* **Architecture:**
  * **Tab 1: Self-Service PIN (`KioskPinCard`):** Available to all employees. Sets 4 to 6 digit fallback PIN. Enforces client-side validation banning sequential (`1234`) and identical (`1111`) numbers.
  * **Tab 2: Tablet Terminal Provisioning (`KioskProvisionCard`):** Governed by `kiosks.manage` permission. Allows configuring tablet station name, location, and activating `kiosk_token`.
  * **Clock-In Modal (`KioskClockInDialog`):** Full tablet terminal punch flow supporting badge QR scan or Employee Number + PIN fallback, face template matching, and live or queued offline punch submission.

---

### 5.5 Employee Directory & Digital ID Card

#### `Routes.EMPLOYEES` (`/employees`)
* **Files:** `EmployeesView`, `DepartmentEmployeesController`, `DepartmentEmployeesRepo`
* **APIs:** `GET /api/v1/employees`, `GET /api/v1/employees/{id}`, `GET /api/v1/employees/export`
* **Permission Scopes:**
  * `own`: Displays personal profile card only.
  * `department`: Displays managed department team members.
  * `company`: Displays complete organization staff directory with department filtering and Excel export (`employees.export`).

#### `Routes.EMPLOYEE_CARD` (`/employee-card`)
* **Files:** `EmployeeCardView`, `EmployeeCardController`, `EmployeeCardRepo`, `CardPdfGenerator`
* **APIs:** `GET /api/v1/me/card`, `GET /api/v1/employees/{id}/card`
* **Features:** Interactive 3D flip card rendering digital badge with live dynamic rotating QR code, employee photo, department, and direct high-resolution PDF download.

---

### 5.6 Unified Requests & Approvals Governance Inbox

#### `Routes.APPROVALS` (`/approvals`)
* **Files:** `ApprovalsInboxView`, `ApprovalController`, `ApprovalRepo`, `ApprovalModel`
* **APIs:**
  * `GET /api/v1/approvals?box=waiting|pending|mine|decided`
  * `POST /api/v1/approvals/{id}/approve`
  * `POST /api/v1/approvals/{id}/reject`
  * `POST /api/v1/approvals/{id}/cancel`
* **Architecture:** Single universal inbox for 5 request categories (Details Change, Leave, Attendance Corrections, Overtime, Loans).
* **4 Operational Boxes:**
  * `waiting`: Requests requiring my decision.
  * `pending`: Requests awaiting upper HR approval.
  * `mine`: Requests submitted by me.
  * `decided`: Concluded approved/rejected requests.
* **HR Override:** Users holding `approvals.override` permission receive `can.as_override: true` to bypass approval chains.

---

### 5.7 Leave Management System

#### `Routes.LEAVE` (`/leave`)
* **Files:** `LeaveManagementView`, `LeaveController`, `LeaveRepo`, `LeaveModel`
* **APIs:**
  * `GET /api/v1/leave/types`
  * `GET /api/v1/me/leave/balances?on=YYYY-MM-DD`
  * `GET /api/v1/me/leave/requests`
  * `POST /api/v1/me/leave/requests/preview`
  * `POST /api/v1/me/leave/requests`
  * `POST /api/v1/me/leave/requests/{id}/cancel`
  * `GET /api/v1/leave/whos-off?from=YYYY-MM-DD&to=YYYY-MM-DD`
* **Features:**
  * Visual leave balance rings (Annual, Casual, Sick).
  * Real-time leave request preview modal computing sandwich weekends and paid vs unpaid deductions.
  * "Who's Off" calendar showing company/department absences.

---

### 5.8 Payroll & Itemized Payslips

#### `Routes.PAYROLL` (`/payroll`)
* **Files:** `PayrollView`, `PayrollController`, `PayrollRepo`, `PayrollModel`
* **APIs:**
  * `GET /api/v1/me/payslips`
  * `GET /api/v1/me/payslips/{id}`
  * `GET /api/v1/me/payslips/{id}/pdf`
  * `GET /api/v1/me/salary`
* **Features:** Monthly payslip history, itemized basic pay, allowances, tax deductions, net payout, and integrated PDF invoice viewer and downloader.

---

### 5.9 Loans, Advances & Expense Claims

#### `Routes.LOANS` (`/loans`)
* **Files:** `MoneyRequestsView`, `MoneyRequestController`, `MoneyRequestRepo`, `MoneyRequestModel`
* **APIs:**
  * `GET /api/v1/me/money-request-types`
  * `POST /api/v1/me/money-requests`
  * `GET /api/v1/me/money-requests`
  * `GET /api/v1/me/money-requests/{id}`
  * `POST /api/v1/me/money-requests/{id}/cancel`
* **Features:** Salary advance requests, emergency personal loans with customizable repayment installment calculators, expense reimbursement receipts upload, and live repayment schedule tracker.

---

### 5.10 Shift Schedules, Rotas & Holidays

#### `Routes.SCHEDULE` (`/schedule`)
* **Files:** `ScheduleView`, `ScheduleController`, `ScheduleRepo`, `ScheduleModel`
* **APIs:**
  * `GET /api/v1/me/schedule?from=YYYY-MM-DD&to=YYYY-MM-DD`
  * `GET /api/v1/employees/{id}/schedule`
  * `GET /api/v1/holidays`
* **Features:** 7-day horizontal calendar bar showing working shifts, break timings, off-days, and national public holidays with countdown badges.

---

### 5.11 Performance Reviews, Goals & Peer Nominations

#### `Routes.EVALUATION` & `Routes.EVALUATION_DETAILS`
* **Files:** `EvaluationView`, `EvaluationDetailsView`, `EvaluationController`, `EvaluationRepo`
* **APIs:**
  * `GET /api/v1/performance/reviews?box=mine|to_review`
  * `GET /api/v1/performance/reviews/{id}`
  * `PUT /api/v1/performance/reviews/{id}/answers`
  * `POST /api/v1/performance/reviews/{id}/submit`
  * `PUT /api/v1/performance/reviews/{id}/goals`
  * `POST /api/v1/performance/reviews/{id}/peers`
  * `POST /api/v1/performance/reviews/{id}/acknowledge`
* **Features:** Employee self-evaluation questionnaires, manager scoring rubric, KPI goal alignment, peer reviewer nominations, and final employee acknowledgment sign-off.

---

### 5.12 Documents, Policies, Letters & Corporate News

#### `Routes.DOCUMENTS` & `Routes.POLICY_DETAILS`
* **Files:** `DocumentsView`, `PolicyDetailsView`, `DocumentController`, `DocumentRepo`
* **APIs:**
  * `GET /api/v1/me/documents`
  * `GET /api/v1/me/documents/files/{id}`
  * `GET /api/v1/company-documents`
  * `GET /api/v1/company-documents/{id}`
  * `POST /api/v1/company-documents/{id}/acknowledge`
  * `POST /api/v1/me/letter-requests`
* **Features:** ID card and passport expiry alerts, official company handbooks with mandatory policy acknowledgment, and formal letter requests (Bonafide, Visa Recommendation, Salary Certificate).

#### `Routes.NEWS` & `Routes.ANNOUNCEMENT_DETAILS`
* **Files:** `NewsView`, `AnnouncementDetailsView`, `NewsController`, `NewsRepo`
* **APIs:**
  * `GET /api/v1/announcements`
  * `GET /api/v1/announcements/{id}`
  * `GET /api/v1/events?from=YYYY-MM-DD&to=YYYY-MM-DD`
  * `GET /api/v1/people/milestones`
  * `PUT /api/v1/me/birthday-sharing`
* **Features:** Pinned CEO announcements, upcoming corporate events, colleague work anniversaries and birthdays with privacy opt-out toggle.

---

### 5.13 Enterprise Onboarding Suite (Assets, Training, Checklists, JD)

#### `Routes.ASSETS` (`/assets`)
* **Files:** `AssetsView`, `AssetController`, `AssetRepo`
* **APIs:** `GET /api/v1/me/assets`, `POST /api/v1/me/assets/{assignment}/acknowledge`
* **Features:** Inventory of assigned laptops, monitors, accessories, and software licenses with digital signature acknowledgment.

#### `Routes.TRAINING` (`/training`)
* **Files:** `TrainingView`, `TrainingController`, `TrainingRepo`
* **APIs:** `GET /api/v1/me/training`
* **Features:** Mandatory compliance courses, completion progress bars, due date indicators, and external video launcher.

#### `Routes.CHECKLISTS` (`/checklists`)
* **Files:** `ChecklistsView`, `ChecklistController`, `ChecklistRepo`
* **APIs:** `GET /api/v1/me/checklists`
* **Features:** Step-by-step interactive onboarding and exit offboarding checklists with completed item check-offs.

#### `Routes.JOB_DESCRIPTION` (`/job-description`)
* **Files:** `JobDescriptionView`, `JobDescriptionController`, `JobDescriptionRepo`
* **APIs:** `GET /api/v1/me/job-description`
* **Features:** Official position overview, reporting hierarchy line managers, key responsibilities, and required competencies.

---

### 5.14 Helpdesk & Technical Support Ticketing

#### `Routes.HELPDESK` & `Routes.HELPDESK_TICKET`
* **Files:** `HelpdeskView`, `HelpdeskTicketView`, `HelpdeskController`, `HelpdeskRepo`
* **APIs:**
  * `GET /api/v1/helpdesk/tickets`
  * `POST /api/v1/helpdesk/tickets`
  * `GET /api/v1/helpdesk/tickets/{id}`
  * `POST /api/v1/helpdesk/tickets/{id}/messages`
  * `POST /api/v1/helpdesk/tickets/{id}/close`
* **Features:** Category-based ticketing (HR, Payroll, IT Support), live real-time bidirectional chat messages with attachments, priority tags, and ticket closure.

#### `Routes.SUPPORT_TICKETS` (`/support-tickets`)
* **Files:** `SupportTicketsView`, `SupportTicketController`, `SupportTicketRepo`
* **APIs:** `GET /api/v1/support/training-videos`
* **Features:** App usage guide video library and direct bug reporting to development support.

---

### 5.15 In-App Notifications & Preference Channels

#### `Routes.NOTIFICATIONS` & `Routes.NOTIFICATION_PREFERENCES`
* **Files:** `NotificationsView`, `NotificationPreferencesView`, `NotificationController`, `NotificationRepo`
* **APIs:**
  * `GET /api/v1/notifications`
  * `POST /api/v1/notifications/{id}/read`
  * `POST /api/v1/notifications/read-all`
  * `GET /api/v1/me/notification-preferences`
  * `PUT /api/v1/me/notification-preferences`
  * `POST /api/v1/push-tokens`
  * `DELETE /api/v1/push-tokens`
* **Features:** Push notifications inbox with category tone badges. Granular opt-in/opt-out toggles for Email, SMS, and Push channels across 8 event categories (In-app bell channel is locked permanent).

---

### 5.16 Profile Management & Account Security

#### `Routes.PROFILE` & `Routes.PROFILE_DETAILS`
* **Files:** `ProfileView`, `ProfileDetailsView`, `ProfileController`, `ProfileRepo`
* **APIs:** `GET /api/v1/me/profile`, `POST /api/v1/auth/logout`
* **Components:**
  * `ProfileOverviewTab`: Job title, department, work email, phone, and quick shortcuts.
  * `ProfileAccountTab`: Kiosk backup PIN configuration sheet, biometric face re-enrollment, 2FA status, and session sign-out.

#### `Routes.EDIT_PROFILE` (`/edit-profile`)
* **Files:** `EditProfileView`, `EditProfileController`, `EditProfileRepo`
* **APIs:** `POST /api/v1/me/details-change`
* **Features:** Submits formal personal information change requests (Name, Phone, Emergency Contacts, Residential Address, Bank Account details) with supporting document attachments. Automatically routes to `/approvals` inbox.

---

# 6. Master API Endpoints Integration Matrix

| # | HTTP Method | Endpoint Path | Feature / Screen | Repository Call |
|:---:|:---:|:---|:---|:---|
| 1 | `POST` | `/auth/login` | Login | `AuthRepo.login()` |
| 2 | `POST` | `/auth/two-factor` | 2FA Challenge | `AuthRepo.verifyTwoFactor()` |
| 3 | `POST` | `/auth/forgot-password` | Password Recovery | `AuthRepo.forgotPassword()` |
| 4 | `POST` | `/auth/logout` | Session Logout | `AuthRepo.logout()` / `ProfileRepo.logout()` |
| 5 | `GET` | `/me` | Identity & Permissions | `IndexRepo.fetchMe()` |
| 6 | `GET` | `/me/profile` | Profile Details | `ProfileRepo.fetchProfile()` |
| 7 | `POST` | `/me/details-change` | Profile Change Request | `EditProfileRepo.submitDetailsChange()` |
| 8 | `GET` | `/me/card` | Personal Digital ID Card | `EmployeeCardRepo.fetchCardDetails()` |
| 9 | `GET` | `/employees` | Staff Directory | `DepartmentEmployeesRepo.fetchStaff()` |
| 10 | `GET` | `/employees/{id}` | Staff Profile View | `DepartmentEmployeesRepo.fetchEmployeeDetails()` |
| 11 | `GET` | `/employees/{id}/card` | Staff ID Card | `EmployeeCardRepo.fetchEmployeeCard()` |
| 12 | `GET` | `/employees/{id}/attendance`| Staff Attendance | `DepartmentEmployeesRepo.fetchEmployeeAttendance()` |
| 13 | `GET` | `/employees/{id}/schedule` | Staff Schedule | `DepartmentEmployeesRepo.fetchEmployeeSchedule()` |
| 14 | `GET` | `/employees/{id}/leave` | Staff Leave History | `DepartmentEmployeesRepo.fetchEmployeeLeave()` |
| 15 | `GET` | `/approvals` | Requests Inbox | `ApprovalRepo.fetchApprovals()` |
| 16 | `GET` | `/approvals/{id}` | Request Details | `ApprovalRepo.fetchApprovalDetails()` |
| 17 | `POST` | `/approvals/{id}/approve` | Approve Request | `ApprovalRepo.approveRequest()` |
| 18 | `POST` | `/approvals/{id}/reject` | Reject Request | `ApprovalRepo.rejectRequest()` |
| 19 | `POST` | `/approvals/{id}/cancel` | Cancel Request | `ApprovalRepo.cancelRequest()` |
| 20 | `GET` | `/notifications` | Notifications Inbox | `NotificationRepo.fetchNotifications()` |
| 21 | `POST` | `/notifications/{id}/read` | Mark Read | `NotificationRepo.markAsRead()` |
| 22 | `POST` | `/notifications/read-all`| Mark All Read | `NotificationRepo.markAllAsRead()` |
| 23 | `GET` | `/me/notification-preferences` | Channel Settings | `NotificationRepo.fetchPreferences()` |
| 24 | `PUT` | `/me/notification-preferences` | Update Preferences | `NotificationRepo.updatePreferences()` |
| 25 | `POST` | `/push-tokens` | Register FCM Token | `NotificationRepo.registerPushToken()` |
| 26 | `DELETE`| `/push-tokens` | Delete FCM Token | `NotificationRepo.deletePushToken()` |
| 27 | `GET` | `/me/schedule` | My Schedule | `ScheduleRepo.fetchSchedule()` |
| 28 | `GET` | `/holidays` | Company Holidays | `ScheduleRepo.fetchHolidays()` |
| 29 | `GET` | `/me/attendance/today` | Today's Dashboard Shift | `DashboardRepo.fetchTodayAttendance()` |
| 30 | `GET` | `/me/attendance` | Monthly Attendance Logs| `AttendanceHistoryRepo.fetchHistory()` |
| 31 | `GET` | `/me/attendance/summary` | Attendance Statistics | `AttendanceSummaryRepo.fetchSummary()` |
| 32 | `POST` | `/me/attendance/punches` | Geofenced Mobile Punch | `AttendanceHistoryRepo.submitPunch()` |
| 33 | `POST` | `/me/attendance/corrections` | Missed Punch Request | `CorrectionRepo.submitCorrection()` |
| 34 | `GET` | `/me/face` | Biometric Face Template| `FaceRecognitionRepo.fetchEnrolledFace()` |
| 35 | `PUT` | `/me/kiosk-pin` | Self-Service Kiosk PIN | `KioskRepo.setKioskPin()` |
| 36 | `POST` | `/kiosks` | Provision Tablet Kiosk | `KioskRepo.provisionKiosk()` |
| 37 | `GET` | `/kiosk` | Kiosk Config & State | `KioskRepo.fetchKioskConfig()` |
| 38 | `POST` | `/kiosk/identify` | QR/PIN Clock-in | `KioskRepo.identifyEmployee()` |
| 39 | `GET` | `/kiosk/face` | Kiosk Face Photo | `KioskRepo.fetchKioskFace()` |
| 40 | `POST` | `/kiosk/punches` | Kiosk Punch Log | `KioskRepo.submitKioskPunch()` |
| 41 | `GET` | `/support/training-videos`| App Video Guides | `SupportTicketRepo.fetchVideos()` |
| 42 | `GET` | `/leave/types` | Leave Quota Definitions| `LeaveRepo.fetchLeaveTypes()` |
| 43 | `GET` | `/me/leave/balances` | Leave Balances | `LeaveRepo.fetchBalances()` |
| 44 | `GET` | `/me/leave/requests` | Leave Request History | `LeaveRepo.fetchRequests()` |
| 45 | `POST` | `/me/leave/requests/preview`| Sandwich Preview | `LeaveRepo.previewLeave()` |
| 46 | `POST` | `/me/leave/requests` | Apply for Leave | `LeaveRepo.applyLeave()` |
| 47 | `POST` | `/me/leave/requests/{id}/cancel` | Cancel Leave | `LeaveRepo.cancelLeave()` |
| 48 | `GET` | `/leave/whos-off` | Who's Off Calendar | `LeaveRepo.fetchWhosOff()` |
| 49 | `GET` | `/me/payslips` | Payslips History | `PayrollRepo.fetchPayslips()` |
| 50 | `GET` | `/me/payslips/{id}` | Payslip Details | `PayrollRepo.fetchPayslipDetails()` |
| 51 | `GET` | `/me/payslips/{id}/pdf` | Download Payslip PDF | `PayrollRepo.fetchPayslipPdf()` |
| 52 | `GET` | `/me/salary` | Salary Formula Lines | `PayrollRepo.fetchSalaryStructure()` |
| 53 | `GET` | `/me/money-request-types` | Loan Categories | `MoneyRequestRepo.fetchTypes()` |
| 54 | `POST` | `/me/money-requests` | Apply Loan / Advance | `MoneyRequestRepo.submitRequest()` |
| 55 | `GET` | `/me/money-requests` | Active Money Requests | `MoneyRequestRepo.fetchRequests()` |
| 56 | `GET` | `/me/money-requests/{id}` | Loan Ledger Details | `MoneyRequestRepo.fetchRequestDetails()` |
| 57 | `POST` | `/me/money-requests/{id}/cancel` | Cancel Money Request | `MoneyRequestRepo.cancelRequest()` |
| 58 | `GET` | `/performance/reviews` | Performance Review List| `EvaluationRepo.fetchReviews()` |
| 59 | `GET` | `/performance/reviews/{id}` | Review Questionnaire | `EvaluationRepo.fetchReviewDetails()` |
| 60 | `PUT` | `/performance/reviews/{id}/answers` | Save Draft Answers | `EvaluationRepo.saveDraftAnswers()` |
| 61 | `POST` | `/performance/reviews/{id}/submit` | Finalize Review | `EvaluationRepo.submitReview()` |
| 62 | `PUT` | `/performance/reviews/{id}/goals` | Set Review Goals | `EvaluationRepo.updateGoals()` |
| 63 | `POST` | `/performance/reviews/{id}/peers` | Nominate Peer Reviewer | `EvaluationRepo.nominatePeer()` |
| 64 | `POST` | `/performance/reviews/{id}/acknowledge` | Final Sign-off | `EvaluationRepo.acknowledgeReview()` |
| 65 | `GET` | `/me/documents` | Personal Right to Work | `DocumentRepo.fetchPersonalDocuments()` |
| 66 | `GET` | `/me/documents/files/{id}` | Download Personal File | `DocumentRepo.fetchDocumentFile()` |
| 67 | `GET` | `/company-documents` | Company Policies List | `DocumentRepo.fetchCompanyDocuments()` |
| 68 | `GET` | `/company-documents/{id}` | Policy Text / File | `DocumentRepo.fetchCompanyDocumentDetails()` |
| 69 | `POST` | `/company-documents/{id}/acknowledge` | Sign Policy Doc | `DocumentRepo.acknowledgeDocument()` |
| 70 | `POST` | `/me/letter-requests` | Request Official Letter| `DocumentRepo.submitLetterRequest()` |
| 71 | `GET` | `/announcements` | Announcements Feed | `NewsRepo.fetchAnnouncements()` |
| 72 | `GET` | `/announcements/{id}` | Read Announcement Body | `NewsRepo.fetchAnnouncementDetails()` |
| 73 | `GET` | `/events` | Company Events Calendar| `NewsRepo.fetchEvents()` |
| 74 | `GET` | `/people/milestones` | Anniversaries/Birthdays | `NewsRepo.fetchMilestones()` |
| 75 | `PUT` | `/me/birthday-sharing` | Privacy Toggle | `NewsRepo.updateBirthdaySharing()` |
| 76 | `GET` | `/tasks` | Task Board Feed | `TaskRepo.fetchTasks()` |
| 77 | `POST` | `/tasks` | Create New Task | `TaskRepo.createTask()` |
| 78 | `GET` | `/tasks/{id}` | Task Thread Details | `TaskRepo.fetchTaskDetails()` |
| 79 | `POST` | `/tasks/{id}/complete` | Mark Task Complete | `TaskRepo.completeTask()` |
| 80 | `POST` | `/tasks/{id}/reopen` | Reopen Closed Task | `TaskRepo.reopenTask()` |
| 81 | `POST` | `/tasks/{id}/comments` | Add Task Comment | `TaskRepo.addComment()` |
| 82 | `GET` | `/me/checklists` | Onboarding Checklists | `ChecklistRepo.fetchChecklists()` |
| 83 | `GET` | `/me/assets` | Hardware/Asset Catalog | `AssetRepo.fetchAssets()` |
| 84 | `POST` | `/me/assets/{id}/acknowledge` | Sign Asset Handover | `AssetRepo.acknowledgeAsset()` |
| 85 | `GET` | `/me/training` | Training Courses List | `TrainingRepo.fetchCourses()` |
| 86 | `GET` | `/me/job-description` | Employee Role Profile | `JobDescriptionRepo.fetchJobDescription()` |
| 87 | `GET` | `/helpdesk/tickets` | Ticket Service Desk | `HelpdeskRepo.fetchTickets()` |
| 88 | `POST` | `/helpdesk/tickets` | Raise New Ticket | `HelpdeskRepo.createTicket()` |
| 89 | `GET` | `/helpdesk/tickets/{id}` | Ticket Chat Thread | `HelpdeskRepo.fetchTicketDetails()` |
| 90 | `POST` | `/helpdesk/tickets/{id}/messages` | Send Message & Files | `HelpdeskRepo.sendMessage()` |
| 91 | `POST` | `/helpdesk/tickets/{id}/close` | Resolve/Close Ticket | `HelpdeskRepo.closeTicket()` |

---

# 7. State Management, Storage Isolation & Lifecycle Protocols

### 7.1 Local Storage Architecture (`AppPreferences`)
Located at `lib/app/api/app_preferences.dart`. Powered by `GetStorage` with complete key isolation:
* **Authentication:** `token`, `user`, `companyName`, `companyCode`.
* **Kiosk State:** `kiosk_secret_token`, `kiosk_active_config`, `kiosk_pin_configured`.
* **Biometrics:** `enrolled_face_embedding`, `biometric_auth_enabled`.
* **Session Purge:** `AppPreferences.clearAuth()` purges all credentials and sensitive caches upon user logout or HTTP 401 unauthenticated session termination.

### 7.2 Controller Lifecycle & Zero-Memory Leak Protocol
Every GetX Controller in the application must strictly release allocated system resources in its `onClose()` lifecycle hook:
```dart
@override
void onClose() {
  textEditingController.dispose();
  focusNode.dispose();
  scrollController.dispose();
  animationController.dispose();
  timer?.cancel();
  streamSubscription?.cancel();
  super.onClose();
}
```

### 7.3 Route Instantiation
All routes are registered in `app_pages.dart` with `fenix: true`:
```dart
GetPage(
  name: Routes.FEATURE,
  page: () => const FeatureView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => FeatureRepo(), fenix: true);
    Get.lazyPut(() => FeatureController(repo: Get.find()), fenix: true);
  }),
)
```
* `fenix: true` releases controller memory when the route is popped from the navigation stack, but recreates a fresh instance whenever the user navigates back to it.

---

# 8. Developer Pre-Flight Verification Checklist

Whenever an agent or engineer adds or modifies code in AMS 2, they must verify the following 9 architectural checks:

- [ ] **1. Binding Check:** Is the binding declared inline using `BindingsBuilder` in `app_pages.dart` without creating separate `binding.dart` files?
- [ ] **2. Layer Check:** Does the View communicate exclusively with its Controller, and the Controller exclusively with its Repository?
- [ ] **3. Colors & Spacing Check:** Do all colors resolve from `AppColors`, and all dimensions/radiuses/fonts from `.w`, `.h`, `.sp`, `.r`?
- [ ] **4. Card Accent Check:** Does every floating card feature the signature `3.w` Modern Teal bottom border (`Border(bottom: BorderSide(color: AppColors.secondary, width: 3.w))`) and `12.w` inside horizontal padding?
- [ ] **5. Resource Disposal Check:** Are all `TextEditingController`, `FocusNode`, `ScrollController`, `AnimationController`, `Timer`, and `StreamSubscription` instances properly disposed in `onClose()`?
- [ ] **6. Mandatory Origin Tagging:** Does every Repository call and exception handler include the formatted origin tracer tag (`tag: 'FeatureRepo / FeatureScreen -> methodName()'`)?
- [ ] **7. Zero Dummy / Fallback Check:** Are live endpoints free of fake arrays, dummy counters, or artificial fallback data?
- [ ] **8. Centered Empty & Error State Check:** Are `CustomStateView.empty(...)` and `CustomStateView.error(...)` centered horizontally and vertically (`Center(child: ...)`)?
- [ ] **9. FormKey & Auto-Scroll Check:** Are user inputs validated via `GlobalKey<FormState>()`, and does the view automatically scroll to and focus the first invalid field upon error?

---
*Report compiled and verified against official specification `doc/api.md` and AMS 2 production code.*
