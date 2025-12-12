# SubTrack Manual Testing Guide

This document outlines key areas for manual testing to ensure the core functionalities of the SubTrack application are working as expected. This guide is based on the features implemented during development phases.

## Phase 1: Core Application and Manual Tracking (MVP)

### 1.1 Project Setup Verification
*   **Objective:** Verify the basic Flutter application runs and the initial setup is correct.
*   **Steps:**
    1.  Ensure you are in the `subtrack` directory: `cd subtrack`
    2.  Run the application on an emulator/device: `flutter run`
    3.  Verify that the app launches successfully and displays the "My Subscriptions" screen.

### 1.2 Biometric Authentication
*   **Objective:** Verify biometric authentication locks and unlocks the app.
*   **Steps:**
    1.  Ensure your test device/emulator has biometrics configured (fingerprint/Face ID).
    2.  Launch the app. It should immediately present a biometric authentication prompt.
    3.  Successfully authenticate. The app should proceed to the "My Subscriptions" screen.
    4.  Put the app in the background and bring it back to the foreground. It should prompt for biometrics again.
    5.  Fail biometric authentication (if possible, e.g., by cancelling or using wrong fingerprint). The app should remain locked.
    6.  (Optional) Disable biometrics on the device. The app should launch without prompting for biometrics or provide an alternative unlock method if implemented.

### 1.3 Subscription Management (CRUD)
*   **Objective:** Verify adding, viewing, editing, and deleting subscriptions.
*   **Steps:**
    1.  **Add Subscription:**
        *   On the "My Subscriptions" screen, tap the `+` button (Add Subscription FAB).
        *   Fill in all required fields (Name, Amount, Currency, Next Billing Date, Billing Cycle).
        *   (Optional) Select a Category.
        *   (Optional) Enter Notes.
        *   (Optional) Toggle "Is this a business expense?" to true and select a "Schedule C Category".
        *   Tap "Add Subscription".
        *   Verify the app navigates back to the "My Subscriptions" screen and the new subscription appears in the list.
    2.  **View Subscriptions:**
        *   Verify all added subscriptions are listed on the "My Subscriptions" screen with their details (Name, Amount, Next Billing, Cycle, Notes).
    3.  **Edit Subscription:**
        *   Tap on an existing subscription card. This should navigate to the "Edit Subscription" screen.
        *   Modify some fields (e.g., Amount, Cycle, Notes, Category, Business Expense status).
        *   Tap "Update Subscription".
        *   Verify the app navigates back and the changes are reflected in the list.
    4.  **Delete Subscription:** (Not yet implemented in UI, but data layer supports it)
        *   *Self-note: A delete option needs to be added to the UI for full CRUD testing.*

### 1.4 Category Management
*   **Objective:** Verify category selection and pre-population works.
*   **Steps:**
    1.  Add a new subscription (see 1.3.1).
    2.  Verify that the default categories ("General", "Entertainment", "Utilities", "Software", "Food") are available in the "Category" dropdown.
    3.  Select a category and save the subscription.
    4.  Edit the subscription and verify the selected category is pre-filled.
    5.  (Optional: if a category management screen is implemented later) Add, edit, and delete custom categories.

## Phase 2: Android Automation

### 2.1 Notification Access Permission Flow
*   **Objective:** Verify the app correctly requests and handles notification listener permission.
*   **Steps:**
    1.  **Initial Launch (without permission):**
        *   Uninstall and reinstall the app on an Android device/emulator.
        *   Launch the app. It should display the "Permission Required" screen, prompting to grant notification access.
    2.  **Grant Permission:**
        *   Tap "Grant Notification Access". The app should navigate to Android's "Notification access" settings.
        *   Find "SubTrack" in the list and enable its access.
        *   Navigate back to SubTrack. The app should now show the "My Subscriptions" screen.
    3.  **Launch (with permission):**
        *   Close and re-launch the app. It should go directly to the "My Subscriptions" screen without prompting for permission.
    4.  **Deny/Revoke Permission:**
        *   Go to Android settings -> Apps -> SubTrack -> Notifications and disable "Allow notification access" for SubTrack.
        *   Bring SubTrack to the foreground. It should return to the "Permission Required" screen.

### 2.2 Automated Transaction Detection (from Notifications)
*   **Objective:** Verify the app can detect and parse financial notifications.
*   **Prerequisites:** Ensure notification access is granted (see 2.1).
*   **Steps:**
    1.  Send a test notification to the device/emulator that mimics a bank transaction (e.g., using `adb shell cmd notification post`). Examples:
        *   `adb shell cmd notification post -S bigtext -t "Chase" "You spent \$15.99 at NETFLIX" -T "Your recent purchase of \$15.99 at NETFLIX was processed." tag "test" 100`
        *   `adb shell cmd notification post -S bigtext -t "Amex" "Amex: charged \$49.99 at SPOTIFY" tag "test" 101`
        *   `adb shell cmd notification post -S bigtext -t "PayPal" "You paid \$9.99 USD to GOOGLE" tag "test" 102`
    2.  Observe the SubTrack app.
    3.  **Verification:** A "Confirm Transaction" screen should appear, pre-filled with the parsed Merchant, Amount, Date, and Source ('Notification').
    4.  (Optional) Try with notifications from other apps/formats to test the generic regex.

