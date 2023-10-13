
-- Cleaning Data in SQL

Select *
From PortfolioProject.dbo.NashvilleHousing



--Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter Table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------

--Population Propety Address date

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
,isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a 
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a 
join PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing



Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
From PortfolioProject.dbo.NashvilleHousing



Alter Table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



-- Breaking out OwnerAddress into Individual Columns
Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
add 
OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set 
OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)



Select *
From PortfolioProject.dbo.NashvilleHousing
-------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing



Update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
--------------------------------------

--Remove Duplicates


with RowNumCTE as
(
Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID 
)

Delete
From RowNumCTE
Where row_num > 1


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
----------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, SaleDate, TaxDistrict, PropertyAddress


