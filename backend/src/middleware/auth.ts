import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../database/client.js';
import { createError } from './errorHandler.js';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
    reputationLevel: number;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('تسجيل الدخول مطلوب', 401, 'UNAUTHORIZED');
    }

    const token = authHeader.split(' ')[1];
    const secret = process.env.JWT_SECRET || 'fallback-secret';

    const decoded = jwt.verify(token, secret) as {
      userId: string;
      email: string;
    };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        role: true,
        reputationLevel: true,
      },
    });

    if (!user) {
      throw createError('المستخدم غير موجود', 401, 'UNAUTHORIZED');
    }

    req.user = user;
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      next(createError('رمز غير صالح', 401, 'UNAUTHORIZED'));
    } else {
      next(error);
    }
  }
};

export const optionalAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];
    const secret = process.env.JWT_SECRET || 'fallback-secret';

    const decoded = jwt.verify(token, secret) as {
      userId: string;
      email: string;
    };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        role: true,
        reputationLevel: true,
      },
    });

    if (user) {
      req.user = user;
    }

    next();
  } catch {
    next();
  }
};

export const requireRole = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(createError('تسجيل الدخول مطلوب', 401, 'UNAUTHORIZED'));
    }

    if (!roles.includes(req.user.role)) {
      return next(createError('لا تملك الصلاحية', 403, 'FORBIDDEN'));
    }

    next();
  };
};

export const requireReputationLevel = (minLevel: number) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(createError('تسجيل الدخول مطلوب', 401, 'UNAUTHORIZED'));
    }

    if (req.user.reputationLevel < minLevel) {
      return next(createError('مستوى السمعة غير كافٍ', 403, 'FORBIDDEN'));
    }

    next();
  };
};
