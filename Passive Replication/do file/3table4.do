**********************************************************************************************
* This Script is expected to output the Table 4
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
sum passive_pct
gen passive_scaled = passive_pct / r(sd)
local xvariable1 passive_scaled lnmarketcap lnfloat
local xvariable2 passive_scaled lnmarketcap lnmarketcap_2 lnfloat
local xvariable3 passive_scaled lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
label variable passive_scaled "Passive\%"
reg Independent_Percentage `xvariable1' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table41
reg Independent_Percentage `xvariable2' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table42
reg Independent_Percentage `xvariable3' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table43

esttab table41 table42 table43 using "${root}/output/table4_raw.tex", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(3) se(3) ///
    mtitles("(1)" "(2)" "(3)") ///
    label booktabs ///
    alignment(c) ///
    keep(passive_scaled) ///
    order(passive_scaled) ///
    stats(bandwidth poly_order float_control year_fixed N_firms N r2, ///
          labels("Bandwidth" "Polynomial order, \(N\)" "Float control" "Year fixed effects" ///
                 "# of firms" "Observations" "\textit{R-squared}") fmt(0 0 0 0 0 0 2)) ///
    title("\textit{Dependent variable =} & \textbf{Passive \% scaled by its sample standard deviation}") ///


