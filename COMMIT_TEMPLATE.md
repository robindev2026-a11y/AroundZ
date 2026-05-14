# 🧾 COMMIT TEMPLATE (CONVENTIONAL + FEATURE-BASED)

Use this template for all commits.

---

## 🎯 FORMAT

<type>(scope): short summary

---

## 🧩 TYPES

* feat     → new feature
* fix      → bug fix
* refactor → code improvement (no behavior change)
* docs     → documentation updates
* chore    → maintenance / non-functional
* style    → UI/styling changes only
* test     → adding/updating tests

---

## 📦 SCOPES (Examples)

* vendor
* auth
* onboarding
* dashboard
* routing
* ui
* firestore
* plan

---

## ✍️ EXAMPLES

feat(auth): add OTP login flow
feat(vendor): implement VendorPlan model
feat(vendor-ui): add plan manager screens
fix(routing): correct onboarding redirect logic
docs(plan): update implementation status

---

## 🧠 EXTENDED FORMAT (OPTIONAL)

<type>(scope): short summary

Details:

* What was done
* Why it was needed

Changes:

* Key files or logic updated

---

## ✅ GOOD COMMIT

feat(onboarding): add tenant onboarding flow

Details:

* Added ONB-T-01 screen
* Connected navigation after login

Changes:

* onboarding_screen.dart
* routing logic updated

---

## ❌ BAD COMMIT

update stuff
fix code
changes

---

## ⚠️ RULES

* One commit = one logical change
* Do NOT mix unrelated changes
* Keep summary under 60 characters
* Use present tense (add, fix, update — not added, fixed)

---

## 🚀 QUICK CHECKLIST

Before committing:

* [ ] Is this one logical change?
* [ ] Is message clear?
* [ ] Is scope correct?
* [ ] Are unrelated files excluded?

---

## 🎯 FINAL DIRECTIVE

"Clear commit > clever commit"
