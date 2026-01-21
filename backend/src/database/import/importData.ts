/**
 * Data Import Script
 * 
 * This script imports data from JSON files into the database.
 * Categories are loaded from a separate file (categories.json).
 * Other data is loaded from boycott_data.json.
 * 
 * Usage:
 *   npx ts-node src/database/import/importData.ts
 *   npx ts-node src/database/import/importData.ts --file=./data/my_data.json
 *   npx ts-node src/database/import/importData.ts --clear  (clears existing data first)
 *   npx ts-node src/database/import/importData.ts --categories-only  (import only categories)
 */

import { PrismaClient, VerdictLabel, ConfidenceLevel, EntityStatus, IssueType } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

// ==================== TYPE DEFINITIONS ====================

interface CategoryData {
  id: string;
  nameEn: string;
  nameAr: string;
  icon?: string;
  parentId?: string;
  sortOrder?: number;
}

interface CompanyData {
  id: string;
  nameEn: string;
  nameAr?: string;
  country?: string;
  aliases?: string[];
  logoUrl?: string;
  websiteUrl?: string;
  description?: string;
  descriptionAr?: string;
  verdict: string;
  confidence: string;
  parentId?: string;
}

interface BrandData {
  id: string;
  nameEn: string;
  nameAr?: string;
  aliases?: string[];
  logoUrl?: string;
  companyId: string;
}

interface ProductData {
  id: string;
  nameEn: string;
  nameAr?: string;
  barcode?: string;
  aliases?: string[];
  description?: string;
  descriptionAr?: string;
  imageUrl?: string;
  images?: string[];
  brandId: string;
  categoryId?: string;
  verdict: string;
  confidence: string;
}

interface EvidenceData {
  url: string;
  title: string;
  publisher?: string;
  publishedDate?: string;
}

interface ClaimData {
  id: string;
  titleEn: string;
  titleAr?: string;
  descriptionEn: string;
  descriptionAr?: string;
  issueType: string;
  confidence: string;
  appliesToCompanyId?: string;
  appliesToProductId?: string;
  evidence?: EvidenceData[];
}

interface AlternativeData {
  boycottedProductId: string;
  alternativeProductId: string;
  isExactAlternative?: boolean;
  notes?: string;
  notesAr?: string;
}

interface StoreData {
  id: string;
  name: string;
  nameAr?: string;
  city: string;
  area?: string;
  address?: string;
  addressAr?: string;
  latitude?: number;
  longitude?: number;
  phone?: string;
  openingHours?: string;
  tags?: string[];
}

interface StoreAvailabilityData {
  storeId: string;
  alternativeProductId: string;
  priceMin?: number;
  priceMax?: number;
  currency?: string;
}

interface ImportData {
  categories?: CategoryData[];
  companies?: CompanyData[];
  brands?: BrandData[];
  products?: ProductData[];
  claims?: ClaimData[];
  alternatives?: AlternativeData[];
  stores?: StoreData[];
  storeAvailability?: StoreAvailabilityData[];
}

// ==================== HELPER FUNCTIONS ====================

function parseVerdict(value: string): VerdictLabel {
  const upper = value.toUpperCase();
  if (upper === 'AVOID') return VerdictLabel.AVOID;
  if (upper === 'CAUTION') return VerdictLabel.CAUTION;
  if (upper === 'PREFERRED') return VerdictLabel.PREFERRED;
  return VerdictLabel.UNKNOWN;
}

function parseConfidence(value: string): ConfidenceLevel {
  const upper = value.toUpperCase();
  if (upper === 'HIGH') return ConfidenceLevel.HIGH;
  if (upper === 'MEDIUM') return ConfidenceLevel.MEDIUM;
  return ConfidenceLevel.LOW;
}

function parseIssueType(value: string): IssueType {
  const upper = value.toUpperCase();
  if (upper === 'OCCUPATION') return IssueType.OCCUPATION;
  if (upper === 'FUNDING') return IssueType.FUNDING;
  if (upper === 'HUMAN_RIGHTS') return IssueType.HUMAN_RIGHTS;
  if (upper === 'LABOR') return IssueType.LABOR;
  if (upper === 'ENVIRONMENTAL') return IssueType.ENVIRONMENTAL;
  return IssueType.OTHER;
}

