import { Router } from 'express';
import {
  getAllCompanies,
  getCompanyById,
  getCompanyOwnership,
  getCompanyBrands,
  getCompanyProducts,
  createCompany,
  updateCompany,
} from './company.controller.js';
import { authenticate, requireRole } from '../../middleware/auth.js';
import { validateRequest } from '../../middleware/validate.js';
import { createCompanySchema, updateCompanySchema } from './company.validation.js';

const router = Router();

// Public routes
router.get('/', getAllCompanies);
router.get('/:id', getCompanyById);
router.get('/:id/ownership', getCompanyOwnership);
router.get('/:id/brands', getCompanyBrands);
router.get('/:id/products', getCompanyProducts);

// Protected routes
router.post('/', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(createCompanySchema), createCompany);
router.patch('/:id', authenticate, requireRole('MODERATOR', 'ADMIN'), validateRequest(updateCompanySchema), updateCompany);

export default router;

