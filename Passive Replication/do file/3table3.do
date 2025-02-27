**********************************************************************************************
* This Script is expected to output the Table 3
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
local xvariable1 r2000 lnmarketcap lnfloat
local xvariable2 r2000 lnmarketcap lnmarketcap_2 lnfloat
local xvariable3 r2000 lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
sum passive_pct
gen passive_scaled = passive_pct / r(sd)
label variable passive_scaled "Passive \% scaled by its sample standard deviation"
reg passive_scaled `xvariable1' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table31
reg passive_scaled `xvariable2' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table32
reg passive_scaled `xvariable3' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table33
esttab table31 table32 table33 using "${root}/output/table3_raw.tex", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(3) se(3) ///
    mtitles("(1)" "(2)" "(3)") ///
    label booktabs ///
    alignment(c) ///
    keep(r2000) ///
    order(r2000) ///
    stats(bandwidth poly_order float_control year_fixed N_firms N r2, ///
          labels("Bandwidth" "Polynomial order, \(N\)" "Float control" "Year fixed effects" ///
                 "# of firms" "Observations" "\textit{R-squared}") fmt(0 0 0 0 0 0 2)) ///
    title("\textit{Dependent variable =} & \textbf{Passive \% scaled by its sample standard deviation}") ///



