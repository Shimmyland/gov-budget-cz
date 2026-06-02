ALTER TABLE "budget_facts" ADD COLUMN "fiscal_month" smallint NOT NULL;--> statement-breakpoint
CREATE INDEX "idx_facts_year_month" ON "budget_facts" USING btree ("fiscal_year","fiscal_month");