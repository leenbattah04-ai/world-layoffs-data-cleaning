-- DATA CLEANING PROJECT - WORLD LAYOFFS--
-- 1. Remove duplicates 
-- 2. Standardize the data 
-- 3. Null values or blank values 
-- 4. Remove any columns OP row
-- ****************************
-- 1. CREATE STAGING TABLE

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs; 

-- 2. REMOVE DUPLICATES
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
 SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
           ) AS row_num
    FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;


SELECT *
FROM layoffs_staging2;

-- 3. STANDARDIZE DATA
-- Remove leading and trailing spaces from company names

SELECT company, TRIM(company)
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry names
SELECT  distinct industry 
FROM layoffs_staging2
order by 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT  distinct industry 
FROM layoffs_staging2;


SELECT  distinct location 
FROM layoffs_staging2
order by 1;

SELECT  distinct country 
FROM layoffs_staging2
order by 1;

-- Standardize country names
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
order by 1;

SELECT distinct country , TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1; 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date from TEXT to DATE

SELECT `date`,
STR_TO_DATE (`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE (`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY column `date` DATE;

select *
FROM layoffs_staging2;

-- 4. HANDLE NULL AND BLANK VALUES

select *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select distinct industry
FROM layoffs_staging2 ;

select *
FROM layoffs_staging2 
WHERE industry IS NULL 
OR industry='' ;

-- Convert blank values to NULL
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '' ;

select *
FROM layoffs_staging2 
WHERE company ='Airbnb';

select *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
 ON t1.company = t2.company
 AND t1.location = t2.location
 WHERE t1.industry IS NULL 
 AND t2.industry IS NOT NULL ;

-- Fill missing industry values using self join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
 ON t1.company = t2.company
 SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
 AND t2.industry IS NOT NULL ;
 
 SELECT *
 FROM layoffs_staging2
 WHERE company LIKE 'Bally%'; 
 
 SELECT *
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL ;
 
 SELECT COUNT(*)
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 5. REMOVE UNNECESSARY ROWS
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
 FROM layoffs_staging2;
 
 -- 6. DROP HELPER COLUMN
 ALTER TABLE layoffs_staging2
 drop column row_num;
 
 -- CLEANED DATA
SELECT *
FROM layoffs_staging2;