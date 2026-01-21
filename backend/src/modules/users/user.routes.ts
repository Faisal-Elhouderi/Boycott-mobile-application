import { Router } from 'express';
import {
  getUserProfile,
  getUserStats,
  getUserBadges,
  getLeaderboard,
  getUserActivity,
} from './user.controller.js';
import { authenticate } from '../../middleware/auth.js';

const router = Router();

// Public routes
router.get('/leaderboard', getLeaderboard);
router.get('/:id', getUserProfile);
router.get('/:id/stats', getUserStats);
router.get('/:id/badges', getUserBadges);

// Protected routes
router.get('/:id/activity', authenticate, getUserActivity);

export default router;

