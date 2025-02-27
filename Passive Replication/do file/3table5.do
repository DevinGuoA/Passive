**********************************************************************************************
* This Script is expected to output the Table 5
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
sum passive_pct
gen passive_scaled = passive_pct / r(sd)
local xvariable1 passive_scaled lnmarketcap lnfloat
local xvariable2 passive_scaled lnmarketcap lnmarketcap_2 lnfloat
local xvariable3 passive_scaled lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
label variable passive_scaled "Passive\%"
reg Independent_Percentage `xvariable1' i.YEAR if in_bandwidth==1 & YEAR<=2002, cluster(CUSIP)
est store table41
reg Independent_Percentage `xvariable2' i.YEAR if in_bandwidth==1 & YEAR<=2002, cluster(CUSIP)
est store table42
reg Independent_Percentage `xvariable3' i.YEAR if in_bandwidth==1 & YEAR<=2002, cluster(CUSIP)
est store table43
reg Independent_Percentage `xvariable1' i.YEAR if in_bandwidth==1 & YEAR>=2003, cluster(CUSIP)
est store table44
reg Independent_Percentage `xvariable2' i.YEAR if in_bandwidth==1 & YEAR>=2003, cluster(CUSIP)
est store table45
reg Independent_Percentage `xvariable3' i.YEAR if in_bandwidth==1 & YEAR>=2003, cluster(CUSIP)
est store table46

esttab table41 table42 table43 table44 table45 table46 using "${root}/output/table5_raw.tex", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    b(3) se(3) ///
    mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
    label booktabs ///
    alignment(c) ///
    keep(passive_scaled) ///
    order(passive_scaled) ///
    stats(bandwidth poly_order float_control year_fixed N_firms N r2, ///
          labels("Bandwidth" "Polynomial order, \(N\)" "Float control" "Year fixed effects" ///
                 "# of firms" "Observations" "\textit{R-squared}") fmt(0 0 0 0 0 0 2)) ///
    prehead("\multicolumn{7}{c}{\textit{Dependent variable = Independent director \%}} \\" ///
            "\cmidrule(lr){2-7}" ///
            "& \multicolumn{3}{c}{\textit{Sample years = 1998-2002}} & \multicolumn{3}{c}{\textit{Sample years = 2003-2006}} \\" ///
            "\cmidrule(lr){2-4} \cmidrule(lr){5-7}") ///
    addnotes("This table reports estimates of a regression of passive mutual fund ownership, " ///
             "scaled by its sample standard deviation, on board independence, separately for two sample periods." ///
             "Standard errors are clustered at the firm level and reported in parentheses. " ///
             "The symbols * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\) indicate significance levels.")
