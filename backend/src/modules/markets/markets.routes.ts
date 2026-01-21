import { Router } from 'express';
import { listMarkets } from './markets.controller.js';

const router = Router();

router.get('/', listMarkets);

export default router;
