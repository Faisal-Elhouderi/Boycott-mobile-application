import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { sendSuccess } from '../../middleware/response.js';

const normalize = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

type ProductWithRelations = Prisma.ProductGetPayload<{
  include: {
    brand: {
      include: {
        company: true;
      };
    };
    category: true;
  };
}>;

type AlternativeLinkWithRelations = Prisma.AlternativeGetPayload<{
  include: {
    product: {
      include: {
        brand: {
          include: {
            company: true;
          };
        };
        category: true;
      };
    };
  };
}>;

const buildProductSummary = (product: ProductWithRelations) => {
  const name = product.nameAr || product.nameEn;
  const description = product.descriptionAr || product.description || null;

  return {
    id: product.id,
    name,
    brand: product.brand.nameEn,
    company: product.brand.company.nameEn,
    category: product.category?.nameAr || null,
    description,
    reason: description,
    iconKey: product.category?.icon || product.imageUrl || null,
    verdictLabel: product.verdictLabel,
  };
};

export const listAlternatives = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', search } = req.query;
    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const filters: Prisma.ProductWhereInput[] = [
      { verdictLabel: 'PREFERRED' },
    ];

    if (search) {
      const term = normalize(search);
      filters.push({
        OR: [
          { nameAr: { contains: term } },
          { nameEn: { contains: term, mode: 'insensitive' } },
          { brand: { nameEn: { contains: term, mode: 'insensitive' } } },
          { brand: { company: { nameEn: { contains: term, mode: 'insensitive' } } } },
        ],
      });
    }

    const where: Prisma.ProductWhereInput = { AND: filters };

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          brand: {
            include: {
              company: true,
            },
          },
          category: true,
        },
        orderBy: { updatedAt: 'desc' },
      }),
      prisma.product.count({ where }),
    ]);

    const items = products.map(buildProductSummary);

    return sendSuccess(res, items, 200, {
      count: total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error) {
    next(error);
  }
};

export const getAlternativeById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const alternative = await prisma.product.findFirst({
      where: {
        id,
        verdictLabel: 'PREFERRED',
      },
      include: {
        brand: { include: { company: true } },
        category: true,
      },
    });

    if (!alternative) {
      throw createError('البديل غير موجود', 404, 'NOT_FOUND');
    }

    const linked = await prisma.alternative.findMany({
      where: { alternativeId: id },
      include: {
        product: {
          include: {
            brand: { include: { company: true } },
            category: true,
          },
        },
      },
    });

    const linkedProducts = linked.map((link: AlternativeLinkWithRelations) => {
      const product = link.product;
      const description = product.descriptionAr || product.description || null;

      return {
        id: product.id,
        name: product.nameAr || product.nameEn,
        brand: product.brand.nameEn,
        company: product.brand.company.nameEn,
        category: product.category?.nameAr || null,
        description,
        reason: description,
        iconKey: product.category?.icon || product.imageUrl || null,
        verdictLabel: product.verdictLabel,
      };
    });

    return sendSuccess(res, {
      alternative: buildProductSummary(alternative),
      linkedProducts,
    });
  } catch (error) {
    next(error);
  }
};

export const getAlternativesByProduct = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { productId } = req.params;

    const alternatives = await prisma.alternative.findMany({
      where: { productId },
      include: {
        alternative: {
          include: {
            brand: {
              include: {
                company: true,
              },
            },
            category: true,
          },
        },
      },
      orderBy: [{ isExactAlternative: 'desc' }],
    });

    const items = alternatives.map((alt) => buildProductSummary(alt.alternative));

    return sendSuccess(res, items);
  } catch (error) {
    next(error);
  }
};

export const getAlternativesByCategory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { categoryId } = req.params;
    const { page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where: {
          categoryId,
          verdictLabel: 'PREFERRED',
        },
        skip,
        take: limitNum,
        include: {
          brand: { include: { company: true } },
          category: true,
        },
        orderBy: { updatedAt: 'desc' },
      }),
      prisma.product.count({
        where: {
          categoryId,
          verdictLabel: 'PREFERRED',
        },
      }),
    ]);

    const items = products.map(buildProductSummary);

    return sendSuccess(res, items, 200, {
      count: total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error) {
    next(error);
  }
};

export const getTopAlternatives = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '10' } = req.query;
    const limitNum = Math.min(parseInt(limit as string, 10), 50);

    const alternatives = await prisma.product.findMany({
      where: {
        verdictLabel: 'PREFERRED',
      },
      include: {
        brand: { include: { company: true } },
        category: true,
      },
      take: limitNum,
      orderBy: { updatedAt: 'desc' },
    });

    const items = alternatives.map(buildProductSummary);

    return sendSuccess(res, items);
  } catch (error) {
    next(error);
  }
};

export const createAlternative = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { productId, alternativeId, isExactAlternative, notes, notesAr } = req.body;

    const [product, altProduct] = await Promise.all([
      prisma.product.findUnique({ where: { id: productId } }),
      prisma.product.findUnique({ where: { id: alternativeId } }),
    ]);

    if (!product) {
      throw createError('المنتج غير موجود', 404, 'NOT_FOUND');
    }
    if (!altProduct) {
      throw createError('البديل غير موجود', 404, 'NOT_FOUND');
    }

    if (altProduct.verdictLabel !== 'PREFERRED') {
      throw createError('يجب أن يكون البديل من المنتجات الموصى بها', 400, 'BAD_REQUEST');
    }

    const alternative = await prisma.alternative.create({
      data: {
        productId,
        alternativeId,
        isExactAlternative: isExactAlternative || false,
        notes,
        notesAr,
      },
      include: {
        product: true,
        alternative: true,
      },
    });

    return sendSuccess(res, alternative, 201);
  } catch (error) {
    next(error);
  }
};

export const deleteAlternative = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    await prisma.alternative.delete({
      where: { id },
    });

    return sendSuccess(res, { message: 'تم حذف البديل' });
  } catch (error) {
    next(error);
  }
};
