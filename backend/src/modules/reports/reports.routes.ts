import { Router } from 'express';
import { createReport, getReports } from './reports.controller.js';
import { authenticate } from '../../middleware/auth.js';

const router = Router();

router.get('/', getReports);
router.post('/', authenticate, createReport);

export default router;
