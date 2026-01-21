import { Router } from 'express';
import { searchAll, searchProducts, searchCompanies, searchBrands, getCategories } from './search.controller.js';

const router = Router();

// Search routes
router.get('/', searchAll);
router.get('/products', searchProducts);
router.get('/companies', searchCompanies);
router.get('/brands', searchBrands);
router.get('/categories', getCategories);

export default router;

