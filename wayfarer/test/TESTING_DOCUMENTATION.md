# Wayfarer Master Testing Guide

This document is the single source of truth for the Wayfarer testing suite. It covers how to run, manage, and scale tests across the three main layers: **Unit**, **Widget**, and **Integration**.

---

## 1. Directory Structure

| Test Type | Location | Purpose |
| :--- | :--- | :--- |
| **Unit** | `test/unit/features/` | Logic, Models, and Providers. |
| **Widget** | `test/` (root) | Individual Screen and Component UI. |
| **Integration** | `integration_test/` | Full End-to-End flows on real devices. |

---

## 2. Test Scenario & Test Cases

### A. Authentication
*   **Scenario 01**: User Login Flow
    *   **TC_01**: Login with valid credentials (Success).
    *   **TC_02**: Login with invalid password (Error display).
    *   **TC_03**: Login as Guest (Bypass auth).
*   **Scenario 02**: User Registration
    *   **TC_04**: Register with new email (Success).
    *   **TC_05**: Register with existing email (Conflict error).

### B. Travel Journal
*   **Scenario 03**: Journal Entry Management
    *   **TC_06**: Create new journal entry with image.
    *   **TC_07**: Edit existing entry.
    *   **TC_08**: Delete entry and verify removal.

### C. Trip Planning
*   **Scenario 04**: Trip Lifecycle
    *   **TC_09**: Create a new trip with name and dates.
    *   **TC_10**: Add multiple destinations to a trip.
    *   **TC_11**: Mark a trip as "Completed".

### D. Tools & Weather
*   **Scenario 05**: Real-time Conversion & Forecast
    *   **TC_12**: Convert USD to EUR using live rates.
    *   **TC_13**: Translate English text to Japanese.
    *   **TC_14**: Fetch 5-day weather forecast for a destination.

### E. Budgeting
*   **Scenario 06**: Expense Management
    *   **TC_15**: Add a new expense category (e.g., Food).
    *   **TC_16**: Add an expense and verify balance update.
    *   **TC_17**: Set a budget limit and trigger warning on overspend.

---

## 3. How to Run Tests

### Unit Tests (Logic)
*   **Run All**: `flutter test test/unit/`
*   **Specific Module**: `flutter test test/unit/features/[module_name]/`

### Widget Tests (UI)
*   **Run All**: `flutter test test/*.dart`
*   **Auth UI**: `flutter test test/login_widget_test.dart`
*   **Tools UI**: `flutter test test/tools_widget_test.dart`

### Integration Tests (E2E on Phone)
*   **Target Device**: ID `f9b16f26`
*   **Auth Flow**: `flutter test -d f9b16f26 integration_test/auth_test.dart`
*   **Journal Flow**: `flutter test -d f9b16f26 integration_test/journal_test.dart`
*   **Planning Flow**: `flutter test -d f9b16f26 integration_test/planning_test.dart`
*   **Tools Flow**: `flutter test -d f9b16f26 integration_test/tools_test.dart`

---

## 4. Capture Evidence (Submission Requirements)

To document your test runs for project submission:

1.  **Screenshots**: Take shots of "Success" snackbars or "Done" screens.
2.  **Screen Recording**: Use `adb shell screenrecord /sdcard/test.mp4`.
3.  **Logs**: Save terminal output to `test_evidence.txt`.

---

## 5. BUG & DEFECT LOG

| Bug ID | Test Case ID | Description | Test Priority | Status |
| :--- | :--- | :--- | :--- | :--- |
| **BUG_001** | TC_039 | Missing Inter-ExtraBold font weights caused crashes. | Critical | ✅ Fixed |
| **BUG_002** | SC_01 | Integration tests fail if moved inside /test/ folder. | High | ✅ Fixed |

---

## 6. Test Result Summary (Total: 105 Cases)

| Layer | Cases | Coverage | Result |
| :--- | :--- | :--- | :--- |
| **Unit/Logic** | 99 | Core Business Models & Providers | ✅ PASS |
| **Widget (UI)** | 1 | Auth Screen Component | ✅ PASS |
| **Integration (E2E)** | 5 | Hardware & API Full Flows | ✅ PASS |

---

## 7. Version Control Best Practices

*   **Branch**: Use `project2-testing` for all testing work.
*   **Commits**: Prefix with `test:` or `fix:`.
*   **Sync**: Always pull before pushing to avoid conflicts.

---

## 8. Troubleshooting

*   **MissingPluginException**: Keep tests in root `/integration_test/`.
*   **Fonts**: Check `pubspec.yaml` for bundled weights.
*   **ADB**: Ensure your device `f9b16f26` is authorized via `adb devices`.
