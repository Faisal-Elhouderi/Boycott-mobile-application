import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';

type ItemProduct = Prisma.ProductGetPayload<{
  include: {
    brand: {
      include: {
        company: {
          include: {
            claims: {
              include: {
                claim: {
                  include: {
                    evidenceSources: true;
                  };
                };
              };
            };
          };
        };
      };
    };
    category: true;
  };
}>;

const buildItem = (product: ItemProduct) => {
  const company = product.brand?.company ?? null;
  const firstClaim = company?.claims?.[0]?.claim ?? null;
  const firstSource = firstClaim?.evidenceSources?.[0] ?? null;

  return {
    id: product.id,
    name: product.nameEn,
    brand: product.brand?.nameEn ?? null,
    company: company?.nameEn ?? null,
    category: product.category?.nameEn ?? null,
    country: company?.country ?? null,
    reason: firstClaim?.descriptionEn ?? product.description ?? null,
    sourceUrl: firstSource?.url ?? null,
    isBoycotted: product.verdictLabel === 'AVOID',
    updatedAt: product.updatedAt,
  };
};

export const getItems = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
    const category = typeof req.query.category === 'string' ? req.query.category.trim() : '';

    const filters: Prisma.ProductWhereInput[] = [];
    if (search) {
      filters.push({
        OR: [
          { nameEn: { contains: search, mode: 'insensitive' } },
          { brand: { nameEn: { contains: search, mode: 'insensitive' } } },
          { brand: { company: { nameEn: { contains: search, mode: 'insensitive' } } } },
        ],
      });
    }

    if (category) {
      filters.push({
        OR: [
          { categoryId: category },
          { category: { nameEn: { equals: category, mode: 'insensitive' } } },
        ],
      });
    }

    const where: Prisma.ProductWhereInput = filters.length ? { AND: filters } : {};

    const products = await prisma.product.findMany({
      where,
      include: {
        brand: {
          include: {
            company: {
              include: {
                claims: {
                  include: {
                    claim: {
                      include: {
                        evidenceSources: true,
                      },
                    },
                  },
                  take: 1,
                },
              },
            },
          },
        },
        category: true,
      },
      orderBy: { updatedAt: 'desc' },
    });

    const items = products.map(buildItem);

    res.json({
      data: items,
      meta: {
        count: items.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getItemById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        brand: {
          include: {
            company: {
              include: {
                claims: {
                  include: {
                    claim: {
                      include: {
                        evidenceSources: true,
                      },
                    },
                  },
                  take: 1,
                },
              },
            },
          },
        },
        category: true,
      },
    });

    if (!product) {
      throw createError('Item not found', 404, 'NOT_FOUND');
    }

    res.json({
      data: buildItem(product),
    });
  } catch (error) {
    next(error);
  }
};
