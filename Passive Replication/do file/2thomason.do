/***********************************************************************************************
This script:
By running this script, you are expected to:
- Generate ownership percentage of mutual funds.
- Merge Thomson Reuters mutual fund data with CRSP stock data.
***********************************************************************************************/

clear all
set more off

***********************************************************************************************
* Step 1: Clean Thomson Mutual Fund Holdings Data
***********************************************************************************************

* Load Thomson Reuters mutual fund holdings dataset
use "${root}/raw data/thomson.dta", clear

* Rename key variables for consistency
rename cusip CUSIP
rename shrout1 shares_million
rename shrout2 shares_thousand

* Generate total shares held by the fund
gen shares_held = shares_million * 1000 if !missing(shares_million)
replace shares_held = shares_thousand if missing(shares_held)

* Drop unnecessary variables and missing CUSIP entries
drop shares_million shares_thousand
drop if missing(CUSIP)

* Encode CUSIP for easier handling
encode CUSIP, gen(nCUSIP)

* Generate quarterly date variable
gen qdate = qofd(fdate)
format qdate %tq

* Set panel structure
duplicates drop nCUSIP qdate,force
xtset nCUSIP qdate

* Remove duplicates and fill missing values where applicable
duplicates drop nCUSIP qdate, force
xtset nCUSIP qdate
tsfill, full
bysort CUSIP (qdate): replace shares_held = shares_held[_n-1] if missing(shares_held) & qdate < yq(2004,2)

* Extract 6-digit CUSIP prefix
gen CUSIP6 = substr(CUSIP,1,6)

* Save cleaned Thomson data
save "${root}/raw data/thomson1.dta", replace

***********************************************************************************************
* Step 2: Merge with ISS Director Data
***********************************************************************************************

use "${root}/raw data/thomson1.dta", clear
rename CUSIP CUSIP8
rename CUSIP6 CUSIP

* Generate year variable
gen YEAR = year(fdate)

* Merge with ISS director dataset
merge m:1 CUSIP YEAR using "${root}/processing data/issdir.dta"
drop _merge
save "${root}/raw data/thomson_issdir.dta", replace

***********************************************************************************************
* Step 3: Process CRSP Data for Market Capitalization
***********************************************************************************************

use "${root}/raw data/crspmissing.dta", clear
rename date fdate

* Remove observations with non-positive prices
drop if PRC <= 0

* Compute market capitalization
gen market_cap = 3 * PRC * SHROUT * 1000

* Remove unnecessary variables
duplicates drop CUSIP fdate, force
drop ACPERM ACCOMP NWPERM

* Save processed market capitalization data
save "${root}/processing data/crsp_marketcap.dta", replace

***********************************************************************************************
* Step 4: Merge Thomson and CRSP Data
***********************************************************************************************

use "${root}/processing data/crsp_marketcap.dta", clear
gen CUSIP6 = substr(CUSIP,1,6)
rename CUSIP CUSIP8
rename CUSIP6 CUSIP
duplicates drop CUSIP fdate, force

* Merge with cleaned Thomson mutual fund data
merge 1:1 fdate CUSIP using "${root}/processing data/thomson_cleaned1.dta"
save "${root}/prepared data/thomson_cleaned_iss.dta", replace

***********************************************************************************************
* Step 5: Compute Fund Ownership Percentages
***********************************************************************************************

use "${root}/prepared data/thomson_cleaned_iss.dta", clear

gen adj_price = abs(PRC) * CFACPR

gen imputed_value = (shares_held * 1000) * adj_price

* Remove extreme and unreasonable values
drop if imputed_value > market_cap
gen fund_holding_pct = imputed_value * 100 / market_cap
drop if missing(fund_holding_pct)
drop if shares_held > SHROUT
drop if YEAR == 1997 | YEAR == 2007
drop if missing(CIK)
drop _merge

* Winsorize fund ownership percentage to remove outliers
winsor2 fund_holding_pct, cuts(1,99) replace

* Save final processed mutual fund data
save "${root}/processing data/mutualfund.dta", replace

***********************************************************************************************
* Step 6: Integrate with Russell 2000 Index Data
***********************************************************************************************

use "${root}/processing data/mutualfund.dta", clear
use "/Users/devin/Desktop/Passive/raw data/R2000.dta", clear
rename Date fdate
gen qdate = qofd(fdate)
format qdate %tq
gen CUSIP8 = substr(CUSIP,1,8)
sort CUSIP8 qdate

gen month = month(fdate)
keep if month == 5 | month == 1 | month == 9 | month == 12

* Merge Russell index data with mutual fund ownership data
merge 1:1 CUSIP8 qdate using "${root}/processing data/mutualfund.dta"
keep if _merge == 3
drop _merge
save "${root}/processing data/mutualfund_v1.dta", replace

***********************************************************************************************
* Step 7: Compute Passive, Active, and Unclassified Fund Ownership
***********************************************************************************************

use "${root}/processing data/mutualfund_v1.dta", clear
gen yearmonth = ym(year(fdate), month(fdate))
format yearmonth %tm
save "${root}/processing data/mutualfund_v2.dta", replace

use "/Users/devin/Desktop/Passive/raw data/russell_all.dta", clear
rename cusip CUSIP8
gen YEAR = floor(yearmonth / 12) + 1960

merge 1:m CUSIP8 YEAR using "${root}/processing data/mutualfund_v2.dta"
keep if _merge == 3
drop _merge
save "${root}/processing data/mutualfund_v3.dta", replace

***********************************************************************************************
* Step 8: Compute Fund Voting Behavior
***********************************************************************************************

use "/Users/devin/Desktop/Passive/raw data/issvote.dta", clear
gen year = year(MeetingDate)
gen month = month(MeetingDate)
gen fiscal_year = year
replace fiscal_year = fiscal_year + 1 if month >= 7

gen total_votes = votedFor + votedAgainst + votedAbstain
gen is_management = (sponsor == "Management")
collapse (sum) votedFor total_votes, by(CUSIP fiscal_year is_management)
gen support_rate = votedFor / total_votes
gen support_rate_management = .
replace support_rate_management = support_rate if is_management == 1
gen support_rate_shareholder = .
replace support_rate_shareholder = support_rate if is_management == 0
collapse (mean) support_rate_management support_rate_shareholder, by(CUSIP fiscal_year)

gen CUSIP8 = substr(CUSIP,1,8)
rename fiscal_year YEAR
merge 1:m CUSIP8 YEAR using "${root}/processing data/mutualfund_v3.dta"
drop if _merge == 1
drop _merge
save "${root}/processing data/mutualfund_v4.dta", replace

***********************************************************************************************
* Step 9: Compute Final Ownership Metrics
***********************************************************************************************

use "/Users/devin/Desktop/Passive/processing data/ownershippassive2.dta", clear
rename cusip CUSIP8
gen YEAR = year(fdate)
merge 1:m CUSIP8 YEAR using "${root}/processing data/mutualfund_v4.dta"
keep if _merge == 3
drop _merge

gen passive_pct = shrout_passive * 1000 * PRC / market_cap
gen active_pct = shrout_active * 1000 * PRC / market_cap
gen unclassified_pct = shrout_unclassified * 1000 * PRC / market_cap

save "${root}/prepared data/mutualfund_v1.dta", replace
