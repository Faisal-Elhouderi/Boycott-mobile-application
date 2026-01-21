import { PrismaClient } from '@prisma/client';
import { categories } from './categories.js';
import { companies } from './companies.js';
import { brands } from './brands.js';
import { products } from './products.js';
import { alternatives } from './alternatives.js';
import { claims } from './claims.js';
import { badges } from './badges.js';
import { stores } from './stores.js';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting database seed...');

  // Clear existing data in reverse order of dependencies
  console.log('Clearing existing data...');
  await prisma.storeAvailability.deleteMany();
  await prisma.scanHistory.deleteMany();
  await prisma.suggestionLike.deleteMany();
  await prisma.communitySuggestion.deleteMany();
  await prisma.vote.deleteMany();
  await prisma.submission.deleteMany();
  await prisma.alternative.deleteMany();
  await prisma.productClaim.deleteMany();
  await prisma.companyClaim.deleteMany();
  await prisma.evidenceSource.deleteMany();
  await prisma.claim.deleteMany();
  await prisma.productChangelog.deleteMany();
  await prisma.report.deleteMany();
  await prisma.product.deleteMany();
  await prisma.brandChangelog.deleteMany();
  await prisma.brand.deleteMany();
  await prisma.companyChangelog.deleteMany();
  await prisma.company.deleteMany();
  await prisma.category.deleteMany();
  await prisma.userBadge.deleteMany();
  await prisma.badge.deleteMany();
  await prisma.store.deleteMany();
  await prisma.scoreLedgerEntry.deleteMany();
  await prisma.campaign.deleteMany();

  // Create categories
  console.log('Creating categories...');
  for (const category of categories) {
    await prisma.category.create({ data: category });
  }

  // Create badges
  console.log('Creating badges...');
  for (const badge of badges) {
    await prisma.badge.create({ data: badge });
  }

  // Create stores
  console.log('Creating stores...');
  for (const store of stores) {
    await prisma.store.create({ data: store });
  }

  // Create companies
  console.log('Creating companies...');
  const companyMap = new Map<string, string>();
  for (const company of companies) {
    const created = await prisma.company.create({
      data: {
        nameEn: company.nameEn,
        nameAr: company.nameAr,
        aliases: company.aliases || [],
        country: company.country,
        logoUrl: company.logoUrl,
        websiteUrl: company.websiteUrl,
        description: company.description,
        descriptionAr: company.descriptionAr,
        status: company.status || 'VERIFIED',
        confidence: company.confidence || 'HIGH',
        verdictLabel: company.verdictLabel || 'AVOID',
      },
    });
    companyMap.set(company.nameEn, created.id);
  }

  // Update parent relationships
  for (const company of companies) {
    if (company.parentName) {
      const parentId = companyMap.get(company.parentName);
      const companyId = companyMap.get(company.nameEn);
      if (parentId && companyId) {
        await prisma.company.update({
          where: { id: companyId },
          data: { parentId },
        });
      }
    }
  }

  // Create brands
  console.log('Creating brands...');
  const brandMap = new Map<string, string>();
  for (const brand of brands) {
    const companyId = companyMap.get(brand.companyName);
    if (companyId) {
      const created = await prisma.brand.create({
        data: {
          nameEn: brand.nameEn,
          nameAr: brand.nameAr,
          aliases: brand.aliases || [],
          logoUrl: brand.logoUrl,
          companyId,
        },
      });
      brandMap.set(brand.nameEn, created.id);
    }
  }

  // Get category IDs
  const categoryMap = new Map<string, string>();
  const allCategories = await prisma.category.findMany();
  for (const cat of allCategories) {
    categoryMap.set(cat.nameEn, cat.id);
  }

  // Create products
  console.log('Creating products...');
  const productMap = new Map<string, string>();
  for (const product of products) {
    const brandId = brandMap.get(product.brandName);
    const categoryId = product.categoryName ? categoryMap.get(product.categoryName) : undefined;

    if (brandId) {
      const created = await prisma.product.create({
        data: {
          barcode: product.barcode,
          nameEn: product.nameEn,
          nameAr: product.nameAr,
          aliases: product.aliases || [],
          description: product.description,
          descriptionAr: product.descriptionAr,
          imageUrl: product.imageUrl,
          brandId,
          categoryId,
          verdictLabel: product.verdictLabel || 'AVOID',
          status: product.status || 'VERIFIED',
          confidence: product.confidence || 'HIGH',
          lastReviewedAt: new Date(),
        },
      });
      productMap.set(product.nameEn, created.id);
    }
  }

  // Create claims and evidence
  console.log('Creating claims and evidence...');
  for (const claim of claims) {
    const created = await prisma.claim.create({
      data: {
        titleEn: claim.titleEn,
        titleAr: claim.titleAr,
        descriptionEn: claim.descriptionEn,
        descriptionAr: claim.descriptionAr,
        issueType: claim.issueType,
        status: 'VERIFIED',
        confidence: 'HIGH',
      },
    });

    // Add evidence sources
    for (const source of claim.evidenceSources || []) {
      await prisma.evidenceSource.create({
        data: {
          claimId: created.id,
          url: source.url,
          title: source.title,
          publisher: source.publisher,
          publishedDate: source.publishedDate ? new Date(source.publishedDate) : undefined,
        },
      });
    }

    // Link to companies
    for (const companyName of claim.companies || []) {
      const companyId = companyMap.get(companyName);
      if (companyId) {
        await prisma.companyClaim.create({
          data: {
            companyId,
            claimId: created.id,
          },
        });
      }
    }
  }

  // Create alternatives
  console.log('Creating alternatives...');
  for (const alt of alternatives) {
    const productId = productMap.get(alt.productName);
    const alternativeId = productMap.get(alt.alternativeName);

    if (productId && alternativeId) {
      await prisma.alternative.create({
        data: {
          productId,
          alternativeId,
          isExactAlternative: alt.isExact || false,
          notes: alt.notes,
          notesAr: alt.notesAr,
        },
      });
    }
  }

  // Create default campaign
  console.log('Creating default campaign...');
  await prisma.campaign.create({
    data: {
      nameEn: 'مقاطعة التضامن مع غزة',
      nameAr: 'مقاطعة التضامن مع غزة',
      descriptionEn: 'حملة لمقاطعة الشركات الداعمة للاحتلال.',
      descriptionAr: 'حملة لمقاطعة الشركات الداعمة للاحتلال.',
      isActive: true,
      isDefault: true,
    },
  });

  console.log('Database seeded successfully');
}

main()
  .catch((e) => {
    console.error('Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
