import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { addPoints } from '../../services/scoring.js';

export const getAllSubmissions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', status, targetType } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (status) where.status = status;
    if (targetType) where.targetType = targetType;

    const [submissions, total] = await Promise.all([
      prisma.submission.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          submitter: {
            select: {
              id: true,
              displayName: true,
              displayNameAr: true,
              avatar: true,
              reputationLevel: true,
            },
          },
          votes: {
            select: {
              voteType: true,
            },
          },
          _count: {
            select: { votes: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.submission.count({ where }),
    ]);

    // Calculate vote summary
    const submissionsWithVotes = submissions.map((sub) => {
      const voteCounts = {
        support: sub.votes.filter((v) => v.voteType === 'SUPPORT').length,
        needsEvidence: sub.votes.filter((v) => v.voteType === 'NEEDS_EVIDENCE').length,
        disagree: sub.votes.filter((v) => v.voteType === 'DISAGREE').length,
      };
      return {
        ...sub,
        votes: undefined,
        voteCounts,
      };
    });

    res.json({
      success: true,
      data: {
        submissions: submissionsWithVotes,
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

export const getSubmissionById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const submission = await prisma.submission.findUnique({
      where: { id },
      include: {
        submitter: {
          select: {
            id: true,
            displayName: true,
            displayNameAr: true,
            avatar: true,
            reputationLevel: true,
          },
        },
        votes: {
          include: {
            voter: {
              select: {
                id: true,
                displayName: true,
                reputationLevel: true,
              },
            },
          },
        },
      },
    });

    if (!submission) {
      throw createError('Submission not found', 404);
    }

    // Calculate vote summary
    const voteCounts = {
      support: submission.votes.filter((v) => v.voteType === 'SUPPORT').length,
      needsEvidence: submission.votes.filter((v) => v.voteType === 'NEEDS_EVIDENCE').length,
      disagree: submission.votes.filter((v) => v.voteType === 'DISAGREE').length,
    };

    res.json({
      success: true,
      data: {
        ...submission,
        voteCounts,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getMySubmissions = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20' } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const [submissions, total] = await Promise.all([
      prisma.submission.findMany({
        where: { submitterId: req.user!.id },
        skip,
        take: limitNum,
        include: {
          _count: {
            select: { votes: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.submission.count({ where: { submitterId: req.user!.id } }),
    ]);

    res.json({
      success: true,
      data: {
        submissions,
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

export const createSubmission = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const {
      targetType,
      targetId,
      proposedData,
      evidenceSources,
      proposedAlternatives,
      proposedStores,
    } = req.body;

    // Validate evidence sources (at least one required for claims)
    if (proposedData.claims && (!evidenceSources || evidenceSources.length === 0)) {
      throw createError('At least one evidence source is required for claims', 400);
    }

    const submission = await prisma.submission.create({
      data: {
        submitterId: req.user!.id,
        targetType,
        targetId,
        proposedData: JSON.stringify(proposedData),
        evidenceSources,
        proposedAlternatives: proposedAlternatives ? JSON.stringify(proposedAlternatives) : undefined,
        proposedStores: proposedStores ? JSON.stringify(proposedStores) : undefined,
        status: 'PENDING',
      },
      include: {
        submitter: {
          select: {
            id: true,
            displayName: true,
          },
        },
      },
    });

    // Award points for creating submission
    await addPoints(req.user!.id, 5, 'submission_created', submission.id);

    res.status(201).json({
      success: true,
      data: submission,
    });
  } catch (error) {
    next(error);
  }
};

export const voteOnSubmission = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { voteType, note } = req.body;

    // Check submission exists and is pending
    const submission = await prisma.submission.findUnique({ where: { id } });
    if (!submission) {
      throw createError('Submission not found', 404);
    }
    if (submission.status !== 'PENDING' && submission.status !== 'NEEDS_INFO') {
      throw createError('Cannot vote on closed submissions', 400);
    }

    // Check user hasn't already voted
    const existingVote = await prisma.vote.findUnique({
      where: {
        submissionId_voterId: {
          submissionId: id,
          voterId: req.user!.id,
        },
      },
    });

    if (existingVote) {
      // Update existing vote
      const vote = await prisma.vote.update({
        where: { id: existingVote.id },
        data: { voteType, note },
      });

      res.json({
        success: true,
        data: vote,
        message: 'Vote updated',
      });
    } else {
      // Create new vote
      const vote = await prisma.vote.create({
        data: {
          submissionId: id,
          voterId: req.user!.id,
          voteType,
          note,
        },
      });

      res.status(201).json({
        success: true,
        data: vote,
        message: 'Vote recorded',
      });
    }
  } catch (error) {
    next(error);
  }
};

export const moderateSubmission = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { status, moderatorNotes, decisionReason } = req.body;

    const submission = await prisma.submission.findUnique({
      where: { id },
      include: { submitter: true },
    });

    if (!submission) {
      throw createError('Submission not found', 404);
    }

    const updated = await prisma.submission.update({
      where: { id },
      data: {
        status,
        moderatorNotes,
        decisionReason,
      },
    });

    // Award/deduct points based on decision
    if (status === 'APPROVED') {
      await addPoints(submission.submitterId, 25, 'submission_approved', submission.id);
      
      // TODO: Actually create the entity from submission data
      // This would involve parsing proposedData and creating Product/Company/Brand
    } else if (status === 'REJECTED' && decisionReason?.includes('spam')) {
      await addPoints(submission.submitterId, -5, 'submission_rejected_spam', submission.id);
    }

    res.json({
      success: true,
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