function log(message: string, type: 'info' | 'success' | 'error' | 'warning' = 'info') {
  const icons = {
    info: '📋',
    success: '✅',
    error: '❌',
    warning: '⚠️'
  };
  console.log(`${icons[type]} ${message}`);
}

// ==================== IMPORT FUNCTIONS ====================

async function importCategories(categories: CategoryData[]) {
  log(`Importing ${categories.length} categories...`);
  
  for (const cat of categories) {
    await prisma.category.upsert({
      where: { id: cat.id },
      update: {
        nameEn: cat.nameEn,
        nameAr: cat.nameAr,
        icon: cat.icon,
        parentId: cat.parentId,
        sortOrder: cat.sortOrder ?? 0,
      },
      create: {
        id: cat.id,
        nameEn: cat.nameEn,
        nameAr: cat.nameAr,
        icon: cat.icon,
        parentId: cat.parentId,
        sortOrder: cat.sortOrder ?? 0,
      },
    });
  }
  
  log(`Categories imported successfully`, 'success');
}

async function importCompanies(companies: CompanyData[]) {
  log(`Importing ${companies.length} companies...`);
  
  // First pass: create all companies without parent references
  for (const company of companies) {
    await prisma.company.upsert({
      where: { id: company.id },
      update: {
        nameEn: company.nameEn,
        nameAr: company.nameAr,
        country: company.country,
        aliases: company.aliases ?? [],
        logoUrl: company.logoUrl,
        websiteUrl: company.websiteUrl,
        description: company.description,
        descriptionAr: company.descriptionAr,
        verdictLabel: parseVerdict(company.verdict),
        confidence: parseConfidence(company.confidence),
        status: EntityStatus.VERIFIED,
      },
      create: {
        id: company.id,
        nameEn: company.nameEn,
        nameAr: company.nameAr,
        country: company.country,
        aliases: company.aliases ?? [],
        logoUrl: company.logoUrl,
        websiteUrl: company.websiteUrl,
        description: company.description,
        descriptionAr: company.descriptionAr,
        verdictLabel: parseVerdict(company.verdict),
        confidence: parseConfidence(company.confidence),
        status: EntityStatus.VERIFIED,
      },
    });
  }
  
  // Second pass: update parent references
  for (const company of companies) {
    if (company.parentId) {
      await prisma.company.update({
        where: { id: company.id },
        data: { parentId: company.parentId },
      });
    }
  }
  
  log(`Companies imported successfully`, 'success');
}

async function importBrands(brands: BrandData[]) {
  log(`Importing ${brands.length} brands...`);
  
  for (const brand of brands) {
    // Check if company exists
    const company = await prisma.company.findUnique({
      where: { id: brand.companyId },
    });
    
    if (!company) {
      log(`Company ${brand.companyId} not found for brand ${brand.nameEn}, skipping...`, 'warning');
      continue;
    }
    
    await prisma.brand.upsert({
      where: { id: brand.id },
      update: {
        nameEn: brand.nameEn,
        nameAr: brand.nameAr,
        aliases: brand.aliases ?? [],
        logoUrl: brand.logoUrl,
        companyId: brand.companyId,
      },
      create: {
        id: brand.id,
        nameEn: brand.nameEn,
        nameAr: brand.nameAr,
        aliases: brand.aliases ?? [],
        logoUrl: brand.logoUrl,
        companyId: brand.companyId,
      },
    });
  }
  
  log(`Brands imported successfully`, 'success');
}

