/*

Cleaning Data in SQL

*/

Select *
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------

--Standardize Date Fromat
Select SaleDate , Convert(Date , SaleDate)
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

-- Populate property Adress Data
Select a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID]> b.[UniqueID]
--where a.PropertyAddress is null 

UPDATE a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID]> b.[UniqueID]
where a.PropertyAddress is null 

-----------------------------------------------------------------------------------------

--Breaking out Address into Indiviudal Columns

select 
Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) As Address,
Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) As Address
from  PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) 


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Breaking out Address into Indiviudal Columns(Using Parsename)

Select
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)
From PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)


-----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant) , count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by count(SoldAsVacant)

Select SoldAsVacant,
case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END

-----------------------------------------------------------------------------------------------
--Remove Duplicate

With RowNumCTE As(
Select*, 
ROW_NUMBER() Over(
Partition by ParcelID, Propertyaddress, Saledate, LegalReference 
Order BY UniqueID ) as row_num
from PortfolioProject..NashvilleHousing
)

Delete
From RowNumCTE
where row_num > 1;

-------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
from PortfolioProject..NashvilleHousing

Alter Table  PortfolioProject..NashvilleHousing
Drop Column SaleDate