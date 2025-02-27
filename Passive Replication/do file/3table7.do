**********************************************************************************************
* This Script is expected to output the Table 7
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
sum passive_pct
gen passive_scaled = passive_pct / r(sd)
local xvariable1 passive_scaled lnmarketcap lnfloat
local xvariable2 passive_scaled lnmarketcap lnmarketcap_2 lnfloat
local xvariable3 passive_scaled lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
label variable passive_scaled "Passive\%"
reg DUALCLASS `xvariable1' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table71

reg DUALCLASS `xvariable2' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table72

reg DUALCLASS `xvariable3' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table73

esttab table71 table72 table73 using "${root}/output/table7_raw.tex", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(3) se(3) ///
    mtitles("(1)" "(2)" "(3)") ///
    label booktabs ///
    alignment(c) ///
    keep(passive_scaled) ///
    order(passive_scaled) ///
    stats(bandwidth order_poly float_control year_fixed N_firms N r2, ///
          labels("Bandwidth" "Polynomial order, \(N\)" "Float control" "Year fixed effects" ///
                 "# of firms" "Observations" "\textit{R-squared}") fmt(0 0 0 0 0 0 2)) ///
    prehead("\multicolumn{4}{c}{\textit{Dependent variable = Indicator for dual class shares}} \\")
