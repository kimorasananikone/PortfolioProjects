/*
Cleaning Data in SQL Queries 
*/


SELECT * 
From portfolio.nashvillehousing; 
--------------------------------------------------------------------------------------------------------------------------

-- Standarized Date Format 

SELECT SaleDateConverted, CAST(SaleDate AS DATE) 
FROM portfolio.nashvillehousing;

UPDATE portfolio.nashvillehousing
SET SaleDate = CAST(SaleDate AS DATE);

-- If it doesn't Update properly 
ALTER TABLE nashvillehousing 
ADD COLUMN SaleDateConverted DATE;

UPDATE portfolio.nashvillehousing
SET SaleDateConverted = CAST(SaleDate AS DATE);

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 
SELECT *
FROM portfolio.nashvillehousing
-- Where PropertyAddress is null; 
order by ParcelID; 

SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    IFNULL(a.PropertyAddress, 
    b.PropertyAddress) 
FROM portfolio.nashvillehousing a 
JOIN portfolio.nashvillehousing b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null; 

UPDATE portfolio.nashvillehousing a 
    JOIN portfolio.nashvillehousing b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) 
SELECT PropertyAddress
From portfolio.nashvillehousing;
-- Where PropertyAddress is null 
-- order by ParcelID 

Select 
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS Address
From portfolio.nashvillehousing;

ALTER TABLE nashvillehousing 
ADD COLUMN PropertySplitAddress Nvarchar(255);

UPDATE portfolio.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE nashvillehousing 
ADD COLUMN PropertySplitCity  nvarchar(255);

UPDATE portfolio.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

Select * 
From portfolio.nashvillehousing; 

Select OwnerAddress
From portfolio.nashvillehousing; 



SELECT 
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3),
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2),
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1)
FROM 
    portfolio.nashvillehousing;

ALTER TABLE nashvillehousing 
ADD COLUMN OwnerSplitAddress Nvarchar(255);

UPDATE portfolio.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3);

ALTER TABLE nashvillehousing 
ADD COLUMN OwnerSplitCity  nvarchar(255);

UPDATE portfolio.nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2);

ALTER TABLE nashvillehousing 
ADD COLUMN OwnerSplitState Nvarchar(255);

UPDATE portfolio.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

Select * 
From portfolio.nashvillehousing; 

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio.nashvillehousing
Group by SoldAsVacant
order by 2; 

Select SoldAsVacant,  
    CASE When SoldAsVacant = 'Y' THEN 'YES' 
    When SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
    END 
From portfolio.nashvillehousing; 


UPDATE portfolio.nashvillehousing
    SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES' 
    When SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
    END;

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 

WITH RowNumCTE AS (
SELECT *, 
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID, 
    PropertyAddress, 
    SalePrice, 
    SaleDate, 
    LegalReference
    ORDER BY UniqueID
    ) AS row_num
FROM portfolio.nashvillehousing

-- order by ParcelID
) 
Select * 
From RowNumCTE
Where row_num > 1
order by PropertyAddress; 

Select * 
From portfolio.nashvillehousing 

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 
Select * 
From portfolio.nashvillehousing; 

ALTER TABLE portfolio.nashvillehousing 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;

ALTER TABLE portfolio.nashvillehousing 
DROP COLUMN SaleDate; 

