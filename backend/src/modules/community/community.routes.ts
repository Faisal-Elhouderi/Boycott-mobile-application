import { Router } from 'express';
import { authenticate } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { createSuggestion, listSuggestions, toggleSuggestionLike } from './community.controller.js';
import { createSuggestionSchema } from './community.validation.js';

const router = Router();

router.get('/suggestions', listSuggestions);
router.post('/suggestions', authenticate, validateRequest(createSuggestionSchema), createSuggestion);
router.post('/suggestions/:id/like', authenticate, toggleSuggestionLike);

export default router;
