import { Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { sendSuccess } from '../../middleware/response.js';

const normalize = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

export const createReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const itemId = normalize(req.body.itemId);
    const name = normalize(req.body.name);
    const company = normalize(req.body.company);
    const reason = normalize(req.body.reason);
    const sourceUrl = normalize(req.body.sourceUrl);

    if (!reason) {
      throw createError('السبب مطلوب', 400, 'BAD_REQUEST');
    }

    if (!itemId && !name) {
      throw createError('يرجى تحديد المنتج أو كتابة اسم المنتج', 400, 'BAD_REQUEST');
    }

    let productId: string | undefined;
    if (itemId) {
      const product = await prisma.product.findUnique({
        where: { id: itemId },
        select: { id: true },
      });

      if (!product) {
        throw createError('المنتج غير موجود', 404, 'NOT_FOUND');
      }

      productId = product.id;
    }

    const report = await prisma.report.create({
      data: {
        productId,
        name: name || null,
        company: company || null,
        reason,
        sourceUrl: sourceUrl || null,
        userId: req.user!.id,
      },
    });

    return sendSuccess(res, {
      id: report.id,
      itemId: report.productId,
      name: report.name,
      company: report.company,
      reason: report.reason,
      sourceUrl: report.sourceUrl,
      userId: report.userId,
      createdAt: report.createdAt,
    }, 201);
  } catch (error) {
    next(error);
  }
};

export const getReports = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const limitRaw = typeof req.query.limit === 'string' ? parseInt(req.query.limit, 10) : 50;
    const limit = Number.isFinite(limitRaw) ? Math.min(limitRaw, 100) : 50;

    const reports = await prisma.report.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        product: {
          select: {
            id: true,
            nameEn: true,
            nameAr: true,
            brand: {
              select: {
                nameEn: true,
                company: {
                  select: {
                    nameEn: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    const data = reports.map((report) => ({
      id: report.id,
      itemId: report.productId,
      name: report.name ?? report.product?.nameAr ?? report.product?.nameEn ?? null,
      company: report.company ?? report.product?.brand?.company?.nameEn ?? null,
      reason: report.reason,
      sourceUrl: report.sourceUrl,
      userId: report.userId,
      createdAt: report.createdAt,
    }));

    return sendSuccess(res, data, 200, {
      count: data.length,
    });
  } catch (error) {
    next(error);
  }
};
