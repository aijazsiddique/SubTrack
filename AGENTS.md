# AGENTS.md: SubTrack Development Blueprint

This document outlines the distinct software agents (modules) to be developed for the SubTrack application. It serves as a blueprint for implementation, linking coding tasks directly to the project's foundational documents.

**Core Reference Documents:**
*   **`requirements.md`**: The technical product requirement document. It defines the **Why** and **What**.
*   **`plan.md`**: The phased development strategy. It defines the **How** and **When**.
*   **`progress.md`**: Tracks the development progress.

### Progress Tracking Rules
1.  **`progress.md` is the Single Source of Truth:** This file must be kept in sync with the actual state of development.
2.  **Update Before Starting:** Before beginning a new major task or sub-task listed in `progress.md`, you **must** update its status.
3.  **Marking Progress:**
    *   To mark a task as complete, change `[ ]` to `[x]`.
    *   Update the Phase `Status` from "Not Started" to "In Progress" when the first task of that phase begins.
    *   Update the Phase `Status` to "Completed" when the last task of that phase is finished.
4.  **Completeness:** A parent task should only be marked as complete (`[x]`) when all of its children sub-tasks are also marked as complete.

---

## Agent Roster

### 1. Data Persistence Agent
*   **Purpose:** To manage the local SQLite database schema and data access operations.
*   **Core Technology:** Drift (SQLite wrapper for Dart/Flutter).
*   **Requirements Reference:** Section 2.3 ("Data Persistence: Drift").
*   **Plan Reference:** Phase 1 ("Database Schema") & Phase 4 ("Database Schema Extension").
*   **Key Tasks:**
    *   Define and create tables for `Subscriptions`, `Transactions`, `Users`, `Categories`, `Groups`, and `Splits`.
    *   Implement type-safe Data Access Objects (DAOs) for all database entities.
    *   Handle database migrations as the schema evolves.

### 2. State Management Agent
*   **Purpose:** To manage application state, handle dependencies, and enable reactive UI updates.
*   **Core Technology:** Riverpod 2.0.
*   **Requirements Reference:** Section 2.2 ("State Management Strategy: Riverpod 2.0").
*   **Plan Reference:** Phase 1 ("Project Setup").
*   **Key Tasks:**
    *   Set up `NotifierProvider` for synchronous form state, `AsyncNotifierProvider` for database calls, and `StreamProvider` for real-time data feeds.
    *   Utilize `riverpod_generator` to ensure type safety and reduce boilerplate.

### 3. Android Notification Parsing Agent
*   **Purpose:** To automatically detect, intercept, and parse financial transactions from Android notifications in real-time.
*   **Core Technology:** Kotlin, `NotificationListenerService`, `EventChannel`, Dart Regex Engine.
*   **Requirements Reference:** Section 3 ("Platform-Specific Implementation: Android").
*   **Plan Reference:** Phase 2 ("Android Automation").
*   **Key Tasks:**
    *   Implement the `NotificationListenerService` in native Kotlin.
    *   Use an `EventChannel` to stream raw notification data to the Dart layer.
    *   Implement the Regex Pattern Matching Engine in Dart to accurately parse the raw text.
    *   Handle Android 15+ restrictions and create a robust permission-granting flow.

### 4. iOS OCR Agent
*   **Purpose:** To extract transaction data from user-provided screenshots or camera scans on iOS.
*   **Core Technology:** Swift, `VisionKit`, `VNDocumentCameraViewController`, Platform Views.
*   **Requirements Reference:** Section 4 ("Platform-Specific Implementation: iOS").
*   **Plan Reference:** Phase 3 ("iOS Automation").
*   **Key Tasks:**
    *   Integrate the `VNDocumentCameraViewController` into the Flutter UI.
    *   Create an OCR pipeline using the `Vision` framework for text recognition.
    *   Develop a heuristic engine in Dart to parse the unstructured OCR output and identify merchant, amount, and date.

### 5. Debt Simplification Agent
*   **Purpose:** To calculate the minimum number of transactions required to settle debts within a group.
*   **Core Technology:** Dart, Graph Theory concepts.
*   **Requirements Reference:** Section 5 ("Core Logic: Debt Simplification Engine").
*   **Plan Reference:** Phase 4 ("Shared Expenses and Debt Simplification").
*   **Key Tasks:**
    *   Implement the greedy algorithm for debt simplification (Minimum Cash Flow).
    *   Model the group's financial state as a directed graph.
    *   Develop and verify the logic with property-based tests to guarantee correctness.

### 6. Tax & Monetization Agent
*   **Purpose:** To implement premium features, including tax compliance tools and subscription management.
*   **Core Technology:** Dart, RevenueCat SDK.
*   **Requirements Reference:** Section 6 ("Regulatory Compliance") & Section 7 ("Monetization").
*   **Plan Reference:** Phase 5 ("Professional Features and Monetization").
*   **Key Tasks:**
    *   Implement IRS Schedule C categorization for business expenses.
    *   Develop a CSV export function for tax filing.
    *   Integrate the RevenueCat SDK to handle in-app purchases and manage premium entitlements.

### 7. Security Agent
*   **Purpose:** To enforce the application's multi-layered security strategy and protect user data.
*   **Core Technology:** `local_auth`, `flutter_secure_storage`, platform-native cryptography.
*   **Requirements Reference:** Section 2.4 ("Security Architecture").
*   **Plan Reference:** Phase 1 ("Security") & Phase 5 ("Security Enhancement").
*   **Key Tasks:**
    *   Implement mandatory biometric authentication (`FaceID`/`Fingerprint`) to access the app.
    *   Implement at-rest encryption for sensitive data fields within the SQLite database, storing keys in the device's hardware-backed secure element.
