import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { getLeaderboard as getLeaderboardService, getPointsHistory, REPUTATION_LEVELS } from '../../services/scoring.js';

export const getUserProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        displayName: true,
        displayNameAr: true,
        avatar: true,
        city: true,
        role: true,
        reputationLevel: true,
        scoreTotal: true,
        createdAt: true,
        badges: {
          include: {
            badge: true,
          },
        },
        _count: {
          select: {
            submissions: true,
            storeConfirmations: true,
            scanHistory: true,
          },
        },
      },
    });

    if (!user) {
      throw createError('User not found', 404);
    }

    // Add reputation level info
    const levelInfo = REPUTATION_LEVELS[user.reputationLevel as keyof typeof REPUTATION_LEVELS];

    res.json({
      success: true,
      data: {
        ...user,
        levelInfo,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getUserStats = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    // Get various stats
    const [
      totalScans,
      thisWeekScans,
      submissionsApproved,
      confirmations,
    ] = await Promise.all([
      prisma.scanHistory.count({ where: { userId: id } }),
      prisma.scanHistory.count({
        where: {
          userId: id,
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
          },
        },
      }),
      prisma.submission.count({
        where: {
          submitterId: id,
          status: 'APPROVED',
        },
      }),
      prisma.storeAvailability.count({
        where: { confirmedById: id },
      }),
    ]);

    // Get scan history with verdict breakdown
    const scansByVerdict = await prisma.scanHistory.groupBy({
      by: ['productId'],
      where: { userId: id },
      _count: true,
    });

    // Get products to get verdict counts
    const productIds = scansByVerdict.map((s) => s.productId);
    const products = await prisma.product.findMany({
      where: { id: { in: productIds } },
      select: { verdictLabel: true },
    });

    const verdictCounts = products.reduce((acc, p) => {
      acc[p.verdictLabel] = (acc[p.verdictLabel] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    res.json({
      success: true,
      data: {
        totalScans,
        thisWeekScans,
        submissionsApproved,
        confirmations,
        verdictCounts,
        impactEstimate: {
          productsAvoided: verdictCounts.AVOID || 0,
          cautionProducts: verdictCounts.CAUTION || 0,
          preferredFound: verdictCounts.PREFERRED || 0,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getUserBadges = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const userBadges = await prisma.userBadge.findMany({
      where: { userId: id },
      include: {
        badge: true,
      },
      orderBy: { earnedAt: 'desc' },
    });

    // Get all available badges to show progress
    const allBadges = await prisma.badge.findMany();

    const earnedBadgeIds = new Set(userBadges.map((ub) => ub.badgeId));

    res.json({
      success: true,
      data: {
        earned: userBadges,
        available: allBadges.filter((b) => !earnedBadgeIds.has(b.id)),
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getLeaderboard = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { limit = '20', period = 'all' } = req.query;
    const limitNum = Math.min(parseInt(limit as string), 100);

    // For now, return all-time leaderboard
    // TODO: Add period filtering (weekly, monthly)
    const leaderboard = await getLeaderboardService(limitNum);

    res.json({
      success: true,
      data: {
        leaderboard,
        period,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getUserActivity = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { limit = '50' } = req.query;
    const limitNum = Math.min(parseInt(limit as string), 100);

    // Only allow users to see their own activity or admins
    if (req.user!.id !== id && req.user!.role !== 'ADMIN') {
      throw createError('Unauthorized', 403);
    }

    const pointsHistory = await getPointsHistory(id, limitNum);

    // Get recent scans
    const recentScans = await prisma.scanHistory.findMany({
      where: { userId: id },
      include: {
        product: {
          include: {
            brand: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });

    res.json({
      success: true,
      data: {
        pointsHistory,
        recentScans,
      },
    });
  } catch (error) {
    next(error);
  }
};