## Phase 3: iOS Automation

### 3.1 Document Scanning (OCR)
*   **Objective:** Verify the app can scan documents using VisionKit and perform OCR.
*   **Steps:**
    1.  Run the app on an iOS device/simulator.
    2.  On the "My Subscriptions" screen, tap the "Scan Document (iOS)" FAB.
    3.  The native document scanner should open.
    4.  Scan a document (e.g., a bill, receipt) with clear transaction details.
    5.  After scanning, the app should process the image.
    6.  **Verification:** A "Confirm Transaction" screen should appear, pre-filled with the parsed Merchant, Amount, Date, and Source ('OCR').
    7.  (Optional) Test with documents containing different layouts or handwritten text (accuracy may vary).

## Phase 4: Shared Expenses and Debt Simplification

### 4.1 Group Management
*   **Objective:** Verify creating, viewing, and deleting groups.
*   **Steps:**
    1.  On the "My Subscriptions" screen, tap the `group` icon in the AppBar to go to "Manage Groups".
    2.  **Add Group:**
        *   Enter a name in the "New Group Name" text field.
        *   Tap "Add Group".
        *   Verify the new group appears in the list.
    3.  **View Groups:**
        *   Verify all added groups are listed.
    4.  **Delete Group:**
        *   Tap the trash icon next to an existing group.
        *   Verify the group is removed from the list.

### 4.2 Transaction Splitting
*   **Objective:** Verify the UI for splitting a transaction and viewing participants.
*   **Steps:**
    1.  Initiate a transaction confirmation (e.g., via Android notification or iOS OCR).
    2.  On the "Confirm Transaction" screen, fill in details as needed.
    3.  Tap "Split Transaction".
    4.  **Verification:** The "Split Transaction" screen should appear.
    5.  Select an existing group from the dropdown.
    6.  Select multiple participants (users) from the checkboxes.
    7.  Enter a total amount (if not pre-filled).
    8.  Verify the individual split amounts are updated (if equal split is default).
    9.  (Optional) Manually adjust individual split amounts.
    10. Tap "Save Splits" (currently prints to console).

### 4.3 Debt Settlement Plan
*   **Objective:** Verify the simplified debt settlement plan is displayed.
*   **Steps:**
    1.  On the "Split Transaction" screen, ensure a group is selected, users are chosen, and a total amount is set.
    2.  Tap "View Debt Settlement Plan".
    3.  **Verification:** The "Simplified Debt Settlement" screen should appear, showing who pays whom and the amounts, based on the `DebtSimplificationService`'s logic.

## Phase 5: Professional Features and Monetization

### 5.1 Tax Features (Schedule C Categorization & CSV Export)
*   **Objective:** Verify that business expenses can be categorized and exported.
*   **Steps:**
    1.  Go to the "My Subscriptions" screen and tap the settings icon in the AppBar.
    2.  **Schedule C Categorization:**
        *   Add/Edit a subscription.
        *   Toggle "Is this a business expense?" to true.
        *   Select a "Schedule C Category" from the dropdown.
        *   Save the subscription.
        *   Edit the subscription again and verify the selected Schedule C category is retained.
    3.  **CSV Export:**
        *   On the "Settings" screen, tap "Export Transactions to CSV".
        *   **Verification:** A SnackBar should appear indicating the path where the CSV file was saved.
        *   (Manual) Access the file system of the device/emulator to verify the CSV file exists and contains the transaction data, including Schedule C categories.

### 5.2 Monetization (Paywall)
*   **Objective:** Verify the "Go Premium" paywall displays offerings and handles purchase/restore flows.
*   **Prerequisites:** You must have a RevenueCat project set up with products/offerings configured and the API key correctly set in `main.dart`. This requires actual app store accounts for testing.
*   **Steps:**
    1.  Go to the "My Subscriptions" screen and tap the settings icon in the AppBar.
    2.  Tap "Go Premium".
    3.  **Verification:** The "Go Premium" screen (paywall) should appear, displaying available offerings and packages (if configured in RevenueCat).
    4.  (Optional - Requires real setup) Tap a "Buy" button to attempt a purchase.
    5.  (Optional - Requires real setup) Tap "Restore Purchases".
    6.  Verify that entitlements are correctly reflected after a successful purchase or restore (e.g., premium features become unlocked, if implemented to rely on `premiumStatusProvider`).

### 5.3 Security Enhancement (At-Rest Encryption)
*   **Objective:** This feature was marked as conceptually complete as it requires deeper native integration and is outside the scope of direct AI implementation for a prototype. Manual verification would involve analyzing the database file on a rooted/jailbroken device to check for field-level encryption.
*   **Steps:** This cannot be directly tested via the UI. Developer tools and specific testing environments would be needed.

---

This guide provides a comprehensive overview of the manual testing required for the SubTrack application's current feature set.