async function importProducts(products: ProductData[]) {
  log(`Importing ${products.length} products...`);
  
  for (const product of products) {
    // Check if brand exists
    const brand = await prisma.brand.findUnique({
      where: { id: product.brandId },
    });
    
    if (!brand) {
      log(`Brand ${product.brandId} not found for product ${product.nameEn}, skipping...`, 'warning');
      continue;
    }
    
    // Check if category exists (optional)
    if (product.categoryId) {
      const category = await prisma.category.findUnique({
        where: { id: product.categoryId },
      });
      if (!category) {
        log(`Category ${product.categoryId} not found for product ${product.nameEn}, setting to null...`, 'warning');
        product.categoryId = undefined;
      }
    }
    
    await prisma.product.upsert({
      where: { id: product.id },
      update: {
        nameEn: product.nameEn,
        nameAr: product.nameAr,
        barcode: product.barcode,
        aliases: product.aliases ?? [],
        description: product.description,
        descriptionAr: product.descriptionAr,
        imageUrl: product.imageUrl,
        images: product.images ?? [],
        brandId: product.brandId,
        categoryId: product.categoryId,
        verdictLabel: parseVerdict(product.verdict),
        confidence: parseConfidence(product.confidence),
        status: EntityStatus.VERIFIED,
      },
      create: {
        id: product.id,
        nameEn: product.nameEn,
        nameAr: product.nameAr,
        barcode: product.barcode,
        aliases: product.aliases ?? [],
        description: product.description,
        descriptionAr: product.descriptionAr,
        imageUrl: product.imageUrl,
        images: product.images ?? [],
        brandId: product.brandId,
        categoryId: product.categoryId,
        verdictLabel: parseVerdict(product.verdict),
        confidence: parseConfidence(product.confidence),
        status: EntityStatus.VERIFIED,
      },
    });
  }
  
  log(`Products imported successfully`, 'success');
}

async function importClaims(claims: ClaimData[]) {
  log(`Importing ${claims.length} claims...`);
  
  for (const claim of claims) {
    // Create the claim
    const createdClaim = await prisma.claim.upsert({
      where: { id: claim.id },
      update: {
        titleEn: claim.titleEn,
        titleAr: claim.titleAr,
        descriptionEn: claim.descriptionEn,
        descriptionAr: claim.descriptionAr,
        issueType: parseIssueType(claim.issueType),
        confidence: parseConfidence(claim.confidence),
        status: EntityStatus.VERIFIED,
      },
      create: {
        id: claim.id,
        titleEn: claim.titleEn,
        titleAr: claim.titleAr,
        descriptionEn: claim.descriptionEn,
        descriptionAr: claim.descriptionAr,
        issueType: parseIssueType(claim.issueType),
        confidence: parseConfidence(claim.confidence),
        status: EntityStatus.VERIFIED,
      },
    });
    
    // Add evidence sources
    if (claim.evidence && claim.evidence.length > 0) {
      // First, delete existing evidence for this claim
      await prisma.evidenceSource.deleteMany({
        where: { claimId: createdClaim.id },
      });
      
      for (const evidence of claim.evidence) {
        await prisma.evidenceSource.create({
          data: {
            claimId: createdClaim.id,
            url: evidence.url,
            title: evidence.title,
            publisher: evidence.publisher,
            publishedDate: evidence.publishedDate ? new Date(evidence.publishedDate) : null,
          },
        });
      }
    }
    
    // Link to company
    if (claim.appliesToCompanyId) {
      const company = await prisma.company.findUnique({
        where: { id: claim.appliesToCompanyId },
      });
      
      if (company) {
        await prisma.companyClaim.upsert({
          where: {
            companyId_claimId: {
              companyId: claim.appliesToCompanyId,
              claimId: createdClaim.id,
            },
          },
          update: {},
          create: {
            companyId: claim.appliesToCompanyId,
            claimId: createdClaim.id,
          },
        });
      } else {
        log(`Company ${claim.appliesToCompanyId} not found for claim ${claim.id}`, 'warning');
      }
    }
    
    // Link to product
    if (claim.appliesToProductId) {
      const product = await prisma.product.findUnique({
        where: { id: claim.appliesToProductId },
      });
      
      if (product) {
        await prisma.productClaim.upsert({
          where: {
            productId_claimId: {
              productId: claim.appliesToProductId,
              claimId: createdClaim.id,
            },
          },
          update: {},
          create: {
            productId: claim.appliesToProductId,
            claimId: createdClaim.id,
          },
        });
      } else {
        log(`Product ${claim.appliesToProductId} not found for claim ${claim.id}`, 'warning');
      }
    }
  }
  
  log(`Claims imported successfully`, 'success');
}

