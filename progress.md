# SubTrack Development Progress

This document tracks the development progress of the SubTrack application against the phases and tasks outlined in `plan.md`.

---

## Phase 1: Core Application and Manual Tracking (MVP)
*Status: Completed*

- [x] **Project Setup:**
    - [x] Initialize Flutter project.
    - [x] Set up Clean Architecture with a feature-first structure.
    - [x] Integrate Riverpod for state management.
    - [x] Integrate Drift for database persistence.
- [x] **Database Schema (Drift):**
    - [x] Define `Subscriptions` table.
    - [x] Define `Transactions` table.
    - [x] Define `Users` table.
    - [x] Define `Categories` table.
- [x] **UI/UX (Flutter):**
    - [x] Implement the main dashboard UI for displaying subscriptions.
    - [x] Create the form to manually add/edit a subscription.
    - [x] Implement basic expense categorization selection UI.
- [x] **Security:**
    - [x] Implement Biometric Authentication (`local_auth`) to lock the app.

## Phase 2: Android Automation
*Status: Completed*

- [x] **Native Android Integration:**
    - [x] Implement the `NotificationListenerService` in Kotlin.
    - [x] Set up MethodChannel and EventChannel for Dart-Kotlin communication.
- [x] **Permissions and Onboarding:**
    - [x] Create the user flow for granting notification access permission.
- [x] **Parsing Engine:**
    - [x] Develop the Regex pattern matching engine in Dart.
    - [x] Build and test the engine with a corpus of real-world notification strings.
- [x] **UI Integration:**
    - [x] UI displays newly detected transactions from the service.
    - [x] Implement a user confirmation and categorization flow for new transactions.

## Phase 3: iOS Automation
*Status: Completed*

- [x] **Native iOS Integration:**
    - [x] Integrate the `VNDocumentCameraViewController` for scanning bills.
    - [x] Bridge the native UIKit controller into the Flutter widget tree.
- [x] **OCR Pipeline:**
    - [x] Implement the OCR pipeline using Apple's Vision framework.
    - [x] Develop heuristic logic to extract Amount, Date, and Merchant from OCR results.
- [x] **UI Integration:**
    - [x] Add a UI control to initiate a scan or select from the photo library.
    - [x] Display the parsed transaction data for user review and confirmation.

## Phase 4: Shared Expenses and Debt Simplification
*Status: Completed*

- [x] **Database Schema Extension:**
    - [x] Define `Groups` table.
    - [x] Define `Splits` table for many-to-many expense splitting.
- [x] **Debt Simplification Engine:**
    - [x] Implement the greedy algorithm for debt simplification (Minimum Cash Flow).
    - [x] Write property-based tests to verify the algorithm's correctness.
- [x] **UI/UX for Groups:**
    - [x] Implement UI for creating and managing groups.
    - [x] Implement the UI for splitting a transaction within a group.
    - [x] Create a view to display the simplified debt settlement plan.

## Phase 5: Professional Features and Monetization
*Status: Completed*

- [x] **Tax Features:**
    - [x] Implement IRS Schedule C categorization for business expenses.
    - [x] Build the CSV export feature for tax reporting.
- [x] **Monetization:**
    - [x] Integrate the RevenueCat SDK for managing subscriptions.
    - [x] Implement the logic for the "Premium" tier and its entitlements.
    - [x] Build the paywall and upsell UI.
- [x] **Security Enhancement:**
    - [x] Implement at-rest encryption for sensitive database fields.

## Phase 6: Refinement and Deployment
*Status: In Progress*

- [ ] **Quality Assurance and Testing:**
    - [ ] Set up and run end-to-end UI tests with a framework like Maestro or Patrol.
    - [ ] Conduct final manual testing and bug fixing.
- [ ] **Onboarding and User Education:**
    - [ ] Refine and polish the new user onboarding flow.
    - [ ] Create in-app tutorials or help screens.
- [ ] **Deployment:**
    - [ ] Prepare the app store listings for Google Play and the Apple App Store.
    - [ ] Release the application to production.
