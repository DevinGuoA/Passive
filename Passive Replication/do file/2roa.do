/***********************************************************************************************
This script:
By running this script, you are expected to:
- Merge ROA with maindataset
***********************************************************************************************/
clear all
set more off
use "/Users/devin/Desktop/Passive/raw data/roa.dta",clear
gen CUSIP8=substr(cusip,1,8)
gen qdate=qofd(datadate)
format qdate %tq
duplicates drop qdate CUSIP8,force
gen roa=niq/atq
merge 1:1 qdate CUSIP8 using "${root}/prepared data/mutualfund_v2.dta"
keep if _merge==3
drop _merge
drop if missing(roa)
save  "${root}/prepared data/mutualfund_v3.dta",replace
