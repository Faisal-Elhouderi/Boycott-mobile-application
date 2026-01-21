import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { prisma } from '../../database/client.js';
import { sendSuccess } from '../../middleware/response.js';

const normalize = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

export const listMarkets = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { search, city } = req.query;

    const where: Prisma.StoreWhereInput = {};

    if (city) {
      const cityValue = normalize(city);
      if (cityValue) {
        where.city = { contains: cityValue };
      }
    }

    if (search) {
      const term = normalize(search);
      if (term) {
        where.OR = [
          { name: { contains: term } },
          { nameAr: { contains: term } },
          { city: { contains: term } },
          { area: { contains: term } },
        ];
      }
    }

    const stores = await prisma.store.findMany({
      where,
      orderBy: { name: 'asc' },
    });

    const items = stores.map((store) => ({
      id: store.id,
      name: store.nameAr || store.name,
      city: store.city,
      area: store.area || null,
      address: store.addressAr || store.address || null,
      isVerified: store.isVerified,
    }));

    return sendSuccess(res, items, 200, { count: items.length });
  } catch (error) {
    next(error);
  }
};
