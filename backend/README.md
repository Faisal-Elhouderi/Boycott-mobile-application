# Boycott Companion API

Backend API for the Boycott Companion App - helping people identify boycotted products and find alternatives.

## Tech Stack

- **Runtime:** Node.js with TypeScript
- **Framework:** Express.js
- **Database:** PostgreSQL with Prisma ORM
- **Authentication:** JWT

## Getting Started

### Prerequisites

- Node.js 18+ 
- PostgreSQL 14+
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp env.example .env
# Edit .env with your database credentials
```

3. Generate Prisma client:
```bash
npm run db:generate
```

4. Push database schema:
```bash
npm run db:push
```

5. Seed the database:
```bash
npm run db:seed
```

6. Start development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user
- `PATCH /api/auth/me` - Update profile

### Products
- `GET /api/products` - List all products
- `GET /api/products/barcode/:barcode` - Get product by barcode (scan)
- `GET /api/products/:id` - Get product details
- `GET /api/products/:id/alternatives` - Get product alternatives
- `GET /api/products/:id/claims` - Get product claims
- `POST /api/products/:id/scan` - Record a scan

### Companies
- `GET /api/companies` - List all companies
- `GET /api/companies/:id` - Get company details
- `GET /api/companies/:id/ownership` - Get ownership chain
- `GET /api/companies/:id/brands` - Get company brands
- `GET /api/companies/:id/products` - Get company products

### Alternatives
- `GET /api/alternatives/product/:productId` - Get alternatives for product
- `GET /api/alternatives/category/:categoryId` - Get alternatives by category
- `GET /api/alternatives/top` - Get top alternatives

### Stores
- `GET /api/stores` - List all stores
- `GET /api/stores/city/:city` - Get stores by city
- `GET /api/stores/product/:alternativeId` - Get stores for alternative
- `POST /api/stores/confirm` - Confirm availability (auth required)
- `POST /api/stores/price` - Update price (auth required)

### Search
- `GET /api/search?q=query` - Search everything
- `GET /api/search/products` - Search products
- `GET /api/search/companies` - Search companies
- `GET /api/search/brands` - Search brands
- `GET /api/search/categories` - Get all categories

### Community
- `GET /api/submissions` - List submissions
- `GET /api/submissions/:id` - Get submission details
- `GET /api/submissions/user/mine` - Get my submissions
- `POST /api/submissions` - Create submission (auth required)
- `POST /api/submissions/:id/vote` - Vote on submission (auth required)

### Users
- `GET /api/users/leaderboard` - Get leaderboard
- `GET /api/users/:id` - Get user profile
- `GET /api/users/:id/stats` - Get user stats
- `GET /api/users/:id/badges` - Get user badges

## Database Schema

See `prisma/schema.prisma` for the complete database schema.

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run db:generate` - Generate Prisma client
- `npm run db:push` - Push schema to database
- `npm run db:migrate` - Run migrations
- `npm run db:seed` - Seed database
- `npm run db:studio` - Open Prisma Studio

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| DATABASE_URL | PostgreSQL connection string | - |
| JWT_SECRET | Secret for JWT signing | - |
| JWT_EXPIRES_IN | JWT expiration time | 7d |
| PORT | Server port | 3000 |
| NODE_ENV | Environment | development |
| CORS_ORIGIN | Allowed CORS origin | http://localhost:5173 |

## License

ISC

