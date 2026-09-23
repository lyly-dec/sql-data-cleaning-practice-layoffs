USE word_layoffs
SELECT * 
FROM word_layoffs.layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Valuse or blank valiuse
-- 4. Remove Any Columns
-- Tạo một database như layoffs
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT*
FROM layoffs_staging
-- Thêm dữ liệu vào database mới tạo
INSERT layoffs_staging
SELECT *
FROM layoffs
-- 1. Kiểm tra xem dữ liệu nào bị Duplicate
WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, 
percentage_laid_off, `date`, stage, funds_raised_millions) AS row_num
FROM layoffs_staging
) 
SELECT *
FROM duplicate_CTE
WHERE row_num > 1
-- Tạo thêm bảng layoff
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
  `row_nume` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- Thêm dữ liệu vào
INSERT layoffs_staging2
WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, 
percentage_laid_off, `date`, stage, funds_raised_millions) AS row_nume
FROM layoffs_staging
) 
SELECT *
FROM duplicate_CTE
-- Lọc dữ liệu bị trùng ( row_nume > 2)
SELECT * 
FROM layoffs_staging2
WHERE row_nume > 1
-- Xóa nó đi
DELETE 
FROM layoffs_staging2
WHERE row_nume > 1;
-- Giờ xem lại 
SELECT * 
FROM layoffs_staging2
WHERE row_nume > 1 -- Không còn nữa

SELECT * 
FROM layoffs_staging2
-- 2.Standardizing the Data ( Finding issues in data and fixing it) 
-- Đầu tiên là Company
SELECT company, TRIM(company)
FROM layoffs_staging2

UPDATE layoffs_staging2
SET company = TRIM(company)
-- Tieps là Industry
UPDATE layoffs_staging2
SET industry = TRIM(industry)

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1 -- Nhận thấy cõ lối Crypto Currency

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
SELECT DISTINCT industry
FROM layoffs_staging2;
-- Tiếp là location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
-- Country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT*
FROM layoffs_staging2
WHERE country LIKE 'United States%' -- dấu chấm ở cuối
-- Bỏ dấu chấm đi
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
-- Đổi kiểu dữ liệu của Date
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y') -- đổi thành kiểu data và hiển thị Y/M/D
FROM layoffs_staging2

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y') 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- ĐỔi thành kiểu date
-- KIỂM TRA NULL 
SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_staging2
WHERE industry IS NULL or industry = ''
-- Thống nhất NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''

SELECT*
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Tìm những công ty có thể fill giá trị cho nhau
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location -- Nếu có cùng company và location thì có thể cùng industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL
-- Update vào
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL
-- kIỂM TRA LẠI XEM CÒN INDUSTRY NÀO NULL KO
SELECT*
FROM layoffs_staging2
WHERE industry IS NULL -- kết quả hiện còn 1 công ty NULL
-- Kiểm tra xem còn công ty nào tên như vậy ko
SELECT*
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
-- Kiểm tra total_laid_off và percentage_laid_off
SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Hoàn thành, xóa cột row_nume ban đầu
ALTER TABLE layoffs_staging2
DROP COLUMN row_nume;


SELECT*
FROM layoffs_staging2







