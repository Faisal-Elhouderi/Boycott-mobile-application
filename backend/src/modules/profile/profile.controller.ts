import { Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { sendSuccess } from '../../middleware/response.js';

export const getMyProfile = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: {
        id: true,
        email: true,
        displayName: true,
      },
    });

    if (!user) {
      throw createError('المستخدم غير موجود', 404, 'NOT_FOUND');
    }

    const [reportsCount, suggestionsCount, likesGiven] = await Promise.all([
      prisma.report.count({ where: { userId: user.id } }),
      prisma.communitySuggestion.count({ where: { userId: user.id } }),
      prisma.suggestionLike.count({ where: { userId: user.id } }),
    ]);

    return sendSuccess(res, {
      user: {
        id: user.id,
        email: user.email,
        name: user.displayName,
      },
      activities: {
        reports: reportsCount,
        suggestions: suggestionsCount,
        likesGiven,
      },
    });
  } catch (error) {
    next(error);
  }
};
