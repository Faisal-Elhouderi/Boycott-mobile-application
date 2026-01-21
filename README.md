## Boycott Companion

Boycott Companion is a full-stack mobile app that helps people identify boycotted products,
understand company ownership, and find local alternatives. It includes a Flutter mobile client
and a Node.js/Express API backed by PostgreSQL.

## What the app does

- Scan a barcode or search for a product and see boycott status and claims.
- Browse alternatives by product or category.
- Explore company ownership, brands, and product lines.
- Contribute community submissions and vote on them.
- Track availability and pricing at stores.
- View user profiles, stats, and leaderboards.

## Tech stack

- Mobile: Flutter, Riverpod, GoRouter, Dio
- Backend: Node.js, TypeScript, Express, Prisma
- Database: PostgreSQL
- Auth: JWT

## Repo structure

```
backend/   # Node.js API + Prisma + data import
mobile/    # Flutter mobile app
```

## Quick start

### Backend (API)

Prerequisites: Node.js 18+, PostgreSQL 14+, npm or yarn

```bash
cd backend
npm install
cp env.example .env
# Edit .env with your database credentials
npm run db:generate
npm run db:push
npm run db:seed
npm run dev
```

API will run at `http://localhost:3000` with health check at `http://localhost:3000/health`.

### Mobile (Flutter)

Prerequisites: Flutter 3.x, Dart 3.x, Android Studio/Xcode

```bash
cd mobile
flutter pub get
flutter run
```

For Android emulator, set the API URL in
`mobile/lib/core/network/api_client.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

For a physical device, use your machine IP instead of `10.0.2.2`.

## Configuration

Backend environment variables (see `backend/env.example`):

| Variable | Description | Default |
|----------|-------------|---------|
| DATABASE_URL | PostgreSQL connection string | - |
| JWT_SECRET | Secret for JWT signing | - |
| JWT_EXPIRES_IN | JWT expiration time | 7d |
| PORT | Server port | 3000 |
| NODE_ENV | Environment | development |
| CORS_ORIGIN | Allowed CORS origin | http://localhost:5173 |

## API overview

Core route groups are mounted under `/api`:

- Auth: register, login, profile
- Products: scan, details, alternatives, claims
- Companies: ownership, brands, products
- Alternatives: product and category alternatives
- Stores and markets: availability and pricing
- Search: products, companies, brands, categories
- Community: submissions, votes, moderation
- Users: profile, stats, badges, leaderboard
- Reports and items: internal content workflows

Full endpoint list is documented in `backend/README.md`.

## Data and imports

The API ships with import scripts, but `backend/data/boycott_data.json` is
currently empty. This means the database will not have boycott content until
you populate the data file or connect a proper data source.

Import scripts live in `backend/src/database/import/importData.ts`.
Categories are in `backend/data/categories.json`.

## Why this app needs some work

- The core boycott dataset is empty, so the app cannot deliver results without
  a data ingestion or curation pipeline.
- Automated tests are minimal (only a single Flutter widget test and no backend
  tests), which makes regressions likely.
- There is no production deployment/CI configuration in the repo (no Docker or
  CI workflows), so release steps are not defined yet.
- The mobile app notes unfinished UX work (for example, dark mode is marked as
  "coming soon").

## What needs to be done to complete the project

Data and content:

- Populate boycott data (companies, brands, products, claims, alternatives).
- Define sources, update cadence, and moderation workflow for community input.
- Add admin tooling or internal dashboards for data QA.

Backend:

- Add automated tests for routes, validation, and business logic.
- Add production hardening (rate limiting, input abuse controls, logging).
- Document deployment (environment setup, migrations, backups).

Mobile:

- Complete dark mode and any unfinished screens or flows.
- Expand offline handling, error states, and empty states.
- Add integration tests around scanning and search flows.

Ops and release:

- Add CI pipelines, linting, and build checks.
- Add release checklist and app store metadata.
- Add monitoring and crash reporting for production.

## Scripts

Backend scripts live in `backend/package.json`. Highlights:

- `npm run dev` - start API in watch mode
- `npm run db:generate` - generate Prisma client
- `npm run db:push` - push schema to database
- `npm run db:seed` - seed database
- `npm run db:import` - import data from `backend/data`

Mobile scripts are standard Flutter commands:

- `flutter run` - run app on device or emulator
- `flutter test` - run tests
- `flutter build apk` - Android release build
- `flutter build ios` - iOS release build

## License

ISC
