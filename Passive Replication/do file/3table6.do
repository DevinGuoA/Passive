**********************************************************************************************
* This Script is expected to output the Table 6
**********************************************************************************************
use "${root}/prepared data/mutualfund_v4.dta",clear
sum passive_pct
gen passive_scaled = passive_pct / r(sd)
local xvariable1 passive_scaled lnmarketcap lnfloat
local xvariable2 passive_scaled lnmarketcap lnmarketcap_2 lnfloat
local xvariable3 passive_scaled lnmarketcap lnmarketcap_2 lnmarketcap_3 lnfloat
label variable passive_scaled "Passive\%"
reg PPILL `xvariable1' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table61

reg PPILL `xvariable2' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table62

reg PPILL `xvariable3' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table63

reg LSPMT `xvariable1' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table64

reg LSPMT `xvariable2' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table65

reg LSPMT `xvariable3' i.YEAR if in_bandwidth==1, cluster(CUSIP)
est store table66

esttab table61 table62 table63 table64 table65 table66 using "${root}/output/table6_raw.tex", ///
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
    prehead("\multicolumn{7}{c}{\textit{Dependent variable = PPILL and LSPMT}} \\" ///
            "\cmidrule(lr){2-7}" ///
            "& \multicolumn{3}{c}{\textit{PPILL}} & \multicolumn{3}{c}{\textit{LSPMT}} \\" ///
            "\cmidrule(lr){2-4} \cmidrule(lr){5-7}") ///
    addnotes("This table reports estimates of a regression of passive mutual fund ownership, " ///
             "scaled by its sample standard deviation, on PPILL and LSPMT. " ///
             "Standard errors are clustered at the firm level (CUSIP) and reported in parentheses. " ///
             "The symbols * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\) indicate significance levels.")
