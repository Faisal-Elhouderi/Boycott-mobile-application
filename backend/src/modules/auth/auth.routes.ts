import { Router } from 'express';
import { register, login, getMe, updateProfile } from './auth.controller.js';
import { authenticate } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { registerSchema, loginSchema, updateProfileSchema } from './auth.validation.js';

const router = Router();

// Public routes
router.post('/register', validateRequest(registerSchema), register);
router.post('/login', validateRequest(loginSchema), login);

// Protected routes
router.get('/me', authenticate, getMe);
router.patch('/me', authenticate, validateRequest(updateProfileSchema), updateProfile);

export default router;

