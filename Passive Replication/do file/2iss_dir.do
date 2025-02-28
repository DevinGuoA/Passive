**********************************************************************************************
* Process ISS director data and compute the percentage of independent directors
**********************************************************************************************

use "${root}/raw data/issdir.dta", clear

* Compute the total number of directors per firm-year
bysort YEAR CUSIP: gen Total_Directors = _N

* Identify independent directors (classification "I") 
gen Independent_Directors = (CLASSIFICATION == "I")
bysort YEAR CUSIP: replace Independent_Directors = sum(Independent_Directors)
bysort YEAR CUSIP: replace Independent_Directors = Independent_Directors[_N]

* Compute the percentage of independent directors
gen Independent_Percentage = Independent_Directors / Total_Directors

* Keep only firm-year level data
keep YEAR CUSIP Independent_Percentage
duplicates drop

save "${root}/processing data/issdir.dta", replace

use "/Users/devin/Desktop/Passive/raw data/thomson.dta",clear

gen CUSIP=substr(cusip,1,6)

gen YEAR=year(fdate)

duplicates drop cusip fdate,force

save "${root}/processing data/thomson_replicate.dta",replace

use "${root}/processing data/thomson_replicate.dta",clear
merge m:1 CUSIP YEAR using "${root}/processing data/issdir.dta"

drop if missing(shrout2)& missing(shrout1)
egen mean_Independent_Percentage = mean(Independent_Percentage)
replace Independent_Percentage = mean_Independent_Percentage if missing(Independent_Percentage)
drop mean_Independent_Percentage


drop (_merge)

rename CUSIP CUSIP6
rename cusip CUSIP

gen qdate = qofd(fdate)
format qdate %tq

drop shrout1
drop shrout2
drop fundno
drop rdate
save "${root}/processing data/iss_dir_clean.dta",replace
use "${root}/processing data/iss_dir_clean.dta",clear
merge 1:1 CUSIP qdate using "/Users/devin/Desktop/Passive/processing data/ownership_final1.dta"
drop if _merge==1
drop _merge
save "/Users/devin/Desktop/Passive/processing data/ownership_dir.dta",replace
