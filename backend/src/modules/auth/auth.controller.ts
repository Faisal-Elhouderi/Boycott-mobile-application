import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { sendSuccess } from '../../middleware/response.js';

const normalize = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

const toAuthUser = (user: { id: string; email: string; displayName?: string | null }) => ({
  id: user.id,
  email: user.email,
  name: user.displayName || undefined,
});

export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const name = normalize(req.body.name);
    const email = normalize(req.body.email).toLowerCase();
    const password = req.body.password;

    if (!name) {
      throw createError('الاسم مطلوب', 400, 'BAD_REQUEST');
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw createError('البريد الإلكتروني مستخدم مسبقًا', 400, 'BAD_REQUEST');
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        displayName: name,
      },
      select: {
        id: true,
        email: true,
        displayName: true,
      },
    });

    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'fallback-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return sendSuccess(res, { token, user: toAuthUser(user) }, 201);
  } catch (error) {
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const email = normalize(req.body.email).toLowerCase();
    const password = req.body.password;

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw createError('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401, 'UNAUTHORIZED');
    }

    const isValidPassword = await bcrypt.compare(password, user.passwordHash);
    if (!isValidPassword) {
      throw createError('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401, 'UNAUTHORIZED');
    }

    if (!user.isActive) {
      throw createError('الحساب معطل', 403, 'FORBIDDEN');
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'fallback-secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return sendSuccess(res, { token, user: toAuthUser(user) });
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req: AuthRequest, res: Response, next: NextFunction) => {
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

    return sendSuccess(res, { user: toAuthUser(user) });
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { displayName, displayNameAr, city, language, avatar } = req.body;

    const user = await prisma.user.update({
      where: { id: req.user!.id },
      data: {
        ...(displayName && { displayName }),
        ...(displayNameAr && { displayNameAr }),
        ...(city && { city }),
        ...(language && { language }),
        ...(avatar && { avatar }),
      },
      select: {
        id: true,
        email: true,
        displayName: true,
        displayNameAr: true,
        avatar: true,
        city: true,
        language: true,
        role: true,
        reputationLevel: true,
        scoreTotal: true,
      },
    });

    return sendSuccess(res, user);
  } catch (error) {
    next(error);
  }
};