async function importAlternatives(alternatives: AlternativeData[]) {
  log(`Importing ${alternatives.length} alternatives...`);
  
  for (const alt of alternatives) {
    // Check if both products exist
    const boycotted = await prisma.product.findUnique({
      where: { id: alt.boycottedProductId },
    });
    const alternative = await prisma.product.findUnique({
      where: { id: alt.alternativeProductId },
    });
    
    if (!boycotted) {
      log(`Boycotted product ${alt.boycottedProductId} not found, skipping...`, 'warning');
      continue;
    }
    if (!alternative) {
      log(`Alternative product ${alt.alternativeProductId} not found, skipping...`, 'warning');
      continue;
    }
    
    await prisma.alternative.upsert({
      where: {
        productId_alternativeId: {
          productId: alt.boycottedProductId,
          alternativeId: alt.alternativeProductId,
        },
      },
      update: {
        isExactAlternative: alt.isExactAlternative ?? false,
        notes: alt.notes,
        notesAr: alt.notesAr,
      },
      create: {
        productId: alt.boycottedProductId,
        alternativeId: alt.alternativeProductId,
        isExactAlternative: alt.isExactAlternative ?? false,
        notes: alt.notes,
        notesAr: alt.notesAr,
      },
    });
  }
  
  log(`Alternatives imported successfully`, 'success');
}

async function importStores(stores: StoreData[]) {
  log(`Importing ${stores.length} stores...`);
  
  for (const store of stores) {
    await prisma.store.upsert({
      where: { id: store.id },
      update: {
        name: store.name,
        nameAr: store.nameAr,
        city: store.city,
        area: store.area,
        address: store.address,
        addressAr: store.addressAr,
        latitude: store.latitude,
        longitude: store.longitude,
        phone: store.phone,
        openingHours: store.openingHours,
        tags: store.tags ?? [],
        isVerified: true,
      },
      create: {
        id: store.id,
        name: store.name,
        nameAr: store.nameAr,
        city: store.city,
        area: store.area,
        address: store.address,
        addressAr: store.addressAr,
        latitude: store.latitude,
        longitude: store.longitude,
        phone: store.phone,
        openingHours: store.openingHours,
        tags: store.tags ?? [],
        isVerified: true,
      },
    });
  }
  
  log(`Stores imported successfully`, 'success');
}

async function importStoreAvailability(availability: StoreAvailabilityData[]) {
  log(`Importing ${availability.length} store availability records...`);
  
  for (const avail of availability) {
    // Check if store exists
    const store = await prisma.store.findUnique({
      where: { id: avail.storeId },
    });
    if (!store) {
      log(`Store ${avail.storeId} not found, skipping...`, 'warning');
      continue;
    }
    
    // Find the alternative record (product -> alternative)
    const alternative = await prisma.alternative.findFirst({
      where: {
        alternativeId: avail.alternativeProductId,
      },
    });
    
    if (!alternative) {
      log(`Alternative product ${avail.alternativeProductId} not found in alternatives table, skipping...`, 'warning');
      continue;
    }
    
    // Check if availability already exists
    const existing = await prisma.storeAvailability.findFirst({
      where: {
        storeId: avail.storeId,
        alternativeId: alternative.id,
      },
    });
    
    if (existing) {
      await prisma.storeAvailability.update({
        where: { id: existing.id },
        data: {
          priceMin: avail.priceMin,
          priceMax: avail.priceMax,
          currency: avail.currency ?? 'LYD',
          isAvailable: true,
        },
      });
    } else {
      await prisma.storeAvailability.create({
        data: {
          storeId: avail.storeId,
          alternativeId: alternative.id,
          priceMin: avail.priceMin,
          priceMax: avail.priceMax,
          currency: avail.currency ?? 'LYD',
          isAvailable: true,
        },
      });
    }
  }
  
  log(`Store availability imported successfully`, 'success');
}

async function clearDatabase() {
  log('Clearing existing data...', 'warning');
  
  // Delete in reverse order of dependencies
  await prisma.storeAvailability.deleteMany({});
  await prisma.alternative.deleteMany({});
  await prisma.store.deleteMany({});
  await prisma.evidenceSource.deleteMany({});
  await prisma.productClaim.deleteMany({});
  await prisma.companyClaim.deleteMany({});
  await prisma.claim.deleteMany({});
  await prisma.product.deleteMany({});
  await prisma.brand.deleteMany({});
  await prisma.company.deleteMany({});
  await prisma.category.deleteMany({});
  
  log('Database cleared', 'success');
}

// ==================== FILE LOADING ====================

