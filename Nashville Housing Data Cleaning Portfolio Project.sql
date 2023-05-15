/*

Cleaning Data in SQL Queries

*/

SELECT TOP (100) *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------

-- Standardising Date Format by removing time in datetime column

SELECT SaleDate, CONVERT (Date, SaleDate) AS DateOnly
FROM PortfolioProject..NashvilleHousing

--Update NashvilleHousing
--SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

SELECT TOP (10) *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- The script above shows that a specific parcel ID refers to a specific address. So, if the Property Address is NULL, we can look up the parcel ID to try to find the address.
-- The script below shows the address for the null Property Address.

SELECT T1.UniqueID, T1.ParcelID, T1.PropertyAddress, T2.UniqueID, T2.ParcelID, T2.PropertyAddress
FROM PortfolioProject..NashvilleHousing AS T1
JOIN PortfolioProject..NashvilleHousing AS T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL



SELECT T1.UniqueID, T1.ParcelID, T1.PropertyAddress, T2.UniqueID, T2.ParcelID, T2.PropertyAddress, ISNULL (T1.PropertyAddress, T2.PropertyAddress) AS PopulatedPropertyAddress
FROM PortfolioProject..NashvilleHousing AS T1
JOIN PortfolioProject..NashvilleHousing AS T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL


Update T1
SET PropertyAddress = ISNULL (T1.PropertyAddress, T2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS T1
JOIN PortfolioProject..NashvilleHousing AS T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address column into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN (PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

--SELECT TOP (100) *
--FROM PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

--SELECT TOP (100) *
--FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

--SELECT TOP (100) *
--FROM PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN (PropertyAddress))

SELECT TOP (100) *
FROM PortfolioProject..NashvilleHousing



SELECT TOP (100) OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT TOP (100)
  PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3) AS AddressParsed
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2) AS CityParsed
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) AS StateParsed
FROM PortfolioProject..NashvilleHousing




ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerAddressParsed nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerAddressParsed	= PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCityParsed nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerCityParsed	= PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerStateParsed nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerStateParsed	= PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

SELECT TOP (100) *
FROM PortfolioProject..NashvilleHousing

SELECT TOP (100) OwnerAddress, OwnerAddressParsed, OwnerCityParsed, OwnerStateParsed
FROM PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject..NashvilleHousing

SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing
WHERE SoldAsVacant = 'Y'
OR SoldAsVacant = 'N'



UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END

SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1




WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing