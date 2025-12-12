# SubTrack Development Plan

This document outlines the phased development plan for the SubTrack application, based on the Technical Product Requirement Document.

## Phase 1: Core Application and Manual Tracking (MVP)

**Goal:** Establish the foundation of the app, allowing users to manually input and track subscriptions and expenses.

**Tasks:**
1.  **Project Setup:**
    *   Initialize a new Flutter project.
    *   Set up the "Clean Architecture" with a feature-first structure.
    *   Integrate Riverpod for state management.
    *   Integrate Drift for database persistence.
2.  **Database Schema (Drift):**
    *   Define initial tables for `Subscriptions`, `Transactions`, `Users`, and `Categories`.
3.  **UI/UX (Flutter):**
    *   Create the main dashboard UI to display a list of subscriptions.
    *   Implement a form to manually add/edit a subscription (Merchant, Amount, Due Date, Category).
    *   Implement basic expense categorization.
4.  **Security:**
    *   Implement Biometric Authentication (via `local_auth`) to secure access to the application.

## Phase 2: Android Automation

**Goal:** Implement the "zero-input" automatic transaction detection feature on Android.

**Tasks:**
1.  **Native Android Integration:**
    *   Create a `NotificationListenerService` in Kotlin to intercept financial notifications.
    *   Set up `MethodChannel` and `EventChannel` for communication between the native Kotlin service and the Dart/Flutter layer.
2.  **Permissions and Onboarding:**
    *   Design and implement a user-friendly workflow to guide the user in granting the necessary notification access permissions.
3.  **Parsing Engine:**
    *   Develop the Regex pattern matching engine in Dart to parse unstructured notification text into structured data (Merchant, Amount, Date).
    *   Build a comprehensive corpus of test SMS/notification strings from various banks.
    *   Write extensive unit tests for the parsing engine to ensure accuracy.
4.  **UI Integration:**
    *   The UI should reactively display new transactions detected by the service.
    *   Implement a confirmation step for users to verify and categorize auto-detected transactions.

## Phase 3: iOS Automation

**Goal:** Implement the "pull" automation feature on iOS using OCR.

**Tasks:**
1.  **Native iOS Integration:**
    *   Integrate the `VNDocumentCameraViewController` for scanning physical receipts and bills.
    *   Use a `UIViewControllerRepresentable` to bridge the native UIKit controller into the Flutter widget tree.
2.  **OCR Pipeline:**
    *   Implement the OCR pipeline using Apple's Vision framework to extract text from images.
    *   Develop heuristic logic to parse the extracted text to identify Amount, Date, and Merchant.
3.  **UI Integration:**
    *   Add a UI element (e.g., a floating action button) to initiate a scan.
    *   Display the scanned and parsed transaction data for user review and confirmation.
    *   Allow users to select images from their photo library for OCR processing.

## Phase 4: Shared Expenses and Debt Simplification

**Goal:** Introduce group features for managing and settling shared expenses.

**Tasks:**
1.  **Database Schema Extension:**
    *   Extend the Drift schema with tables for `Groups` and `Splits` to model many-to-many relationships between users and transactions.
2.  **Debt Simplification Engine:**
    *   Implement the greedy algorithm for debt simplification (Minimum Cash Flow).
    *   Write property-based tests to rigorously verify the algorithm's correctness and ensure no money is lost or created.
3.  **UI/UX for Groups:**
    *   Create UI for creating and managing groups of users.
    *   Allow users to split an existing transaction with a group, specifying equal or unequal shares.
    *   Display the simplified debt settlement plan in a clear and understandable way.

## Phase 5: Professional Features and Monetization

**Goal:** Add premium features targeting freelancers and monetize the application.

**Tasks:**
1.  **Tax Features:**
    *   Implement IRS Schedule C categorization for business-related expenses.
    *   Build a CSV export feature to generate reports compatible with accounting software.
2.  **Monetization:**
    *   Integrate the RevenueCat SDK for managing in-app subscriptions.
    *   Define a "Premium" tier that unlocks automation, tax features, and unlimited groups.
    *   Implement a paywall or upsell screens within the app.
3.  **Security Enhancement:**
    *   Implement at-rest, field-level encryption for sensitive database columns using `flutter_secure_storage` to store encryption keys in the device's secure element.

## Phase 6: Refinement and Deployment

**Goal:** Polish the application and prepare it for public release.

**Tasks:**
1.  **Quality Assurance and Testing:**
    *   Conduct end-to-end UI testing using a framework like Maestro or Patrol.
    *   Perform extensive manual testing across a range of physical devices and OS versions.
2.  **Onboarding and User Education:**
    *   Refine the new user onboarding flow to be as smooth as possible.
    *   Create in-app tutorials, tooltips, or help screens to educate users on advanced features.
3.  **Deployment:**
    *   Prepare app store listings for the Google Play Store and Apple App Store, including screenshots, descriptions, and privacy policies.
    *   Execute the release process for both platforms.
