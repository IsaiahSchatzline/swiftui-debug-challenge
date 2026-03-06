# SwiftUI Debug Challenge

A lightweight SwiftUI + MVVM demo app designed as a **45-minute debugging challenge**.

The app launches and navigates, but three regressions were introduced during a refactor. Your job is to restore the app to a healthy state. Use this README as your guide. The first time you get stuck, I recommend checking the extra tips/hints at the bottom of this file before checking the task-specific hints. The difficulty of this challenge meets the standards of a debugging interview for a mid-level iOS Engineer.

---

## What you’ll practice

- SwiftUI state management and MVVM boundaries
- Finding and fixing a practical retain cycle / memory leak
- Debugging login validation logic and edge cases

---

## Challenge rules

- Treat the current behavior as “broken”
- Fix the three issues so the app matches expected behavior again
- Keep fixes minimal and maintainable

---

## Tasks

### Task 1 – State Management

- Expected: The checkmark in card selection and the card saved by the Save button always match.
- Actual: The UI can show one selected card, but Save behaves like a different card is selected (or no card is selected).

<details>
  <summary>Acceptance Criteria (click to expand)</summary>

- Checkmark state and saved card always match.  
- Save uses the currently selected card reliably.

</details>

<details>
  <summary>Hints (click to expand)</summary>

- Check whether there is one source of truth for selected card state.  
- Verify the state used by row checkmarks is the same state used during Save.

</details>


---

### Task 2 – Memory Leak

- Expected: Repeating Start → Merchant → Login → back should not keep old screen/view-model instances alive.
- Actual: Memory usage grows over repeated loops, and related objects do not deallocate as expected.

<details>
  <summary>Acceptance Criteria (click to expand)</summary>

- Repeated navigation loops do not show continued memory growth.  
- Leaked view models no longer persist after leaving the screen.

</details>

<details>
  <summary>Hints (click to expand)</summary>

- Look for closures registered with long-lived shared services.  
- Check capture semantics and whether subscriptions are canceled/unsubscribed.

</details>


---

### Task 3 – Login Authentication

- Expected: Non-empty username/password should proceed; empty fields should show inline error and block navigation.
- Actual: Valid non-empty credentials are rejected, while empty/partial-empty credentials can proceed.

<details>
  <summary>Acceptance Criteria (click to expand)</summary>

- Empty username or password shows inline error and does not navigate.  
- Non-empty username/password navigates to the next step.  
- OTP flow (if enabled) still requires code `1234`.

</details>

<details>
  <summary>Hints (click to expand)</summary>

- Inspect the credential validation guard condition carefully.  
- Try a truth-table style check for empty vs non-empty username/password combinations.

</details>


---

<details>
  <summary><strong>Extra Tips</strong></summary>

### Extra Tips/Hints (click to expand)

1. Reproduce each bug and write down the exact steps
2. Fix Task 3 first (quick confidence win)
3. Fix Task 1 next (state / data flow)
4. Use Memory Graph or Instruments for Task 2

Recommended tools:
- Breakpoints + Debug View Hierarchy
- Memory Graph Debugger
- Instruments → Leaks / Allocations

</details>
