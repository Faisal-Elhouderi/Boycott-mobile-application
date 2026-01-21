import { z } from 'zod';

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'الاسم مطلوب'),
    email: z.string().email('البريد الإلكتروني غير صالح'),
    password: z.string().min(8, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('البريد الإلكتروني غير صالح'),
    password: z.string().min(1, 'كلمة المرور مطلوبة'),
  }),
});

export const updateProfileSchema = z.object({
  body: z.object({
    displayName: z.string().min(2).optional(),
    displayNameAr: z.string().optional(),
    city: z.string().optional(),
    language: z.enum(['ar', 'en']).optional(),
    avatar: z.string().url().optional(),
  }),
});
