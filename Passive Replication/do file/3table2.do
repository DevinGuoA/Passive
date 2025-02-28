**********************************************************************************************
* This Script is expected to output the Table 2
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
local xvariable r2000 lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
reg fund_holding_pct `xvariable'  i.YEAR if in_bandwidth==1
est store a

reg active_pct `xvariable' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store b

reg passive_pct `xvariable' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store c

reg unclassified_pct `xvariable' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store d

esttab a b c d using "${root}/output/table2_raw.tex", ///
    replace ///
    keep(r2000) /// 
    order(r2000) ///
    b(3) se(3) /// 
    star(* 0.10 ** 0.05 *** 0.01) /// 
    mtitles("All mutual funds" "Passive" "Active" "Unclassified") ///
    eqlabels(none) ///
    refcat(r2000 "\textit{R2000}") ///
    stats(N_firms N obs r2, ///
          labels("\# of firms" "Observations" "\textit{R-squared}") ///
          fmt(0 0 2)) ///
    label booktabs alignment(c) ///
    compress
