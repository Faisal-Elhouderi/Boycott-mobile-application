import { Request, Response, NextFunction } from 'express';
import { prisma } from '../../database/client.js';
import { createError } from '../../middleware/errorHandler.js';
import { AuthRequest } from '../../middleware/auth.js';
import { addPoints } from '../../services/scoring.js';

export const getAllStores = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '50', city, tags } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (city) where.city = city;
    if (tags) where.tags = { hasSome: (tags as string).split(',') };

    const [stores, total] = await Promise.all([
      prisma.store.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { name: 'asc' },
      }),
      prisma.store.count({ where }),
    ]);

    res.json({
      success: true,
      data: {
        stores,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          totalPages: Math.ceil(total / limitNum),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getStoreById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const store = await prisma.store.findUnique({
      where: { id },
      include: {
        availability: {
          where: { isAvailable: true },
          include: {
            alternative: {
              include: {
                alternative: {
                  include: {
                    brand: true,
                    category: true,
                  },
                },
              },
            },
          },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!store) {
      throw createError('Store not found', 404);
    }

    res.json({
      success: true,
      data: store,
    });
  } catch (error) {
    next(error);
  }
};

export const getStoresByCity = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { city } = req.params;
    const { area, tags } = req.query;

    const where: any = { city };
    if (area) where.area = area;
    if (tags) where.tags = { hasSome: (tags as string).split(',') };

    const stores = await prisma.store.findMany({
      where,
      include: {
        _count: {
          select: { availability: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    res.json({
      success: true,
      data: stores,
    });
  } catch (error) {
    next(error);
  }
};

export const getStoresForProduct = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { alternativeId } = req.params;
    const { city, sortBy = 'recent' } = req.query;

    const where: any = {
      alternativeId,
      isAvailable: true,
    };
    if (city) {
      where.store = { city: city as string };
    }

    let orderBy: any = { createdAt: 'desc' };
    if (sortBy === 'price') {
      orderBy = { priceMin: 'asc' };
    } else if (sortBy === 'confirmations') {
      // Will be handled differently
    }

    const availability = await prisma.storeAvailability.findMany({
      where,
      include: {
        store: true,
        confirmedBy: {
          select: {
            id: true,
            displayName: true,
            reputationLevel: true,
          },
        },
      },
      orderBy,
    });

    // Group by store for better presentation
    const storeMap = new Map<string, any>();
    for (const avail of availability) {
      if (!storeMap.has(avail.storeId)) {
        storeMap.set(avail.storeId, {
          store: avail.store,
          confirmations: [],
          latestConfirmation: avail.createdAt,
          latestPrice: avail.priceMin && avail.priceMax ? {
            min: avail.priceMin,
            max: avail.priceMax,
            currency: avail.currency,
          } : null,
        });
      }
      storeMap.get(avail.storeId).confirmations.push({
        id: avail.id,
        isAvailable: avail.isAvailable,
        priceMin: avail.priceMin,
        priceMax: avail.priceMax,
        currency: avail.currency,
        confirmedAt: avail.createdAt,
        confirmedBy: avail.confirmedBy,
      });
    }

    const stores = Array.from(storeMap.values());

    res.json({
      success: true,
      data: stores,
    });
  } catch (error) {
    next(error);
  }
};

export const createStore = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const data = req.body;

    const store = await prisma.store.create({
      data: {
        name: data.name,
        nameAr: data.nameAr,
        city: data.city,
        area: data.area,
        address: data.address,
        addressAr: data.addressAr,
        latitude: data.latitude,
        longitude: data.longitude,
        phone: data.phone,
        openingHours: data.openingHours,
        tags: data.tags || [],
        isVerified: false,
      },
    });

    res.status(201).json({
      success: true,
      data: store,
    });
  } catch (error) {
    next(error);
  }
};

export const updateStore = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const data = req.body;

    const store = await prisma.store.update({
      where: { id },
      data: {
        ...(data.name && { name: data.name }),
        ...(data.nameAr && { nameAr: data.nameAr }),
        ...(data.city && { city: data.city }),
        ...(data.area && { area: data.area }),
        ...(data.address && { address: data.address }),
        ...(data.addressAr && { addressAr: data.addressAr }),
        ...(data.latitude !== undefined && { latitude: data.latitude }),
        ...(data.longitude !== undefined && { longitude: data.longitude }),
        ...(data.phone && { phone: data.phone }),
        ...(data.openingHours && { openingHours: data.openingHours }),
        ...(data.tags && { tags: data.tags }),
        ...(data.isVerified !== undefined && { isVerified: data.isVerified }),
      },
    });

    res.json({
      success: true,
      data: store,
    });
  } catch (error) {
    next(error);
  }
};

export const confirmAvailability = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { storeId, alternativeId, isAvailable } = req.body;

    // Get user reputation level for trust weight
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: { reputationLevel: true },
    });

    const trustWeight = 1 + (user?.reputationLevel || 0) * 0.2;

    const confirmation = await prisma.storeAvailability.create({
      data: {
        storeId,
        alternativeId,
        isAvailable,
        confirmedById: req.user!.id,
        trustWeight,
      },
      include: {
        store: true,
      },
    });

    // Award points
    await addPoints(req.user!.id, 2, 'store_confirmation', confirmation.id);

    res.status(201).json({
      success: true,
      data: confirmation,
    });
  } catch (error) {
    next(error);
  }
};

export const updatePrice = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { storeId, alternativeId, priceMin, priceMax, currency = 'LYD' } = req.body;

    // Get user reputation level for trust weight
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id },
      select: { reputationLevel: true },
    });

    const trustWeight = 1 + (user?.reputationLevel || 0) * 0.2;

    const priceUpdate = await prisma.storeAvailability.create({
      data: {
        storeId,
        alternativeId,
        isAvailable: true,
        priceMin,
        priceMax,
        currency,
        confirmedById: req.user!.id,
        trustWeight,
      },
      include: {
        store: true,
      },
    });

    // Award points for price update
    await addPoints(req.user!.id, 2, 'price_update', priceUpdate.id);

    res.status(201).json({
      success: true,
      data: priceUpdate,
    });
  } catch (error) {
    next(error);
  }
};

