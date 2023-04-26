Select * 
From HousingProject..Nashville


--Converting date format


Alter Table Nashville
Add SaleDateConverted date;


Update Nashville
Set SaleDateConverted = convert(date, saledate)


Select SaleDateConverted
From HousingProject..Nashville


--Populate property adress data

Select *
From HousingProject..Nashville
where propertyaddress is null



Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
From HousingProject..Nashville a
Join HousingProject..Nashville b
	on a.parcelID = b.parcelID
	and a.uniqueid <> b.uniqueid
Where a.propertyaddress is null

Update a
Set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
From HousingProject..Nashville a
Join HousingProject..Nashville b
	on a.parcelID = b.parcelID
	and a.uniqueid <> b.uniqueid
Where a.propertyaddress is null


--Breaking out address into individual columns (address, city, state)


Select propertyaddress
From HousingProject..Nashville


Select
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as address
, substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address
From HousingProject..Nashville



Alter Table Nashville
Add PropertySplitAddress nvarchar(255);


Update Nashville
Set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

Alter Table Nashville
Add PropertySplitCity nvarchar(255);


Update Nashville
Set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))







Select OwnerAddress
From HousingProject..Nashville


Select
Parsename(Replace(OwnerAddress, ',', '.'), 3)
,Parsename(Replace(OwnerAddress, ',', '.'), 2)
,Parsename(Replace(OwnerAddress, ',', '.'), 1)
From HousingProject..Nashville


Alter Table Nashville
Add OwnerSplitAddress nvarchar(255);


Update Nashville
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)


Alter Table Nashville
Add OwnerSplitCity nvarchar(255);


Update Nashville
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)



Alter Table Nashville
Add OwnerSplitState nvarchar(255);


Update Nashville
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)



--Change Y and N to Yes and No in "Sold as Vacant"


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingProject..Nashville
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end
From HousingProject..Nashville

Update Nashville
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   end


--Remove Duplicates

With RowNumCTE AS(
Select *,
	row_number() OVER (
	Partition by parcelID,
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by
				uniqueID
				) row_num


From HousingProject..Nashville
--order by parcelID
)

delete
From RowNumCTE
Where row_num > 1


-- Delete unused columns


Alter Table HousingProject..Nashville
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table HousingProject..Nashville
Drop column SaleDate





