This program takes a file of weather data containing multiple years of 
drought data at collection district level with fields 
geoid, cd_code, year, month, avsum and avcount.
The data must start 13 months before the first date of interest. 

It skips the first 12 entries and then calculates the drought status and the 
number of months in the preceding 12 where drought status would be 
declared in NSW, VIC or either.  

It gives drought status as NSW if avcount >= 5 and for Victoria if avsum 
<= -17.5 

It also includes the maximum avcount and the minimum avsum in the 
previous 12 months and the month and year in which they occurred.

It gives also says whether the cd entered or left drought in the 12 month period 

The output fields are CD_code, year, month, IndroughtNSW, IndroughtVIC, 
MonthsInDroughtNSW, MonthsInDroughtVIC, MonthsInDroughtAll, 
MaxAvcount, MaxMonth, MaxYear, MinAvsum, MinMonth, MinYear, 
EnterDroughtNSW, leaveDroughtNSW, EnterDroughtVIC, leaveDroughtVIC
