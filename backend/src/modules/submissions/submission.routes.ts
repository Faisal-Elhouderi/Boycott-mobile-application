import { Router } from 'express';
import {
  getAllSubmissions,
  getSubmissionById,
  getMySubmissions,
  createSubmission,
  voteOnSubmission,
  moderateSubmission,
} from './submission.controller.js';
import { authenticate, requireRole } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { createSubmissionSchema, voteSchema, moderateSchema } from './submission.validation.js';

const router = Router();

// Public routes
router.get('/', getAllSubmissions);
router.get('/:id', getSubmissionById);

// Protected routes (authenticated users)
router.get('/user/mine', authenticate, getMySubmissions);
router.post('/', authenticate, validateRequest(createSubmissionSchema), createSubmission);
router.post('/:id/vote', authenticate, validateRequest(voteSchema), voteOnSubmission);

// Moderator routes
router.post('/:id/moderate', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(moderateSchema), moderateSubmission);

export default router;

