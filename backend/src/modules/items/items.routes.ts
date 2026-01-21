import { Router } from 'express';
import { getItems, getItemById } from './items.controller.js';

const router = Router();

router.get('/', getItems);
router.get('/:id', getItemById);

export default router;
