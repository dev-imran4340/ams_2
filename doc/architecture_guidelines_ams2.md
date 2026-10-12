# SoftGenie Architecture & Development Guidelines

This document outlines the strict rules, architectural patterns, and development flow for the SoftGenie Flutter project. **These rules must be followed for every new feature, screen, component, and API integration.**

---

## 1. Architectural Pattern
- **Pattern:** MVVM (Model-View-ViewModel) combined with the Repository Pattern.
- **State Management & DI:** Strictly GetX.
- **Strict Layer Flow Policy:** `View -> Controller -> Repository -> ApiClient`
  * **View:** Sirf controller ke methods aur observables (`Obx`) ke sath interact karega.
  * **Controller:** Sirf Feature Repository ko call karega. Controller ke andar direct `ApiClient`, raw HTTP calls, ya direct local storage calls strictly forbidden hain.
  * **Repository:** ApiClient ko call karke raw JSON ko model mein parse karega, error origin tags pass karega, aur mapped model controller ko return karega.
  * **ApiClient:** Generalized network client (`lib/app/api/api_client.dart`) jo headers, tokens, timeouts, pre-flight internet check, logging, aur status code routing handle karta hai.

---

## 2. Screen Creation Flow & Folder Structure
Whenever a new screen/feature is created, you must strictly follow this folder structure:

```text
lib/app/screens/
└── [feature_name]/
    ├── model/         # Request & Response data models/entities
    ├── repo/          # Feature repository (API calls, origin tagging & parsing)
    ├── controller/    # GetX controller (business logic, observables & lifecycle)
    ├── view/          # Main UI view (GetView / Obx, wrapped in NetworkBoundaryWrapper)
    └── components/    # Screen-specific widgets (sirf isi screen par use honge)
```

- **STRICT RULE ON BINDINGS:** Do **NOT** create any separate `binding/` folders or `*_binding.dart` files.
- **Routing & Dependency Injection:** All bindings and DI must be registered **inline** using `BindingsBuilder` inside `app_pages.dart`:
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

---

## 3. Strict API & Network Integration Standard

### 3.1 Network Layer Organization (`lib/app/api/`)
```text
lib/app/api/
├── api_client.dart          # Core network engine (Standard HTTP & Multipart uploads)
├── api_endpoints.dart       # Tamam API URLs aur static path definitions
├── app_preferences.dart     # Dedicated local storage (Token, User ID, GetStorage)
└── exception_handler.dart   # Unified error routing, origin tracer aur status codes
```

### 3.2 Invariant Rules for Every Screen API Integration
1. **Endpoints Centralization (`api_endpoints.dart`):**
   - Poore project mein kisi bhi file mein direct string URL (`'https://...'` ya `'/auth/login'`) use karna strictly banned hai.
   - Har endpoint pehle `ApiEndpoints` mein constant ya static method ke tor par define hona chahiye.
2. **Storage Isolation (`app_preferences.dart`):**
   - UI widgets ya controllers mein `SharedPreferences` ya `GetStorage` ka direct reference strictly prohibited hai.
   - Auth tokens, refresh tokens, user IDs, aur local settings sirf `AppPreferences` ke getters/setters ke zariye access hongi.
3. **Mandatory Origin Tagging & Logging Rule:**
   - Direct `print()`, unformatted `debugPrint`, ya raw loggers strictly banned hain.
   - Tamam debug logging sirf `kDebugMode` ke andar `Get.log` aur `ExceptionHandler.handle` ke zariye hogi.
   - Har Repository mein exception aane par ya invalid response aane par **origin tag** pass karna mandatory hai:
     ```dart
     tag: 'FeatureRepo / FeatureScreen -> methodName()'
     ```
   - Terminal par formatted trace print hota hai:
     ```text
     🚨 ==================== [EXCEPTION TRACER] ====================
     📍 ORIGIN / SCREEN : FeatureRepo / FeatureScreen -> methodName()
     ⬅️ STATUS CODE    : 400
     🏷️ ERROR CODE     : INVALID_REQUEST
     ❌ ERROR DETAILS   : Validation failed
     ==============================================================
     ```
4. **Status Code & Payload Contract:**
   - Sirf HTTP status code **200 aur 201** valid responses hain jo JSON decode ho kar return honge.
   - Tamam other status codes (400, 401, 403, 404, 422, 500+) `ApiClient` se `ExceptionHandler` mein route hokar handle honge.
   - Agar status 200 par server HTML code (e.g. Cloudflare error, redirect) bhejta hai, toh `ApiClient` use turant block karega.
