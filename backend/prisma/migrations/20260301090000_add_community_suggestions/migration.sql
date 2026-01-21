-- CreateTable
CREATE TABLE "community_suggestions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "textAr" TEXT NOT NULL,
    "companyName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "community_suggestions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suggestion_likes" (
    "id" TEXT NOT NULL,
    "suggestionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "suggestion_likes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "suggestion_likes_suggestionId_userId_key" ON "suggestion_likes"("suggestionId", "userId");

-- AddForeignKey
ALTER TABLE "community_suggestions" ADD CONSTRAINT "community_suggestions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "suggestion_likes" ADD CONSTRAINT "suggestion_likes_suggestionId_fkey" FOREIGN KEY ("suggestionId") REFERENCES "community_suggestions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "suggestion_likes" ADD CONSTRAINT "suggestion_likes_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
