import { Router } from 'express';
import {
  getProductByBarcode,
  getProductById,
  getAllProducts,
  createProduct,
  updateProduct,
  getProductAlternatives,
  getProductClaims,
  recordScan,
} from './product.controller.js';
import { authenticate, optionalAuth, requireRole } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { createProductSchema, updateProductSchema } from './product.validation.js';

const router = Router();

// Public routes (with optional auth for scan tracking)
router.get('/', getAllProducts);
router.get('/barcode/:barcode', optionalAuth, getProductByBarcode);
router.get('/:id', optionalAuth, getProductById);
router.get('/:id/alternatives', getProductAlternatives);
router.get('/:id/claims', getProductClaims);

// Record scan (optional auth - tracks for logged in users)
router.post('/:id/scan', optionalAuth, recordScan);

// Protected routes (moderator/admin only)
router.post('/', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(createProductSchema), createProduct);
router.patch('/:id', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(updateProductSchema), updateProduct);

export default router;

