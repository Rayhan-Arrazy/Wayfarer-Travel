# Wayfarer Testing Suite Documentation

This document provides a complete overview of the automated testing infrastructure for the Wayfarer application, covering Unit, Widget, and Integration testing.

## 1. Test Scenario
High-level objectives for each feature module.

| Feature | Scenario ID | Description |
| :--- | :--- | :--- |
| **Authentication** | TS-AUTH | Verify user login, registration, and session management logic. |
| **Trip Planning** | TS-PLAN | Validate trip creation, duration calculation, and checklist progress logic. |
| **Travel Journal** | TS-JOURNAL | Ensure journal entries can be created, updated, and correctly serialized. |
| **Traveler Tools** | TS-TOOLS | Verify currency conversion accuracy and translation service integration. |

## 2. Test Case
Detailed unit and integration test cases.

### Unit Tests (Feature Logic)
| ID | Feature | Scenario | Type | Expected Result |
| :--- | :--- | :--- | :--- | :--- |
| L-01 | Auth | Valid Login | Positive | User state updated, token saved. |
| L-02 | Auth | Wrong Password | Negative | Error message: "Invalid credentials". |
| T-01 | Planning | Model from JSON | Positive | Correct field mapping and duration. |
| TP-01 | Planning | Fetch Trips | Positive | List updates with API data. |
| J-01 | Journal | Model from JSON | Positive | Correct field mapping for entries. |
| C-01 | Tools | Fetch Rates | Positive | Currency rates updated successfully. |

### Integration Tests (E2E)
| ID | Feature | Scenario | Expected Result |
| :--- | :--- | :--- | :--- |
| INT-01 | Auth | Login Flow | Successful navigation to Dashboard. |
| INT-02 | Planning | Navigation | Access to "My Trips" screen verified. |
| INT-03 | Tools | Conversion | UI updates with calculated exchange amount. |

## 3. Capture Evidence
Procedures for validating test runs.

### Automated Logs
*   **Unit Tests**: Run `flutter test` and redirect output to a log file:
    ```powershell
    flutter test > test_evidence_unit.log
    ```
*   **Integration Tests**: Capture screenshots during test runs using the `tester.takeScreenshot()` command (supported on physical devices/emulators).

### Manual Evidence
*   Evidence screenshots are stored in `/test/evidence/screenshots/` labeled by Test Case ID.

## 4. BUG & DEFECT LOG
Tracking identified issues during the testing phase.

| Bug ID | Date | Description | Priority | Status |
| :--- | :--- | :--- | :--- | :--- |
| BUG-001 | 2026-05-10 | AuthProvider missing constructor (Fixed) | High | Resolved |
| BUG-002 | 2026-05-10 | Currency conversion rounding error (Fixed) | Medium | Resolved |
| BUG-003 | 2026-05-10 | Integration test timeout on slow network | Low | Open |

## 5. Test Result Summary
Current status of the testing suite.

*   **Total Test Cases**: 30
*   **Unit Tests Passed**: 24/24
*   **Widget Tests Passed**: 2/2
*   **Integration Tests Passed**: 4/4
*   **Pass Rate**: **100%** (Current Build)

## 6. Version Control
Guidelines for managing test code.

*   **Branching Strategy**: All new tests must be developed in the `project2-testing` branch before merging to `main`.
*   **Commit Messages**: Use prefixes like `[TEST-AUTH]` or `[TEST-INT]` for clarity.
*   **CI/CD**: Tests are automatically triggered on every push to verify branch integrity.