5. **Network Boundary Handling:**
   - Har screen ka UI root `NetworkBoundaryWrapper` widget se wrap hona zaroori hai. Internet disconnect hone par screen par centralized error view aur auto-recovery provide karta hai.

---

## 4. Reference Implementation (Standard Blueprint)

### Example 1: Feature Model (`screens/feature/model/feature_model.dart`)
```dart
class FeatureResponseModel {
  final String? id;
  final String? title;

  FeatureResponseModel({this.id, this.title});

  factory FeatureResponseModel.fromJson(Map<String, dynamic> json) {
    return FeatureResponseModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
    );
  }
}
```

### Example 2: Feature Repository (`screens/feature/repo/feature_repo.dart`)
```dart
import '../../../api/api_client.dart';
import '../../../api/api_endpoints.dart';
import '../../../api/exception_handler.dart';
import '../model/feature_model.dart';

class FeatureRepo {
  final String _tag = 'FeatureRepo / FeatureScreen';

  Future<LoginResponseModel?> feature(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.request(
        method: HttpMethod.post,
        endpoint: ApiEndpoints.login,
        body: body,
        tag: '$_tag -> feature()',
      );

      // Verify valid response
      if (response == null || response is! Map<String, dynamic>) {
        ExceptionHandler.handle(
          ApiException(message: 'Invalid response format received.'),
          tag: '$_tag -> feature()',
        );
        return null;
      }

      // Safe envelope extraction
      final jsonPayload = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;

      return LoginResponseModel.fromJson(jsonPayload);
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Model mapping failed: $e'),
        tag: '$_tag -> feature() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}

```

### Example 3: Feature Controller (`screens/feature/controller/feature_controller.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/app_preferences.dart';
import '../model/feature_model.dart';
import '../repo/feature_repo.dart';

class FeatureController extends GetxController {
  final FeatureRepo repo;
  FeatureController({required this.repo});

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  final RxBool isLoading = false.obs;
  final Rxn<FeatureResponseModel> featureData = Rxn<FeatureResponseModel>();

  @override
  void onInit() {
    super.onInit();
    loadFeatureData();
  }

  Future<void> loadFeatureData() async {
    try {
      isLoading.value = true;
      final body = {
        "email": "[EMAIL_ADDRESS]",
        "password": "[PASSWORD]",
      };
      final result = await repo.feature(body);
      if (result != null) {
        featureData.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    textFocusNode.dispose();
    super.onClose();
  }
}
```

### Example 4: Feature View (`screens/feature/view/feature_view.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/feature_controller.dart';

class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadFeatureData,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.featureData.value == null) {
              return CustomStateView.empty(
                title: 'No Data',
                message: 'No data available for this feature.',
                buttonText: 'Retry',
                onAction: controller.loadFeatureData,
              );
            }

