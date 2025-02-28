**********************************************************************************************
* This Script is expected to output the Table 1
**********************************************************************************************

use "${root}/prepared data/mutualfund_v4.dta",clear

local describelist fund_holding_pct passive_pct active_pct unclassified_pct Independent_Percentage PPILL LSPMT DUALCLASS support_rate_management support_rate_shareholder roa

estpost tabstat `describelist', statistics(n mean median sd) columns(statistics)
est store a

esttab a using "${root}/output/table1_raw.tex", ///
    replace ///
    collabels(\multicolumn{1}{c}{{N}} \multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Median}} \multicolumn{1}{c}{{St.Dev}}) ///
    cells("count(fmt(0)) mean(fmt(3)) p50(fmt(3)) sd(fmt(3))") /// 
    label noobs booktabs ///
    alignment(c)  // 

