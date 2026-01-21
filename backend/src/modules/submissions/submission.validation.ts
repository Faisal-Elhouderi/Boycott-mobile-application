import { z } from 'zod';

export const createSubmissionSchema = z.object({
  body: z.object({
    targetType: z.enum(['product', 'company', 'brand']),
    targetId: z.string().optional(), // If updating existing entity
    proposedData: z.object({
      nameEn: z.string().optional(),
      nameAr: z.string().optional(),
      barcode: z.string().optional(),
      brandName: z.string().optional(),
      companyName: z.string().optional(),
      verdictLabel: z.enum(['AVOID', 'CAUTION', 'UNKNOWN', 'PREFERRED']).optional(),
      claims: z.array(z.object({
        title: z.string(),
        description: z.string(),
        issueType: z.string(),
      })).optional(),
    }),
    evidenceSources: z.array(z.string().url()).min(0),
    proposedAlternatives: z.array(z.object({
      name: z.string(),
      brandName: z.string().optional(),
      isExact: z.boolean().optional(),
    })).optional(),
    proposedStores: z.array(z.object({
      name: z.string(),
      city: z.string(),
      area: z.string().optional(),
      priceRange: z.string().optional(),
    })).optional(),
  }),
});

export const voteSchema = z.object({
  body: z.object({
    voteType: z.enum(['SUPPORT', 'NEEDS_EVIDENCE', 'DISAGREE']),
    note: z.string().optional(),
  }),
});

export const moderateSchema = z.object({
  body: z.object({
    status: z.enum(['PENDING', 'NEEDS_INFO', 'APPROVED', 'REJECTED', 'MERGED']),
    moderatorNotes: z.string().optional(),
    decisionReason: z.string().optional(),
  }),
});

