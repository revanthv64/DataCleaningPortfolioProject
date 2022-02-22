/*
CLEANING DATA IN SQL QUERY
*/

SELECT *
FROM ProjectPortfolio1..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM ProjectPortfolio1..NashvilleHousing 

UPDATE ProjectPortfolio1..NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE ProjectPortfolio1..NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM ProjectPortfolio1..NashvilleHousing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio1..NashvilleHousing a
JOIN ProjectPortfolio1..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio1..NashvilleHousing a
JOIN ProjectPortfolio1..NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City. State)

SELECT PropertyAddress
FROM ProjectPortfolio1..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio1..NashvilleHousing

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD PropertySplitAddress nvarchar(255);

UPDATE ProjectPortfolio1..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD PropertySplitCity nvarchar(255);

UPDATE ProjectPortfolio1..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
	
SELECT *
FROM ProjectPortfolio1..NashvilleHousing

SELECT OwnerAddress
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio1..NashvilleHousing

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255);

UPDATE ProjectPortfolio1..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD OwnerSplitCity nvarchar(255);

UPDATE ProjectPortfolio1..NashvilleHousing 
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE ProjectPortfolio1..NashvilleHousing 
ADD OwnerSplitState nvarchar(255);

UPDATE ProjectPortfolio1..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

-----------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'SoldASVacant' Field

SELECT SoldAsVacant, COUNT(SoldASVacant)
FROM ProjectPortfolio1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Ý' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM ProjectPortfolio1..NashvilleHousing

UPDATE ProjectPortfolio1..NashvilleHousing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Ý' THEN 'Yes'
	                   WHEN SoldAsVacant = 'N' THEN 'No'
	                   ELSE SoldAsVacant
                   END

-----------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
                              ParcelID,
                              PropertyAddress,
							  SaleDate,
							  SalePrice,
							  LegalReference
							  ORDER BY UniqueID
							  ) RowNum
FROM ProjectPortfolio1..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1

-----------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM ProjectPortfolio1..NashvilleHousing

ALTER TABLE ProjectPortfolio1..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict



