import { z } from 'zod';

export const createStoreSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Store name is required'),
    nameAr: z.string().optional(),
    city: z.string().min(1, 'City is required'),
    area: z.string().optional(),
    address: z.string().optional(),
    addressAr: z.string().optional(),
    latitude: z.number().optional(),
    longitude: z.number().optional(),
    phone: z.string().optional(),
    openingHours: z.string().optional(),
    tags: z.array(z.string()).optional(),
  }),
});

export const updateStoreSchema = z.object({
  body: z.object({
    name: z.string().min(1).optional(),
    nameAr: z.string().optional(),
    city: z.string().min(1).optional(),
    area: z.string().optional(),
    address: z.string().optional(),
    addressAr: z.string().optional(),
    latitude: z.number().optional(),
    longitude: z.number().optional(),
    phone: z.string().optional(),
    openingHours: z.string().optional(),
    tags: z.array(z.string()).optional(),
    isVerified: z.boolean().optional(),
  }),
});

export const confirmAvailabilitySchema = z.object({
  body: z.object({
    storeId: z.string().min(1, 'Store ID is required'),
    alternativeId: z.string().min(1, 'Alternative ID is required'),
    isAvailable: z.boolean(),
  }),
});

export const updatePriceSchema = z.object({
  body: z.object({
    storeId: z.string().min(1, 'Store ID is required'),
    alternativeId: z.string().min(1, 'Alternative ID is required'),
    priceMin: z.number().min(0),
    priceMax: z.number().min(0),
    currency: z.string().optional().default('LYD'),
  }),
});

