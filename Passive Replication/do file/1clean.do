/***********************************************************************************************
This script:
By running this script, you are expected to:
- Generate all necessary variables
- Merge datasets to obtain required outputs
- Address missing values and remove outliers
***********************************************************************************************/

clear all
set more off

//************** Clean the dataset **************//

do "${root}/do file/2iss_dir.do"

do "${root}/do file/2passive.do"
* "${root}/prepared data/ownershippassive2.dta" is generated

do "${root}/do file/2thomason.do"
* "${root}/processing data/mutualfund.dta" is generated

do "${root}/do file/2roa.do"
* "${root}/prepared data/mutualfund_v2.dta" is generated

use "${root}/prepared data/mutualfund_v3.dta",clear
keep CUSIP8 yearmonth qdate DUALCLASS PPILL LSPMT r2000 switch2to1 switch1to2 Russell2000 Independent_Percentage fund_holding_pct active_pct passive_pct unclassified_pct support_rate_management support_rate_shareholder adj_mrktvalue roa YEAR market_cap nCUSIP
replace passive_pct=. if missing(unclassified_pct)
replace active_pct=. if missing(unclassified_pct)
label variable fund_holding_pct "Total mutual fund ownership \%"
label variable passive_pct "Passive ownership \%"
label variable active_pct "Active ownership \%"
label variable unclassified_pct "Unclassified ownership \%"
label variable Independent_Percentage "Independent director \%"
label variable PPILL"Poison pill removal"
label variable LSPMT"Greater ability to call special meeting"
label variable DUALCLASS "Indicator for dual class shares"
label variable support_rate_management "Mngt. proposal support \%"
label variable support_rate_shareholder "Shareholder gov. proposal support \%"
label variable r2000 "R2000"
label variable roa "ROA"
winsor2 fund_holding_pct,cuts(1,99) replace
winsor2 passive_pct,cuts(1,99) replace
winsor2 active_pct,cuts(1,99) replace
winsor2 unclassified_pct,cuts(1,99) replace
winsor2 Independent_Percentage,cuts(1,99)replace
winsor2 PPILL,cuts(1,99)replace
winsor2 LSPMT,cuts(1,99)replace
winsor2 support_rate_management,cuts(1,99)replace
winsor2 support_rate_shareholder,cuts(1,99)replace
winsor2 roa,cuts(1,99)replace
winsor2 adj_mrktvalue,cuts(1,99)replace
winsor2 market_cap,cuts(1,99)replace
sort YEAR adj_mrktvalue, stable
bysort YEAR (adj_mrktvalue): gen firm_rank = _n
gen in_bandwidth = (firm_rank >= 751 & firm_rank <= 1250)
gen lnmarketcap=ln(market_cap)
gen lnmarketcap_2=lnmarketcap*lnmarketcap
gen lnmarketcap_3=lnmarketcap*lnmarketcap_2
gen lnfloat=ln(adj_mrktvalue)
winsor2 lnfloat,cuts(1,99)replace
winsor2 lnmarketcap,cuts(1,99)replace
winsor2 lnmarketcap_2,cuts(1,99)replace
winsor2 lnmarketcap_3,cuts(1,99)replace
save "${root}/prepared data/mutualfund_v4.dta",replace
