import { prisma } from '../database/client.js';

// Point values for different actions
export const POINTS = {
  submission_created: 5,
  submission_approved: 25,
  submission_rejected_spam: -5,
  evidence_accepted: 10,
  store_confirmation: 2,
  price_update: 2,
  error_report_accepted: 8,
  duplicate_merged: 1,
} as const;

// Reputation level thresholds
export const REPUTATION_LEVELS = {
  0: { name: 'New User', nameAr: 'مستخدم جديد', minPoints: 0 },
  1: { name: 'Contributor', nameAr: 'مساهم', minPoints: 50 },
  2: { name: 'Trusted Contributor', nameAr: 'مساهم موثوق', minPoints: 200 },
  3: { name: 'Power Contributor', nameAr: 'مساهم متميز', minPoints: 500 },
} as const;

export const addPoints = async (
  userId: string,
  points: number,
  reason: string,
  referenceId?: string
): Promise<void> => {
  // Create ledger entry
  await prisma.scoreLedgerEntry.create({
    data: {
      userId,
      points,
      reason,
      referenceId,
    },
  });

  // Update user total and check for level up
  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      scoreTotal: { increment: points },
    },
    select: {
      scoreTotal: true,
      reputationLevel: true,
    },
  });

  // Check if user should level up
  const newLevel = calculateLevel(user.scoreTotal);
  if (newLevel > user.reputationLevel) {
    await prisma.user.update({
      where: { id: userId },
      data: {
        reputationLevel: newLevel,
        role: newLevel >= 2 ? 'TRUSTED_CONTRIBUTOR' : undefined,
      },
    });
  }
};

export const calculateLevel = (points: number): number => {
  if (points >= REPUTATION_LEVELS[3].minPoints) return 3;
  if (points >= REPUTATION_LEVELS[2].minPoints) return 2;
  if (points >= REPUTATION_LEVELS[1].minPoints) return 1;
  return 0;
};

export const getPointsHistory = async (userId: string, limit = 50) => {
  return prisma.scoreLedgerEntry.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: limit,
  });
};

export const getLeaderboard = async (limit = 20) => {
  return prisma.user.findMany({
    where: {
      isActive: true,
      scoreTotal: { gt: 0 },
    },
    select: {
      id: true,
      displayName: true,
      displayNameAr: true,
      avatar: true,
      scoreTotal: true,
      reputationLevel: true,
      _count: {
        select: {
          submissions: true,
          storeConfirmations: true,
        },
      },
    },
    orderBy: { scoreTotal: 'desc' },
    take: limit,
  });
};

