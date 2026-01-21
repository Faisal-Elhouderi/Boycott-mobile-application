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

type AlternativeWithRelations = Prisma.AlternativeGetPayload<{
  include: {
    alternative: {
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
  const brand = product.brand;
  const company = brand.company;
  const name = product.nameAr || product.nameEn;
  const description = product.descriptionAr || product.description || null;

  return {
    id: product.id,
    name,
    brand: brand.nameEn,
    company: company.nameEn,
    category: product.category?.nameAr || null,
    description,
    reason: description,
    iconKey: product.category?.icon || product.imageUrl || null,
    verdictLabel: product.verdictLabel,
  };
};

const buildAlternativeSummary = (alternative: AlternativeWithRelations) => {
  const product = alternative.alternative;
  const brand = product.brand;
  const company = brand.company;
  const name = product.nameAr || product.nameEn;
  const description = product.descriptionAr || product.description || null;

  return {
    id: product.id,
    name,
    brand: brand.nameEn,
    company: company.nameEn,
    category: product.category?.nameAr || null,
    description,
    reason: description,
    iconKey: product.category?.icon || product.imageUrl || null,
    verdictLabel: product.verdictLabel,
    isExactAlternative: alternative.isExactAlternative,
  };
};

export const getAllProducts = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', category, verdict, search } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const filters: Prisma.ProductWhereInput[] = [];

    if (category) {
      const categoryValue = normalize(category);
      filters.push({
        OR: [
          { categoryId: categoryValue },
          { category: { nameAr: { equals: categoryValue } } },
          { category: { nameEn: { equals: categoryValue } } },
        ],
      });
    }

    if (verdict) {
      filters.push({ verdictLabel: verdict as string });
    }

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

    const where: Prisma.ProductWhereInput = filters.length ? { AND: filters } : {};

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

export const getProductByBarcode = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { barcode } = req.params;

    const product = await prisma.product.findUnique({
      where: { barcode },
      include: {
        brand: {
          include: {
            company: true,
          },
        },
        category: true,
        alternatives: {
          include: {
            alternative: {
              include: {
                brand: { include: { company: true } },
                category: true,
              },
            },
          },
        },
      },
    });

    if (!product) {
      throw createError('المنتج غير موجود', 404, 'NOT_FOUND');
    }

    const response = {
      product: buildProductSummary(product),
      alternatives: product.alternatives.map(buildAlternativeSummary),
    };

    return sendSuccess(res, response);
  } catch (error) {
    next(error);
  }
};

export const getProductById = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        brand: {
          include: {
            company: true,
          },
        },
        category: true,
        alternatives: {
          include: {
            alternative: {
              include: {
                brand: { include: { company: true } },
                category: true,
              },
            },
          },
        },
      },
    });

    if (!product) {
      throw createError('المنتج غير موجود', 404, 'NOT_FOUND');
    }

    const response = {
      product: buildProductSummary(product),
      alternatives: product.alternatives.map(buildAlternativeSummary),
    };

    return sendSuccess(res, response);
  } catch (error) {
    next(error);
  }
};

export const createProduct = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const data = req.body;

    const product = await prisma.product.create({
      data: {
        barcode: data.barcode,
        nameEn: data.nameEn,
        nameAr: data.nameAr,
        aliases: data.aliases || [],
        description: data.description,
        descriptionAr: data.descriptionAr,
        imageUrl: data.imageUrl,
        images: data.images || [],
        brandId: data.brandId,
        categoryId: data.categoryId,
        verdictLabel: data.verdictLabel || 'UNKNOWN',
        status: data.status || 'UNDER_REVIEW',
        confidence: data.confidence || 'LOW',
      },
      include: {
        brand: {
          include: {
            company: true,
          },
        },
        category: true,
      },
    });

    await prisma.productChangelog.create({
      data: {
        productId: product.id,
        field: 'created',
        newValue: JSON.stringify(data),
        changedBy: req.user?.id,
        reason: 'Initial creation',
      },
    });

    return sendSuccess(res, buildProductSummary(product), 201);
  } catch (error) {
    next(error);
  }
};

export const updateProduct = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const data = req.body;

    const existing = await prisma.product.findUnique({ where: { id } });
    if (!existing) {
      throw createError('المنتج غير موجود', 404, 'NOT_FOUND');
    }

    const product = await prisma.product.update({
      where: { id },
      data: {
        ...(data.barcode && { barcode: data.barcode }),
        ...(data.nameEn && { nameEn: data.nameEn }),
        ...(data.nameAr && { nameAr: data.nameAr }),
        ...(data.aliases && { aliases: data.aliases }),
        ...(data.description && { description: data.description }),
        ...(data.descriptionAr && { descriptionAr: data.descriptionAr }),
        ...(data.imageUrl && { imageUrl: data.imageUrl }),
        ...(data.images && { images: data.images }),
        ...(data.brandId && { brandId: data.brandId }),
        ...(data.categoryId && { categoryId: data.categoryId }),
        ...(data.verdictLabel && { verdictLabel: data.verdictLabel }),
        ...(data.status && { status: data.status }),
        ...(data.confidence && { confidence: data.confidence }),
        lastReviewedAt: new Date(),
      },
      include: {
        brand: {
          include: {
            company: true,
          },
        },
        category: true,
      },
    });

    await prisma.productChangelog.create({
      data: {
        productId: product.id,
        field: 'updated',
        oldValue: JSON.stringify(existing),
        newValue: JSON.stringify(data),
        changedBy: req.user?.id,
        reason: data.reason || 'Update',
      },
    });

    return sendSuccess(res, buildProductSummary(product));
  } catch (error) {
    next(error);
  }
};

export const getProductAlternatives = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const alternatives = await prisma.alternative.findMany({
      where: { productId: id },
      include: {
        alternative: {
          include: {
            brand: { include: { company: true } },
            category: true,
          },
        },
      },
    });

    return sendSuccess(res, alternatives.map(buildAlternativeSummary));
  } catch (error) {
    next(error);
  }
};

export const getProductClaims = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const claims = await prisma.productClaim.findMany({
      where: { productId: id },
      include: {
        claim: {
          include: {
            evidenceSources: true,
          },
        },
      },
    });

    return sendSuccess(res, claims.map((pc) => pc.claim));
  } catch (error) {
    next(error);
  }
};

export const recordScan = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { sessionId } = req.body;

    await prisma.scanHistory.create({
      data: {
        productId: id,
        userId: req.user?.id,
        sessionId: !req.user ? sessionId : undefined,
      },
    });

    return sendSuccess(res, { message: 'تم تسجيل المسح' });
  } catch (error) {
    next(error);
  }
};
