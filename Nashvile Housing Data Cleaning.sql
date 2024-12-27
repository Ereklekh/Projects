SELECT * FROM `Nashvie Housing`.housing1;

SELECT *
FROM housing1;

-- standardize Date format
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M/%d/%Y') AS ConvertedDate
FROM housing1
WHERE STR_TO_DATE(SaleDate, '%M %d, %Y') IS NOT NULL;


SELECT DISTINCT SaleDate FROM housing1 LIMIT 10;

SELECT SaleDate, 
       STR_TO_DATE(TRIM(SaleDate), '%M %d, %Y') AS ConvertedDate
FROM housing1;

update housing1
set SaleDate = STR_TO_DATE(TRIM(SaleDate), '%M %d, %Y');


select *
from housing1;

-- Populate Property Address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from housing1 a
join housing1 b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
;

UPDATE housing1 a
JOIN housing1 b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from housing1
;

SELECT PropertyAddress,
       SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)- 1) AS Address,
       SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM housing1;

ALTER TABLE housing1
ADD COLUMN PropertySplitAddress VARCHAR(255);



alter table housing1
add column PropertySplitCity varchar(255);

update housing1
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)- 1);

update housing1
set PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

select * from housing1;


select OwnerAddress 
from housing1;

SELECT OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS AddressPart1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS AddressPart2,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS AddressPart3
FROM housing1;


ALTER TABLE housing1
ADD COLUMN OwnerSplitAddres VARCHAR(255);

ALTER TABLE housing1
ADD COLUMN OwnerSplitCity VARCHAR(255);

ALTER TABLE housing1
ADD COLUMN OwnerSplitState VARCHAR(255);



update housing1
set OwnerSplitAddres = SUBSTRING_INDEX(OwnerAddress, ',', 1);

update housing1
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

update housing1
set OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

Select * from housing1;

-- Change Y and N to Yes and No

select distinct(SoldAsVacant), count(SoldAsVacant) 
from housing1
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from housing1;




update housing1
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end;

select * from housing1
where SoldAsVacant = 'N' or SoldAsVacant = 'Y';



-- Remove Duplicates

with Rank_numCTE as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
			 PropertyAddress, 
             SalePrice, SaleDate, 
             LegalReference 
             ORDER BY UniqueID) as row_num
from housing1
order by UniqueID
)
delete h
from housing1 h
join Rank_numCTE r
    on h.UniqueID = r.UniqueID
where r.row_num > 1;


-- Check if duplicates are deleted
with Rank_numCTe as
(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
			 PropertyAddress, 
             SalePrice, SaleDate, 
             LegalReference 
             ORDER BY UniqueID) as row_num
from housing1
order by UniqueID
)
select *
from Rank_numCTe
where row_num > 1;

-- Delete unesed Columns

alter table housing1
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;


select *
from housing1;





