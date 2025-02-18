/*

Cleaning Data in Sql Queries

*/


Select * from DataExploration..NashvilleHousing


-- Standardize Date Format


Select SaleDateConverted, Convert(Date, SaleDate)
from DataExploration..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate);



-- Populate Empty/Null Property Address fields

Select * from DataExploration..NashvilleHousing
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from DataExploration..NashvilleHousing a
join DataExploration..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from DataExploration..NashvilleHousing a
join DataExploration..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into different columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address
from DataExploration..NashvilleHousing

Alter Table DataExploration..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Alter Table DataExploration..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update DataExploration..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Update DataExploration..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


Select OwnerAddress from DataExploration..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from DataExploration..NashvilleHousing
where OwnerAddress is not null

Alter Table DataExploration..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table DataExploration..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table DataExploration..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update DataExploration..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

Update DataExploration..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

Update DataExploration..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);



-- Change Y and N to 'Yes' and 'No' in SoldAsVacant Field

Update DataExploration..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
               When SoldAsVacant = 'N' Then 'No'
			   ELSE SoldAsVacant
			   END


-- Remove Duplicates

With cte as(
Select *, ROW_NUMBER() Over (
Partition By ParcelID,
PropertyAddress,
SalePrice,
SaleDate
Order by UniqueID
) row_num
from DataExploration..NashvilleHousing
)

Delete from cte
where row_num>1


--Delete unused Columns

Alter Table DataExploration..NashvilleHousing
Drop Column PropertyAddress, SaleDateConverted, OwnerAddress, TaxDistrict

Select * from DataExploration..NashvilleHousing