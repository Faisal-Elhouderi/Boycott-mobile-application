import { z } from 'zod';

export const createCompanySchema = z.object({
  body: z.object({
    nameEn: z.string().min(1, 'اسم الشركة مطلوب'),
    nameAr: z.string().optional(),
    aliases: z.array(z.string()).optional(),
    country: z.string().optional(),
    logoUrl: z.string().url().optional(),
    websiteUrl: z.string().url().optional(),
    description: z.string().optional(),
    descriptionAr: z.string().optional(),
    parentId: z.string().optional(),
    verdictLabel: z.enum(['AVOID', 'CAUTION', 'UNKNOWN', 'PREFERRED']).optional(),
    status: z.enum(['VERIFIED', 'UNDER_REVIEW', 'DISPUTED', 'OUTDATED']).optional(),
    confidence: z.enum(['HIGH', 'MEDIUM', 'LOW']).optional(),
  }),
});

export const updateCompanySchema = z.object({
  body: z.object({
    nameEn: z.string().min(1).optional(),
    nameAr: z.string().optional(),
    aliases: z.array(z.string()).optional(),
    country: z.string().optional(),
    logoUrl: z.string().url().optional(),
    websiteUrl: z.string().url().optional(),
    description: z.string().optional(),
    descriptionAr: z.string().optional(),
    parentId: z.string().nullable().optional(),
    verdictLabel: z.enum(['AVOID', 'CAUTION', 'UNKNOWN', 'PREFERRED']).optional(),
    status: z.enum(['VERIFIED', 'UNDER_REVIEW', 'DISPUTED', 'OUTDATED']).optional(),
    confidence: z.enum(['HIGH', 'MEDIUM', 'LOW']).optional(),
    reason: z.string().optional(),
  }),
});
