import { z } from 'zod';

export const createSuggestionSchema = z.object({
  body: z.object({
    text: z.string().min(3, 'نص الاقتراح مطلوب'),
    companyName: z.string().min(2, 'اسم الشركة غير صالح').optional(),
  }),
});
