import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';

export const searchAll = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, limit = '10' } = req.query;
    const limitNum = Math.min(parseInt(limit as string), 50);

    if (!q || typeof q !== 'string') {
      return res.json({
        success: true,
        data: { products: [], companies: [], brands: [] },
      });
    }

    const searchTerm = q.trim();

    // Check if it looks like a barcode (numeric, 8-13 digits)
    const isBarcode = /^\d{8,13}$/.test(searchTerm);

    const [products, companies, brands] = await Promise.all([
      // Search products
      prisma.product.findMany({
        where: isBarcode
          ? { barcode: searchTerm }
          : {
              OR: [
                { nameEn: { contains: searchTerm, mode: 'insensitive' } },
                { nameAr: { contains: searchTerm } },
                { aliases: { has: searchTerm } },
                { barcode: { contains: searchTerm } },
              ],
            },
        include: {
          brand: {
            include: {
              company: {
                select: {
                  id: true,
                  nameEn: true,
                  nameAr: true,
                  verdictLabel: true,
                },
              },
            },
          },
          category: true,
        },
        take: limitNum,
      }),

      // Search companies
      prisma.company.findMany({
        where: {
          OR: [
            { nameEn: { contains: searchTerm, mode: 'insensitive' } },
            { nameAr: { contains: searchTerm } },
            { aliases: { has: searchTerm } },
          ],
        },
        include: {
          _count: {
            select: { brands: true },
          },
        },
        take: limitNum,
      }),

      // Search brands
      prisma.brand.findMany({
        where: {
          OR: [
            { nameEn: { contains: searchTerm, mode: 'insensitive' } },
            { nameAr: { contains: searchTerm } },
            { aliases: { has: searchTerm } },
          ],
        },
        include: {
          company: {
            select: {
              id: true,
              nameEn: true,
              nameAr: true,
              verdictLabel: true,
            },
          },
        },
        take: limitNum,
      }),
    ]);

    res.json({
      success: true,
      data: {
        products,
        companies,
        brands,
        query: searchTerm,
        isBarcode,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const searchProducts = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, category, verdict, page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};

    if (q && typeof q === 'string') {
      where.OR = [
        { nameEn: { contains: q, mode: 'insensitive' } },
        { nameAr: { contains: q } },
        { aliases: { has: q } },
        { barcode: { contains: q } },
      ];
    }

    if (category) where.categoryId = category;
    if (verdict) where.verdictLabel = verdict;

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          brand: {
            include: {
              company: {
                select: {
                  id: true,
                  nameEn: true,
                  nameAr: true,
                  verdictLabel: true,
                },
              },
            },
          },
          category: true,
        },
        orderBy: { nameEn: 'asc' },
      }),
      prisma.product.count({ where }),
    ]);

    res.json({
      success: true,
      data: {
        products,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const searchCompanies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, verdict, page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};

    if (q && typeof q === 'string') {
      where.OR = [
        { nameEn: { contains: q, mode: 'insensitive' } },
        { nameAr: { contains: q } },
        { aliases: { has: q } },
      ];
    }

    if (verdict) where.verdictLabel = verdict;

    const [companies, total] = await Promise.all([
      prisma.company.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          parent: {
            select: {
              id: true,
              nameEn: true,
              nameAr: true,
            },
          },
          _count: {
            select: { brands: true, subsidiaries: true },
          },
        },
        orderBy: { nameEn: 'asc' },
      }),
      prisma.company.count({ where }),
    ]);

    res.json({
      success: true,
      data: {
        companies,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const searchBrands = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { q, companyId, page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};

    if (q && typeof q === 'string') {
      where.OR = [
        { nameEn: { contains: q, mode: 'insensitive' } },
        { nameAr: { contains: q } },
        { aliases: { has: q } },
      ];
    }

    if (companyId) where.companyId = companyId;

    const [brands, total] = await Promise.all([
      prisma.brand.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          company: {
            select: {
              id: true,
              nameEn: true,
              nameAr: true,
              verdictLabel: true,
            },
          },
          _count: {
            select: { products: true },
          },
        },
        orderBy: { nameEn: 'asc' },
      }),
      prisma.brand.count({ where }),
    ]);

    res.json({
      success: true,
      data: {
        brands,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getCategories = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const categories = await prisma.category.findMany({
      where: { parentId: null },
      include: {
        children: {
          orderBy: { sortOrder: 'asc' },
        },
        _count: {
          select: { products: true },
        },
      },
      orderBy: { sortOrder: 'asc' },
    });

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    next(error);
  }
};

