/***********************************************************************************************
This script: 
By running this script, you are expected to get all the empirical results shown in the research
***********************************************************************************************/

clear all
capture log close
set more off
macro drop _all
program drop _all
matrix drop _all

//************** Define directory structure and set up logs **************//
global user "Devin"
if "$user" == "Devin" {
	global root "/Users/devin/Desktop/Passive"
}

** Create log directory if it doesn't exist ***
cap mkdir "${root}/log"

** Set up log file ***
global date: display %tdCCYYNNDD date(c(current_date), "DMY")
log using "${root}/log/log${date}.log", text replace

//************** Clean the dataset **************//

do "${root}/do file/1clean.do"

//************** Results out put **************//

do "${root}/do file/3table1.do"

do "${root}/do file/3table2.do"

do "${root}/do file/3table3.do"

do "${root}/do file/3table4.do"

do "${root}/do file/3table5.do"

do "${root}/do file/3table6.do"

do "${root}/do file/3table7.do"

log close
