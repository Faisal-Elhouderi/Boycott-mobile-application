import { z } from 'zod';

export const createAlternativeSchema = z.object({
  body: z.object({
    productId: z.string().min(1, 'معرف المنتج مطلوب'),
    alternativeId: z.string().min(1, 'معرف البديل مطلوب'),
    isExactAlternative: z.boolean().optional(),
    notes: z.string().optional(),
    notesAr: z.string().optional(),
  }),
});
