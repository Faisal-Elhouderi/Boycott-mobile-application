import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { sendSuccess } from '../../middleware/response.js';

const normalize = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

type SuggestionWithCounts = Prisma.CommunitySuggestionGetPayload<{
  include: {
    _count: { select: { likes: true } };
    user: { select: { id: true; displayName: true } };
  };
}>;

const buildSuggestionSummary = (suggestion: SuggestionWithCounts) => ({
  id: suggestion.id,
  text: suggestion.textAr,
  companyName: suggestion.companyName,
  likesCount: suggestion._count.likes,
  createdAt: suggestion.createdAt,
  author: {
    id: suggestion.user.id,
    name: suggestion.user.displayName,
  },
});

export const createSuggestion = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const text = normalize(req.body.text);
    const companyName = normalize(req.body.companyName) || null;

    if (!text) {
      throw createError('نص الاقتراح مطلوب', 400, 'BAD_REQUEST');
    }

    const suggestion = await prisma.communitySuggestion.create({
      data: {
        textAr: text,
        companyName,
        userId: req.user!.id,
      },
      include: {
        _count: { select: { likes: true } },
        user: { select: { id: true, displayName: true } },
      },
    });

    return sendSuccess(res, buildSuggestionSummary(suggestion), 201);
  } catch (error) {
    next(error);
  }
};

export const listSuggestions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', sort = 'top' } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = Math.min(parseInt(limit as string, 10), 100);
    const skip = (pageNum - 1) * limitNum;

    const sortValue = sort === 'new' ? 'new' : 'top';
    const orderBy = sortValue === 'new'
      ? [{ createdAt: 'desc' as const }]
      : [{ likes: { _count: 'desc' as const } }, { createdAt: 'desc' as const }];

    const [suggestions, total] = await Promise.all([
      prisma.communitySuggestion.findMany({
        skip,
        take: limitNum,
        include: {
          _count: { select: { likes: true } },
          user: { select: { id: true, displayName: true } },
        },
        orderBy,
      }),
      prisma.communitySuggestion.count(),
    ]);

    const items = suggestions.map(buildSuggestionSummary);

    return sendSuccess(res, items, 200, {
      count: total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error) {
    next(error);
  }
};

export const toggleSuggestionLike = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const suggestion = await prisma.communitySuggestion.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!suggestion) {
      throw createError('الاقتراح غير موجود', 404, 'NOT_FOUND');
    }

    const existingLike = await prisma.suggestionLike.findUnique({
      where: {
        suggestionId_userId: {
          suggestionId: id,
          userId: req.user!.id,
        },
      },
    });

    let liked = false;

    if (existingLike) {
      await prisma.suggestionLike.delete({
        where: { id: existingLike.id },
      });
      liked = false;
    } else {
      await prisma.suggestionLike.create({
        data: {
          suggestionId: id,
          userId: req.user!.id,
        },
      });
      liked = true;
    }

    const likesCount = await prisma.suggestionLike.count({
      where: { suggestionId: id },
    });

    return sendSuccess(res, {
      suggestionId: id,
      liked,
      likesCount,
    });
  } catch (error) {
    next(error);
  }
};
