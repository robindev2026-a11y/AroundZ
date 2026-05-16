# CoffeeCall Backend

Firebase Cloud Functions + Firestore for serverless backend.

## Setup

**Platform:** Firebase (Cloud Functions, Firestore, Cloud Messaging, Storage)
**Runtime:** Node.js 18+

## Build & Deploy

```bash
cd apps/backend/functions
npm install
npm run build
cd ../../..
firebase deploy --only functions
```

## Local Testing

```bash
cd apps/backend/functions
npm test
cd ../../..
firebase emulators:start
```

## Implementation

Current phase is coding and verification. Treat older prompt-generation docs as historical unless the user explicitly asks to regenerate backend code from prompts.

### Reference Files
- Architecture: `/Planning/architecture.md`
- Specification: `/Planning/spec.md`
- Rules and endpoints are documented in `/Planning/spec.md` and `/Planning/architecture.md`

## Project Structure

```
backend/
├── functions/
│   ├── src/
│   │   ├── triggers/         # Cloud Function triggers
│   │   ├── handlers/         # Business logic
│   │   ├── services/         # Firebase, geohashing
│   │   ├── models/           # Data models
│   │   └── index.ts          # Entry point
│   ├── package.json
│   └── tsconfig.json
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
└── firebase.json
```

## Key Functions

- `POST /createPost` — Post creation + geohashing + notification
- `POST /acceptPost` — Acceptance + thread creation + notification
- `POST /sendMessage` — Message persistence
- `GET /getNearbyPosts` — Geohashing query
- `GET /getPosterDashboard` — Acceptances list

---

**Status:** Implementation in progress
