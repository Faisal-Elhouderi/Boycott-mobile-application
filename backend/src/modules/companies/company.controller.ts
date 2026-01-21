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

type CompanySummary = {
  id: string;
  name: string;
  description: string | null;
  country: string | null;
  verdictLabel: string;
  iconKey: string | null;
};

const buildCompanySummary = (company: {
  id: string;
  nameEn: string;
  description?: string | null;
  descriptionAr?: string | null;
  country?: string | null;
  verdictLabel: string;
  logoUrl?: string | null;
}): CompanySummary => ({
  id: company.id,
  name: company.nameEn,
  description: company.descriptionAr || company.description || null,
  country: company.country || null,
  verdictLabel: company.verdictLabel,
  iconKey: company.logoUrl || null,
});

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

export const getAllCompanies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', search } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: Prisma.CompanyWhereInput = {};
    if (search) {
      const term = normalize(search);
      where.OR = [
        { nameEn: { contains: term, mode: 'insensitive' } },
        { aliases: { has: term } },
      ];
    }

    const [companies, total] = await Promise.all([
      prisma.company.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { nameEn: 'asc' },
      }),
      prisma.company.count({ where }),
    ]);

    const items = companies.map(buildCompanySummary);

    return sendSuccess(res, items, 200, {
      count: total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error) {
    next(error);
  }
};

export const getCompanyById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const company = await prisma.company.findUnique({
      where: { id },
    });

    const resolved = company
      ? company
      : await prisma.company.findFirst({
          where: {
            OR: [
              { nameEn: { equals: id, mode: 'insensitive' } },
              { aliases: { has: id } },
            ],
          },
        });

    if (!resolved) {
      throw createError('الشركة غير موجودة', 404, 'NOT_FOUND');
    }

    const products = await prisma.product.findMany({
      where: {
        brand: { companyId: resolved.id },
      },
      include: {
        brand: { include: { company: true } },
        category: true,
      },
      orderBy: { updatedAt: 'desc' },
    });

    return sendSuccess(res, {
      company: buildCompanySummary(resolved),
      products: products.map(buildProductSummary),
    });
  } catch (error) {
    next(error);
  }
};

const buildOwnershipChain = async (companyId: string, visited: Set<string> = new Set()): Promise<any> => {
  if (visited.has(companyId)) return null;
  visited.add(companyId);

  const company = await prisma.company.findUnique({
    where: { id: companyId },
    select: {
      id: true,
      nameEn: true,
      nameAr: true,
      logoUrl: true,
      verdictLabel: true,
      status: true,
      parentId: true,
      brands: {
        select: {
          id: true,
          nameEn: true,
          nameAr: true,
          logoUrl: true,
        },
      },
    },
  });

  if (!company) return null;

  let parent = null;
  if (company.parentId) {
    parent = await buildOwnershipChain(company.parentId, visited);
  }

  return {
    ...company,
    parent,
  };
};

const getSiblingBrands = async (companyId: string): Promise<any[]> => {
  const company = await prisma.company.findUnique({
    where: { id: companyId },
    include: { parent: true },
  });

  if (!company?.parentId) return [];

  const siblings = await prisma.brand.findMany({
    where: {
      company: {
        parentId: company.parentId,
        NOT: { id: companyId },
      },
    },
    select: {
      id: true,
      nameEn: true,
      nameAr: true,
      logoUrl: true,
      company: {
        select: {
          id: true,
          nameEn: true,
          nameAr: true,
        },
      },
    },
    take: 20,
  });

  return siblings;
};

export const getCompanyOwnership = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const [ownershipChain, alsoOwns] = await Promise.all([
      buildOwnershipChain(id),
      getSiblingBrands(id),
    ]);

    if (!ownershipChain) {
      throw createError('الشركة غير موجودة', 404, 'NOT_FOUND');
    }

    return sendSuccess(res, {
      chain: ownershipChain,
      alsoOwns,
    });
  } catch (error) {
    next(error);
  }
};

export const getCompanyBrands = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const brands = await prisma.brand.findMany({
      where: { companyId: id },
      include: {
        _count: {
          select: { products: true },
        },
      },
    });

    return sendSuccess(res, brands);
  } catch (error) {
    next(error);
  }
};

export const getCompanyProducts = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where: {
          brand: { companyId: id },
        },
        skip,
        take: limitNum,
        include: {
          brand: { include: { company: true } },
          category: true,
        },
      }),
      prisma.product.count({
        where: { brand: { companyId: id } },
      }),
    ]);

    return sendSuccess(res, products.map(buildProductSummary), 200, {
      count: total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error) {
    next(error);
  }
};

export const createCompany = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const data = req.body;

    const company = await prisma.company.create({
      data: {
        nameEn: data.nameEn,
        nameAr: data.nameAr,
        aliases: data.aliases || [],
        country: data.country,
        logoUrl: data.logoUrl,
        websiteUrl: data.websiteUrl,
        description: data.description,
        descriptionAr: data.descriptionAr,
        parentId: data.parentId,
        verdictLabel: data.verdictLabel || 'UNKNOWN',
        status: data.status || 'UNDER_REVIEW',
        confidence: data.confidence || 'LOW',
      },
    });

    await prisma.companyChangelog.create({
      data: {
        companyId: company.id,
        field: 'created',
        newValue: JSON.stringify(data),
        changedBy: req.user?.id,
        reason: 'Initial creation',
      },
    });

    return sendSuccess(res, buildCompanySummary(company), 201);
  } catch (error) {
    next(error);
  }
};

export const updateCompany = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const data = req.body;

    const existing = await prisma.company.findUnique({ where: { id } });
    if (!existing) {
      throw createError('الشركة غير موجودة', 404, 'NOT_FOUND');
    }

    const company = await prisma.company.update({
      where: { id },
      data: {
        ...(data.nameEn && { nameEn: data.nameEn }),
        ...(data.nameAr && { nameAr: data.nameAr }),
        ...(data.aliases && { aliases: data.aliases }),
        ...(data.country && { country: data.country }),
        ...(data.logoUrl && { logoUrl: data.logoUrl }),
        ...(data.websiteUrl && { websiteUrl: data.websiteUrl }),
        ...(data.description && { description: data.description }),
        ...(data.descriptionAr && { descriptionAr: data.descriptionAr }),
        ...(data.parentId !== undefined && { parentId: data.parentId }),
        ...(data.verdictLabel && { verdictLabel: data.verdictLabel }),
        ...(data.status && { status: data.status }),
        ...(data.confidence && { confidence: data.confidence }),
      },
    });

    await prisma.companyChangelog.create({
      data: {
        companyId: company.id,
        field: 'updated',
        oldValue: JSON.stringify(existing),
        newValue: JSON.stringify(data),
        changedBy: req.user?.id,
        reason: data.reason || 'Update',
      },
    });

    return sendSuccess(res, buildCompanySummary(company));
  } catch (error) {
    next(error);
  }
};
