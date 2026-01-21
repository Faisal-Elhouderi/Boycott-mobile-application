import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import routes
import authRoutes from './modules/auth/auth.routes.js';
import productRoutes from './modules/products/product.routes.js';
import companyRoutes from './modules/companies/company.routes.js';
import alternativeRoutes from './modules/alternatives/alternative.routes.js';
import communityRoutes from './modules/community/community.routes.js';
import profileRoutes from './modules/profile/profile.routes.js';
import marketRoutes from './modules/markets/markets.routes.js';
import storeRoutes from './modules/stores/store.routes.js';
import submissionRoutes from './modules/submissions/submission.routes.js';
import userRoutes from './modules/users/user.routes.js';
import searchRoutes from './modules/search/search.routes.js';
import itemRoutes from './modules/items/items.routes.js';
import reportRoutes from './modules/reports/reports.routes.js';

// Import middleware
import { errorHandler } from './middleware/errorHandler.js';
import { notFoundHandler } from './middleware/notFoundHandler.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
const allowedOrigins = (process.env.CORS_ORIGIN || 'http://localhost:5173,http://127.0.0.1:5173')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || origin === 'null') {
      return callback(null, true);
    }
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/companies', companyRoutes);
app.use('/api/alternatives', alternativeRoutes);
app.use('/api/community', communityRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/markets', marketRoutes);
app.use('/api/stores', storeRoutes);
app.use('/api/submissions', submissionRoutes);
app.use('/api/users', userRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/reports', reportRoutes);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log('Boycott API running on http://localhost:' + PORT);
  console.log('Health check: http://localhost:' + PORT + '/health');
});

export default app;
