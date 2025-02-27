**********************************************************************************************
* Process Thomson (fund holdings data), adjust shrout variable, and save
**********************************************************************************************

* Load Thomson Reuters mutual fund holdings dataset
use "/Users/devin/Desktop/Passive/raw data/thomson.dta", clear

* Drop redundant date variable
drop rdate

* Adjust share outstanding (shrout) variable
gen shrout = shrout1 * 1000  // Convert millions to actual share count
replace shrout = shrout2 if missing(shrout)  // Use shrout2 if shrout1 is missing

* Drop unnecessary variables
drop shrout1 shrout2

* Extract the month from the report date
gen month = month(fdate)

* Keep only observations from September
keep if month == 9

* Drop missing CUSIP entries
drop if missing(cusip)

* Save the processed Thomson dataset
save "/Users/devin/Desktop/Passive/processing data/thomson_for_passive.dta", replace

**********************************************************************************************
* Merge Thomson fund holdings with MFLINKS data to classify funds as passive or active
**********************************************************************************************

* Reload processed Thomson data
use "/Users/devin/Desktop/Passive/processing data/thomson_for_passive.dta", clear

* Merge with MFLINKS dataset using fund number and date
merge m:1 fundno fdate using "/Users/devin/Desktop/Passive/raw data/mflink2_raw.dta"

* Keep only matched observations
keep if _merge == 3
drop _merge

* Drop redundant date variable
drop rdate

* Initialize passive flag variable
gen passive_flag = 0

* Convert fund names to lowercase for consistent regex matching
gen fund_name = lower(fundname)

* Identify index funds using common passive fund name indicators
replace passive_flag = 1 if regexm(fund_name, "index|idx|indx|ind_|russell|s & p|s and p|s&p|sandp|sp|dow|dj|msci|bloomberg|kbw|nasdaq|nyse|stoxx|ftse|wilshire|morningstar|100|400|500|600|900|1000|1500|2000|5000")

* Save processed data with passive classification
save "/Users/devin/Desktop/Passive/processing data/thomson_mflink_for_passive.dta", replace

**********************************************************************************************
* Classify funds into Passive and Active categories
**********************************************************************************************

* Load processed Thomson-MFLINKS dataset
use "/Users/devin/Desktop/Passive/processing data/thomson_mflink_for_passive.dta", clear

* Drop observations with missing CUSIP
drop if missing(cusip)

* Assign fund type based on passive classification
gen fund_type = "Passive" if passive_flag == 1
replace fund_type = "Active" if passive_flag == 0

* Save the updated dataset
save "/Users/devin/Desktop/Passive/processing data/thomson_mflink_for_passive1.dta", replace

**********************************************************************************************
* Merge with CRSP fund summary to classify unclassified funds
**********************************************************************************************

* Load CRSP fund summary dataset
use "/Users/devin/Desktop/Passive/raw data/crsp_fund_summary.dta", clear

* Remove duplicate fund numbers
duplicates drop crsp_fundno, force

* Keep only relevant variables
keep crsp_fundno

* Rename variable for merging
rename crsp_fundno fundno

* Merge with the Thomson-MFLINKS dataset
merge 1:m fundno using "/Users/devin/Desktop/Passive/processing data/thomson_mflink_for_passive1.dta"

* Classify unmatched funds as "Unclassified"
replace fund_type = "Unclassified" if _merge == 2

* Drop unmatched observations from the CRSP dataset
drop if _merge == 1
drop _merge

* Keep only necessary variables
keep fundno shrout fdate fund_type cusip

* Save ownership classification dataset
save "/Users/devin/Desktop/Passive/processing data/ownershippassive1.dta", replace

**********************************************************************************************
* Aggregate fund shareholdings by classification (Active, Passive, Unclassified)
**********************************************************************************************

* Generate shareholding variables by fund type
gen shrout_active = shrout if fund_type == "Active"
gen shrout_passive = shrout if fund_type == "Passive"
gen shrout_unclassified = shrout if fund_type == "Unclassified"

* Replace missing values with zero
replace shrout_active = 0 if missing(shrout_active)
replace shrout_passive = 0 if missing(shrout_passive)
replace shrout_unclassified = 0 if missing(shrout_unclassified)

* Aggregate shareholdings at the CUSIP-date level
collapse (sum) shrout_active shrout_passive shrout_unclassified, by(cusip fdate)

* Save the final ownership dataset
save "/Users/devin/Desktop/Passive/processing data/ownershippassive2.dta", replace
