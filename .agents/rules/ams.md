---
trigger: always_on
---

AMS 2 — STRICT ARCHITECTURE & API INTEGRATION RULES FOR AI AGENTS

ROLE & BEHAVIOR: You are an expert Flutter & Backend Integration Engineer working on AMS 2 (Attendance Management System & Enterprise HR Suite) for Softech Business Services.

ZERO TOLERANCE: You MUST follow every rule below without deviation. Ad-hoc styling, layer-skipping, hardcoded values, or guessing IDs/APIs is strictly forbidden.

PART 1: FLUTTER ARCHITECTURAL INVARIANTS

1. Architectural Pattern & Layer Flow

Pattern: Strict MVVM with Repository Pattern powered by GetX.

Enforced Flow Policy: View -> Controller -> Repository -> ApiClient

View: Sirf Controller ke methods aur observables (Obx) ke sath interact karega. UI mein direct repository ya API client call karna strictly banned hai.

Controller: Sirf Feature Repository ko call karega. Controller ke andar direct ApiClient, raw HTTP calls, ya GetStorage/SharedPreferences calls strictly prohibited hain.

Repository: ApiClient.request() ko call karega, raw JSON envelope ko model mein deserialize karega, mandatory origin tracer tag pass karega, aur mapped model Controller ko return karega.

ApiClient: Central network engine (lib/app/api/api_client.dart) jo headers, auth tokens, timeouts, aur status codes handle karta hai.

2. Feature Folder Structure & Bindings

Har screen/feature ko is standard folder structure par hona lazmi hai:

lib/app/screens/[feature_name]/
├── model/         # Request & Response data models/entities (.fromJson / .toJson)
├── repo/          # Feature repository (API calls, origin tagging & parsing)
├── controller/    # GetX controller (business logic, observables & lifecycle)
├── view/          # Main UI view (wrapped in NetworkBoundaryWrapper)
└── components/    # Screen-specific widgets (sirf isi screen par use honge)


STRICT BINDING RULE: Do NOT create separate binding/ folders or *_binding.dart files.

Tamam routes aur dependency injection app_pages.dart mein inline BindingsBuilder ke zariye register hongi:

GetPage(
  name: Routes.FEATURE,
  page: () => const FeatureView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => FeatureRepo(), fenix: true);
    Get.lazyPut(() => FeatureController(repo: Get.find()), fenix: true);
  }),
)


3. Controller Lifecycle & Zero-Leak Policy

Mandatory Resource Disposal: Har GetX Controller jo resources allocate karta hai, use onClose() ke andar dispose karna lazmi hai:

TextEditingController.dispose()

FocusNode.dispose()

ScrollController.dispose()

AnimationController.dispose()

Cancel all StreamSubscription, Timer, and Worker instances.

Route Memory Release: Route bindings mein fenix: true use karein taake route pop hone par memory release ho aur dobara aane par clean recreate ho.

4. UI Invariants & Design System (Corporate Navy & Teal)

Centralized Colors Only (AppColors):

Primary Brand Navy: AppColors.primary (0xFF012B43)

Accent Modern Teal: AppColors.secondary (0xFF0DA6A3)

Lite Tints: AppColors.litePrimary (0xFF99BBD6), AppColors.liteSecondary (0xFFB4E3E4)

Intermediate Navy: AppColors.accentNavy (0xFF023E61)

Dynamic Theme Getters: AppColors.backgroundColor, AppColors.cardBackground, AppColors.textColor, AppColors.subTextColor, AppColors.borderColor, AppColors.error.

Banned: UI files mein const Color(0xFF...) ya Get.isDarkMode ? ... : ... ternaries likhna strictly banned hai.

Signature Floating Card Blueprint:

Har main container card par inside horizontal padding strictly 12.w (padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h)).

Border radius: 15.r.

Signature Bottom Border Accent:

border: Border(bottom: BorderSide(color: AppColors.secondary, width: 3.w))


Responsiveness: Har dimension, padding, radius aur font size ke liye flutter_screenutil (.w, .h, .sp, .r) use karein. Raw pixels strictly banned hain.

Buttons: Primary buttons hamesha CustomButton(isGradient: true) honge (Corporate Navy to Teal gradient).

Error & Empty States: Ad-hoc inline columns banaye bina centralized CustomStateView.error(...) aur CustomStateView.empty(...) use karein.

Root Screen Container: UI root ko NetworkBoundaryWrapper se wrap karein.

5. Asynchronous Loading & Double-Tap Prevention

Tamam await actions ko try-finally block mein wrap karna lazmi hai:

try {
  isLoading.value = true;
  await repo.doAction();
} finally {
  isLoading.value = false;
}


Jab isLoading.value == true ho, tamam interactive buttons disable hone chahiye taake duplicate API requests trigger na hon. Dialogs mein PopScope(canPop: !isLoading.value) lazmi ho.

