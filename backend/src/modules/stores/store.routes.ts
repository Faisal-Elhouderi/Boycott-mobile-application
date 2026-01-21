import { Router } from 'express';
import {
  getAllStores,
  getStoreById,
  getStoresByCity,
  getStoresForProduct,
  createStore,
  updateStore,
  confirmAvailability,
  updatePrice,
} from './store.controller.js';
import { authenticate, requireRole } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { createStoreSchema, updateStoreSchema, confirmAvailabilitySchema, updatePriceSchema } from './store.validation.js';

const router = Router();

// Public routes
router.get('/', getAllStores);
router.get('/city/:city', getStoresByCity);
router.get('/product/:alternativeId', getStoresForProduct);
router.get('/:id', getStoreById);

// Protected routes (any authenticated user can confirm availability)
router.post('/confirm', authenticate, validateRequest(confirmAvailabilitySchema), confirmAvailability);
router.post('/price', authenticate, validateRequest(updatePriceSchema), updatePrice);

// Admin/Moderator routes
router.post('/', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(createStoreSchema), createStore);
router.patch('/:id', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(updateStoreSchema), updateStore);

export default router;

