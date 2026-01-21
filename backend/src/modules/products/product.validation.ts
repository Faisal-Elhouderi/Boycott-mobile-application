import { z } from 'zod';

export const createProductSchema = z.object({
  body: z.object({
    barcode: z.string().optional(),
    nameEn: z.string().min(1, 'الاسم مطلوب'),
    nameAr: z.string().optional(),
    aliases: z.array(z.string()).optional(),
    description: z.string().optional(),
    descriptionAr: z.string().optional(),
    imageUrl: z.string().url().optional(),
    images: z.array(z.string().url()).optional(),
    brandId: z.string().min(1, 'معرف العلامة مطلوب'),
    categoryId: z.string().optional(),
    verdictLabel: z.enum(['AVOID', 'CAUTION', 'UNKNOWN', 'PREFERRED']).optional(),
    status: z.enum(['VERIFIED', 'UNDER_REVIEW', 'DISPUTED', 'OUTDATED']).optional(),
    confidence: z.enum(['HIGH', 'MEDIUM', 'LOW']).optional(),
  }),
});

export const updateProductSchema = z.object({
  body: z.object({
    barcode: z.string().optional(),
    nameEn: z.string().min(1).optional(),
    nameAr: z.string().optional(),
    aliases: z.array(z.string()).optional(),
    description: z.string().optional(),
    descriptionAr: z.string().optional(),
    imageUrl: z.string().url().optional(),
    images: z.array(z.string().url()).optional(),
    brandId: z.string().optional(),
    categoryId: z.string().optional(),
    verdictLabel: z.enum(['AVOID', 'CAUTION', 'UNKNOWN', 'PREFERRED']).optional(),
    status: z.enum(['VERIFIED', 'UNDER_REVIEW', 'DISPUTED', 'OUTDATED']).optional(),
    confidence: z.enum(['HIGH', 'MEDIUM', 'LOW']).optional(),
    reason: z.string().optional(),
  }),
});