function loadJsonFile<T>(filePath: string): T | null {
  if (!fs.existsSync(filePath)) {
    return null;
  }
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(content) as T;
  } catch (error) {
    log(`Failed to parse ${filePath}: ${error}`, 'error');
    return null;
  }
}

// ==================== MAIN ====================

async function main() {
  const args = process.argv.slice(2);
  
  // Parse arguments
  const dataDir = path.join(__dirname, '../../data');
  let dataFilePath = path.join(dataDir, 'boycott_data.json');
  let categoriesFilePath = path.join(dataDir, 'categories.json');
  let shouldClear = false;
  let categoriesOnly = false;
  
  for (const arg of args) {
    if (arg.startsWith('--file=')) {
      dataFilePath = arg.replace('--file=', '');
      if (!path.isAbsolute(dataFilePath)) {
        dataFilePath = path.join(process.cwd(), dataFilePath);
      }
    }
    if (arg.startsWith('--categories=')) {
      categoriesFilePath = arg.replace('--categories=', '');
      if (!path.isAbsolute(categoriesFilePath)) {
        categoriesFilePath = path.join(process.cwd(), categoriesFilePath);
      }
    }
    if (arg === '--clear') {
      shouldClear = true;
    }
    if (arg === '--categories-only') {
      categoriesOnly = true;
    }
  }
  
  log(`\n🚀 Starting Data Import`);
  log(`📂 Categories file: ${categoriesFilePath}`);
  if (!categoriesOnly) {
    log(`📂 Data file: ${dataFilePath}`);
  }
  
  // Load categories from separate file
  const categories = loadJsonFile<CategoryData[]>(categoriesFilePath);
  
  // Load other data from main file
  let data: ImportData = {};
  if (!categoriesOnly) {
    const loadedData = loadJsonFile<ImportData>(dataFilePath);
    if (loadedData) {
      data = loadedData;
    } else if (fs.existsSync(dataFilePath)) {
      log(`Failed to load data file`, 'error');
      process.exit(1);
    }
  }
  
  // Clear database if requested
  if (shouldClear) {
    await clearDatabase();
  }
  
  // Track counts for summary
  let categoriesCount = 0;
  
  // Import data in order
  try {
    // Import categories from separate file
    if (categories && categories.length > 0) {
      await importCategories(categories);
      categoriesCount = categories.length;
    } else if (data.categories && data.categories.length > 0) {
      // Fallback: check if categories are in main data file
      await importCategories(data.categories);
      categoriesCount = data.categories.length;
    }
    
    if (categoriesOnly) {
      log(`\n✨ Categories import completed!`, 'success');
      console.log(`\n📊 Import Summary:`);
      console.log(`   Categories: ${categoriesCount}`);
      return;
    }
    
    if (data.companies && data.companies.length > 0) {
      await importCompanies(data.companies);
    }
    
    if (data.brands && data.brands.length > 0) {
      await importBrands(data.brands);
    }
    
    if (data.products && data.products.length > 0) {
      await importProducts(data.products);
    }
    
    if (data.claims && data.claims.length > 0) {
      await importClaims(data.claims);
    }
    
    if (data.alternatives && data.alternatives.length > 0) {
      await importAlternatives(data.alternatives);
    }
    
    if (data.stores && data.stores.length > 0) {
      await importStores(data.stores);
    }
    
    if (data.storeAvailability && data.storeAvailability.length > 0) {
      await importStoreAvailability(data.storeAvailability);
    }
    
    log(`\n✨ Import completed successfully!`, 'success');
    
    // Print summary
    console.log('\n📊 Import Summary:');
    console.log(`   Categories: ${categoriesCount}`);
    console.log(`   Companies: ${data.companies?.length ?? 0}`);
    console.log(`   Brands: ${data.brands?.length ?? 0}`);
    console.log(`   Products: ${data.products?.length ?? 0}`);
    console.log(`   Claims: ${data.claims?.length ?? 0}`);
    console.log(`   Alternatives: ${data.alternatives?.length ?? 0}`);
    console.log(`   Stores: ${data.stores?.length ?? 0}`);
    console.log(`   Store Availability: ${data.storeAvailability?.length ?? 0}`);
    
  } catch (error) {
    log(`Import failed: ${error}`, 'error');
    throw error;
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