PART 2: STRICT API & BACKEND INTEGRATION RULES

1. Current Phase Contract: UI Prototyping vs Live APIs

Prototyping Phase: Repositories local mock data return karengi with realistic async delay (300-600ms) bina real HTTP call ke.

Live Integration Phase: Niche diye gaye standard API contracts strictly follow honge.

2. The Golden Rule — The Server Decides Access

No Client-Side Roles: App mein kabhi bhi static role checks (if (role == 'admin')) na karein.

Dynamic Menu Construction: App Drawer aur Tabs strictly GET /me → data.menu ki list aur order se render honge.

Permission-Driven Action Controls: Screen ke andar buttons GET /me → data.permissions ke mutabiq show/hide honge:

Scopes: own (apna record), department (apne under department), location (workplace location), company (company-wide). Key na hone ka matlab "not allowed" hai.

Server-Filtered Listings: Tamam listing queries (/employees, /approvals) server se user ke permissions ke mutabiq pre-filtered aati hain.

3. API Standards & Headers

Base URL: https://laravel.ams-hrpayroll.com/api/v1

Standard Headers:

Authorization: Bearer <token> (Siwaye /auth/login, /auth/two-factor, aur /auth/forgot-password)

Accept: application/json (Har request par mandatory)

Content-Type: application/json (Ya file uploads ke liye multipart/form-data)

X-Device-Id: <UUID>, X-App-Version: 2.0.0, X-Client-Platform: android | ios

Centralized Endpoints: Direct URL string code mein likhna mana hai; tamam URLs ApiEndpoints class mein define honi chahiye.

Storage Isolation: Tokens aur user IDs sirf AppPreferences ke getters/setters se access honge. Direct GetStorage() widget/controller mein forbidden hai.

4. 26-Character Opaque ULIDs

Database IDs hamesha 26-character opaque strings hain (e.g., 01jb2x9k4m7q8r3t5v6w8y0z1a).

Banned: Kabhi bhi ID ko int.parse() na karein, na locally construct karein, aur na guess karein.

5. Error Invariant — "Code Over Message"

Frontend business decisions aur error handling hamesha error.code par mabni hogi, kabhi bhi human-readable message string ko parse na karein.

error.message user ko dialog/snackbar mein display karne ke liye safe hai.

error.code == "validation_failed" par error.fields se form fields ke neeche specific error render karein.

HTTP Code Handling:

200 / 201: Success with { "data": ... }.

204: Success with empty body.

401 unauthenticated / 403 account_unavailable: Foran AppPreferences.clearAuth() call karke user ko Routes.LOGIN par redirect karein.

429 too_many_requests: Retry-After header parh kar countdown display karein aur retry button disable karein.

6. Mandatory Origin Tagging

Direct print() ya unformatted debugPrint poore project mein strictly banned hai.

Tamam API calls aur catch blocks mein formatted Origin Tag pass karna lazmi hai:

tag: 'FeatureRepo / FeatureScreen -> methodName()'


7. Universal Requests & Approvals Inbox (/approvals)

Tamam employee requests (details change, leave, attendance corrections, overtime, loans) single endpoint /approvals par aati hain.

4 Standard Boxes:

waiting: Mere faislay ka intezar hai.

pending: HR level par waiting (sirf HR rights walon ke liye).

mine: Meri submit ki hui requests.

decided: Jo requests approve ya reject ho chuki hain.

Status Tones: Server se aane wale status_tone ko UI status chips se map karein:

amber (Pending / Waiting)

emerald (Approved)

rose (Rejected)

slate (Cancelled)

8. Client-Side Input Sanitization Whitelist

Server validation ke sath sath input fields par client-side character restrictions lazmi hon:

Phone: Digits, spaces, +, (, ), - (Max 20 chars).

Names: Letters, spaces, ', ., - (Max 80 chars).

Postcodes: Letters, digits, space, - (Max 12 chars).

Comments/Notes: Plain text (Max 1000 chars).

PART 3: AGENT PRE-FLIGHT VERIFICATION CHECKLIST

Jab bhi Agent koi naya code generate ya modify kare, wo in 6 checks ko verify karega:

[ ] Binding Check: Kya binding inline BindingsBuilder mein hai bina kisi alag binding.dart file ke?

[ ] Layer Check: Kya UI sirf Controller ko, aur Controller sirf Repository ko call kar raha hai?

[ ] Colors & Spacing Check: Kya tamam colors AppColors se aur sizes .w, .h, .sp, .r se hain?

[ ] Card Accent Check: Kya floating card par 3.w Modern Teal bottom border aur 12.w inside padding mojood hai?

[ ] Disposal Check: Kya controller ke tamam TextEditingController aur FocusNode onClose() mein dispose ho rahe hain?

[ ] API Tagging Check: Kya Repository call mein mandatory tag: '... -> ...' pass hua hai?