import { Router } from 'express';
import { authenticate } from '../../middleware/auth.js';
import { getMyProfile } from './profile.controller.js';

const router = Router();

router.get('/me', authenticate, getMyProfile);

export default router;