            return Padding(
              padding: AppSpaces.defaultPadding,
              child: Column(
                children: [
                  // Feature content
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
```

---

## 5. Theming, Colors & Dark Mode (Strict Policy)
- **Centralized `AppColors` ONLY:** All colors **MUST** strictly come from the dynamic getters in `AppColors` (e.g., `AppColors.backgroundColor`, `AppColors.cardBackground`, `AppColors.textColor`, `AppColors.subTextColor`, `AppColors.borderColor`, `AppColors.primary`, `AppColors.litePrimary`, `AppColors.secondary`, `AppColors.success`, `AppColors.error`).
- **NO Inline Theme Checks:** Do **NOT** write `Get.isDarkMode ? colorA : colorB` or `Theme.of(context)` ternaries inside UI widgets. The dark/light mode switching logic is already encapsulated inside `AppColors`.
- **NO Hardcoded Hex Colors:** Never hardcode raw hex values (`const Color(0xFF...)`) inside widget files or models. If a new semantic color is required, define it inside `AppColors`.

---

## 6. Responsiveness & Spacing
- **ScreenUtil Extensions:** Always use `flutter_screenutil` extensions (`.w`, `.h`, `.sp`, `.r`) for all dimensions, paddings, margins, border radii, and font sizes. Never use hardcoded pixel values.
- **Spacing & Typography:** Always reuse `AppSpaces` (`AppSpaces.vSpace16`, `AppSpaces.hSpace8`, etc.) and `AppTextStyles` (`AppTextStyles.text14`, `AppTextStyles.text18`, etc.).

---

## 7. Widget Placement & Reusability Rules
- **Global / Shared Reusable Widgets (`lib/app/core/widgets/`):**
  - Any widget that can be used across multiple screens (`CustomAppBar`, `CustomCard`, `CustomBadge`, `CustomProgressBar`, `CustomButton`, `CustomTextField`, `CustomSnackbar`, `CustomStateView`, `NetworkBoundaryWrapper`) **MUST** be placed in `lib/app/core/widgets/`.
- **Screen-Specific Widgets (`lib/app/screens/[feature]/view/components/`):**
  - Widgets that are exclusively used on a single screen **MUST** be placed inside that screen's `view/components/` directory.
- **Main View File (`[feature]_view.dart`):**
  - Should remain clean and focused on assembling the layout and connecting controller actions.

---

## 8. Controller Lifecycle, Memory Management & Leak Prevention
- **Resource Disposal in `onClose()`:**
  - Every GetX controller that allocates memory resources **MUST** override `onClose()` and dispose them properly:
    - `TextEditingController.dispose()`
    - `ScrollController.dispose()`
    - `FocusNode.dispose()`
    - `AnimationController.dispose()`
    - Cancel all active `StreamSubscription`, `Timer`, and debounce workers (`Worker.dispose()`).
- **Memory Release on Screen Pop / Exit:**
  - In `app_pages.dart`, use `Get.lazyPut(() => MyController(), fenix: true)` so that the controller is automatically disposed when its route is popped and cleanly recreated when the user revisits the screen.
- **No Unbounded Retained References:**
  - Never store static references to `BuildContext`, controllers, or large widget trees that prevent garbage collection.
- **Production Performance:**
  - Maintain 60/120 FPS by avoiding unnecessary `Obx` wrappers around static trees.

---

## 9. Unified Error & Empty State Handling (`CustomStateView`)
- **Centralized Empty & Error Views:**
  - Whenever a screen or list fails to load, encounters an API/network error, or has no data to display, **never write ad-hoc inline columns with hardcoded retry buttons or error text**.
  - Always use the centralized `CustomStateView` widget (`lib/app/core/widgets/custom_state_view.dart`):
    - **For Errors:** `CustomStateView.error(message: '...', onRetry: controller.fetchData)`
    - **For Empty States:** `CustomStateView.empty(title: 'No Items', message: '...', buttonText: 'Create New', onAction: ...)`
  - **Zero Blank Screens:** Any view that queries a list, collection, or search query must properly render `CustomStateView.empty` when the result count is 0.

---

## 10. Strict Loading & Asynchronous Action Standard
- **Mandatory Loading State on EVERY `await` Action:**
  - Har action, controller method, button tap, form submission, dialog action, ya network call jahan `await` use ho, wahan **proper loading state lazmi handle honi chahiye**.
- **Enforced `try-finally` Block Pattern:**
  - Har asynchronous execution block mein `isLoading` flag ko `try-finally` pattern mein wrap karna strictly mandatory hai taake error aane par bhi loading state hang na ho:
    ```dart
    try {
      isLoading.value = true;
      await repo.performAction();
    } finally {
      isLoading.value = false;
    }
    ```
- **UI & Interaction Lock (Duplicate Tap Prevention):**
  - Jab koi asynchronous action in-flight ho:
    * Tamam interactive controls (buttons, form inputs, dialog dismissals, tap handlers) **disable** hone chahiye taake user accidental double-tap ya duplicate API requests trigger na kar sake.
    * Dialogs ke andar `PopScope(canPop: !isLoading)` lazmi use karein taake in-progress API calls ke doran dialog dismiss na ho sake.
- **Visual Feedback Requirement:**
  * Har button par spinning indicator show karein (`CustomButton(isLoading: controller.isLoading.value)` ya `CircularProgressIndicator`).
  * Dialog actions ke andar action button loader spinner show kare aur progress status text (e.g. "Signing out...", "Saving...") update kare.
  * Screen-level data loading par proper skeleton/shimmer ya centered spinner render karein.
- **Strick Rule must implemntation:**
 * always use horizontal padding insiode padding is 12.w
 * always left ya right padding must b 12.w
 * Always use AppSpaces.defaultPadding for the main padding of the screen.
 *  Always use existing resources  existing theme , app colors , app spaces , app pading , app text styles , app fonts , app icons , app images , app strings , app icons , app images , app strings      
 * never use hardcoded hex colors  
 * always  use existing  flutter resources existing theme , app colors , app spaces , app pading , app text styles , app fonts , app icons , app images , app strings , app icons , app images , app strings      
 * never use hardcoded hex colors  
 * always  use existing  flutter resources