-- View the nashville data set
SELECT *
FROM nashvillehousing;

--CONVERTING SALEDATE TO DATE without '00:00'
--Sometimes the syntax dfrom the update function may not work.
--Maybe due to sql not able to replace the original column when used in a formular
Update nashvillehousing
SET SaleDate = CONVERT(smalldatetime, SaleDate)

--Alter table nashvillehousing
--Add sale_date date
--Update nashvillehousing
--set sale_date = CONVERT(date, SaleDate)

--Alter table nashvillehousing
--DROP column sale_date

--run to see if it works if not try alter
Alter Table nashvillehousing
Alter column SaleDate Date
--Select SaleDate from nashvillehousing;

-------------------------------------------------------------------------------------------------
--PROPERTY ADDRESS
SELECT * 
FROM nashvillehousing
where PropertyAddress is null -- THIS CODE IS TO SEE ALL THE DATA SET WHEN PROPERTY ADDRESS IS NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing as a
JOIN  nashvillehousing as b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null --JOINING THE SAME TABLE TO KNOW IF THE PROPERTY ADDRESS EXISTS WHEN THEY HAVE THE SAME PARCEL ID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing as a
JOIN  nashvillehousing as b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null --This creates another table where the null values in a are replaced with the values in b
--since they have the same parcel ID

Update a --Its best to use a instead of specifying everything, since a will be described as the entirety of the nashville data)
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing as a
JOIN  nashvillehousing as b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-----------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
FROM nashvillehousing

--using substring function

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as city
FROM nashvillehousing

Alter table nashvillehousing
Add address varchar(255),
city varchar(255)

Update nashvillehousing
SET address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--SELECT *
--FROM nashvillehousing;

--Doing the same for owner address
Select OwnerAddress
From nashvillehousing
where OwnerAddress is not null
--USING PARSENAME
Select OwnerAddress, PARSENAME(Replace(OwnerAddress,',','.'), 3) as owner_address,
PARSENAME(Replace(OwnerAddress,',','.'), 2) As owner_city, 
PARSENAME(Replace(OwnerAddress,',','.'), 1) As owner_state
From nashvillehousing
where OwnerAddress is not null
--Placing them in the original table
ALTER TABLE nashvillehousing
Add owner_address varchar(255),
owner_city varchar(255),
owner_state varchar(255)

Update nashvillehousing
SET owner_address = PARSENAME(Replace(OwnerAddress,',','.'), 3),
owner_city = PARSENAME(Replace(OwnerAddress,',','.'), 2),
owner_state = PARSENAME(Replace(OwnerAddress,',','.'), 1)
--select* FROM nashvillehousing
--Replacing null values in owner_address, owner_city etc
Select a.address, a.city, b.owner_address, b.owner_city, ISNULL(b.owner_address,a.address), 
ISNULL(b.owner_city, a.city)
from nashvillehousing as a
JOIN nashvillehousing as b
ON a.[UniqueID ]=b.[UniqueID ]
Where b.owner_address is null


Update b
SET owner_address = ISNULL(b.owner_address,a.address)
from nashvillehousing as a
JOIN nashvillehousing as b
ON a.[UniqueID ]=b.[UniqueID ]
Where b.owner_address is null

Update b
SET owner_city = ISNULL(b.owner_city, a.city)
from nashvillehousing as a
JOIN nashvillehousing as b
ON a.[UniqueID ]=b.[UniqueID ]
Where b.owner_city is null
--select* FROM nashvillehousing
--------------------------------------------------------------------------
--Replacing y and N to yes and no
SELECT *
FROM nashvillehousing;

Select SoldAsVacant, count(SoldAsVacant)
FROM nashvillehousing
group by SoldAsVacant

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                   END;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashvillehousing
--order by ParcelID
)
Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- To completely remove the duplicates
--WITH RowNumCTE AS(
--Select *,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,  PropertyAddress, SalePrice,SaleDate, LegalReference, ORDER BY, UniqueID) row_num
--From nashvillehousing
--order by ParcelID
)
--Delete
--From RowNumCTE
--Where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From nashvillehousing


ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate