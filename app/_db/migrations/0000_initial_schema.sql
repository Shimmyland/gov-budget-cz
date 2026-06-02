CREATE TYPE "public"."category_type" AS ENUM('expense', 'income');--> statement-breakpoint
CREATE TABLE "budget_facts" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"fiscal_year" smallint NOT NULL,
	"org_unit_id" integer,
	"paragraph_id" integer NOT NULL,
	"item_id" integer NOT NULL,
	"value" numeric(14, 2) NOT NULL,
	"is_approved" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "categories" (
	"id" serial PRIMARY KEY NOT NULL,
	"parent_id" integer,
	"slug" varchar(60) NOT NULL,
	"type" "category_type" NOT NULL,
	"is_mandatory" boolean DEFAULT false NOT NULL,
	CONSTRAINT "categories_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "category_paragraph_map" (
	"category_id" integer NOT NULL,
	"paragraph_id" integer NOT NULL,
	CONSTRAINT "category_paragraph_map_category_id_paragraph_id_pk" PRIMARY KEY("category_id","paragraph_id")
);
--> statement-breakpoint
CREATE TABLE "chapter_org_units" (
	"id" serial PRIMARY KEY NOT NULL,
	"chapter_id" integer NOT NULL,
	"code" varchar(20) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "chapter_org_units_chapterId_code_unique" UNIQUE("chapter_id","code")
);
--> statement-breakpoint
CREATE TABLE "chapters" (
	"id" serial PRIMARY KEY NOT NULL,
	"code" varchar(10) NOT NULL,
	"slug" varchar(100) NOT NULL,
	CONSTRAINT "chapters_code_unique" UNIQUE("code"),
	CONSTRAINT "chapters_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "economic_classes" (
	"id" serial PRIMARY KEY NOT NULL,
	"code" char(1) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "economic_classes_code_unique" UNIQUE("code"),
	CONSTRAINT "economic_classes_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "economic_groups" (
	"id" serial PRIMARY KEY NOT NULL,
	"class_id" integer NOT NULL,
	"code" varchar(2) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "economic_groups_code_unique" UNIQUE("code"),
	CONSTRAINT "economic_groups_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "economic_items" (
	"id" serial PRIMARY KEY NOT NULL,
	"group_id" integer NOT NULL,
	"code" varchar(4) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "economic_items_code_unique" UNIQUE("code"),
	CONSTRAINT "economic_items_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "functional_divisions" (
	"id" serial PRIMARY KEY NOT NULL,
	"code" varchar(2) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "functional_divisions_code_unique" UNIQUE("code"),
	CONSTRAINT "functional_divisions_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "functional_paragraphs" (
	"id" serial PRIMARY KEY NOT NULL,
	"subdivision_id" integer NOT NULL,
	"code" varchar(4) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "functional_paragraphs_code_unique" UNIQUE("code"),
	CONSTRAINT "functional_paragraphs_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "functional_subdivisions" (
	"id" serial PRIMARY KEY NOT NULL,
	"division_id" integer NOT NULL,
	"code" varchar(3) NOT NULL,
	"slug" varchar(100) NOT NULL,
	"name_cs" text NOT NULL,
	CONSTRAINT "functional_subdivisions_code_unique" UNIQUE("code"),
	CONSTRAINT "functional_subdivisions_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
ALTER TABLE "budget_facts" ADD CONSTRAINT "budget_facts_org_unit_id_chapter_org_units_id_fk" FOREIGN KEY ("org_unit_id") REFERENCES "public"."chapter_org_units"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "budget_facts" ADD CONSTRAINT "budget_facts_paragraph_id_functional_paragraphs_id_fk" FOREIGN KEY ("paragraph_id") REFERENCES "public"."functional_paragraphs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "budget_facts" ADD CONSTRAINT "budget_facts_item_id_economic_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."economic_items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_categories_id_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."categories"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "category_paragraph_map" ADD CONSTRAINT "category_paragraph_map_category_id_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "category_paragraph_map" ADD CONSTRAINT "category_paragraph_map_paragraph_id_functional_paragraphs_id_fk" FOREIGN KEY ("paragraph_id") REFERENCES "public"."functional_paragraphs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "chapter_org_units" ADD CONSTRAINT "chapter_org_units_chapter_id_chapters_id_fk" FOREIGN KEY ("chapter_id") REFERENCES "public"."chapters"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "economic_groups" ADD CONSTRAINT "economic_groups_class_id_economic_classes_id_fk" FOREIGN KEY ("class_id") REFERENCES "public"."economic_classes"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "economic_items" ADD CONSTRAINT "economic_items_group_id_economic_groups_id_fk" FOREIGN KEY ("group_id") REFERENCES "public"."economic_groups"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "functional_paragraphs" ADD CONSTRAINT "functional_paragraphs_subdivision_id_functional_subdivisions_id_fk" FOREIGN KEY ("subdivision_id") REFERENCES "public"."functional_subdivisions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "functional_subdivisions" ADD CONSTRAINT "functional_subdivisions_division_id_functional_divisions_id_fk" FOREIGN KEY ("division_id") REFERENCES "public"."functional_divisions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_facts_fiscal_year" ON "budget_facts" USING btree ("fiscal_year");--> statement-breakpoint
CREATE INDEX "idx_facts_org_unit" ON "budget_facts" USING btree ("org_unit_id");--> statement-breakpoint
CREATE INDEX "idx_facts_paragraph" ON "budget_facts" USING btree ("paragraph_id");--> statement-breakpoint
CREATE INDEX "idx_facts_item" ON "budget_facts" USING btree ("item_id");--> statement-breakpoint
CREATE INDEX "idx_facts_year_org" ON "budget_facts" USING btree ("fiscal_year","org_unit_id");