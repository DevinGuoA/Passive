**********************************************************************************************
* Generate the passive data
**********************************************************************************************
* 1. 读取所需数据集 (.dta 文件)
use "${root}/raw data/crsp_fund_summary.dta", clear

* 标记被动基金（Passive）: 关键词匹配
gen passive_flag = 0
replace passive_flag = 1 if regexm(fund_name, "(?i)Index|Idx|Indx|Ind_|Russell|S & P|S and P|S&P|SandP|SP|DOW|Dow|DJ|MSCI|Bloomberg|KBW|NASDAQ|NYSE|STOXX|FTSE|Wilshire|Morningstar|100|400|500|600|900|1000|1500|2000|5000")

* 创建基金类型变量：默认为 Active
gen fund_type = "Active"
replace fund_type = "Passive" if passive_flag == 1

* 保留关键字段
keep crsp_fundno fund_name fund_type

* 保存处理后的基金数据
tempfile crsp_funds
save `crsp_funds', replace

**********************************************
* 2. 读取 MFLINKS 并匹配 CRSP 基金信息
**********************************************
use "mflinks1.dta", clear
append using "mflinks2.dta"

* 通过 `crsp_fundno` 合并 CRSP 基金类型
sort crsp_fundno
merge m:1 crsp_fundno using `crsp_funds', keepusing(fund_type fund_name) nogenerate

* 未匹配的基金标记为 Unclassified
replace fund_type = "Unclassified" if missing(fund_type)

* 保存匹配结果
tempfile fund_link
save `fund_link', replace

**********************************************
* 3. 读取 Thomson 基金持仓数据，并合并基金分类
**********************************************
use "thomson_holdings.dta", clear
sort thomson_fund_id
merge m:1 thomson_fund_id using `fund_link', nogenerate

* 确保所有基金类型都有正确标记
replace fund_type = "Unclassified" if missing(fund_type)

* 生成季度变量，方便后续合并
gen quarter = qofd(fdate)

**********************************************
* 4. 读取 CRSP 股票市场数据，按季度聚合
**********************************************
use "crsp_stock_market.dta", clear
gen quarter = qofd(date)
sort cusip quarter date
by cusip quarter: keep if _n == _N  // 仅保留每季度的最新数据

* 计算市值
gen market_cap = prc * shrout

keep cusip quarter ticker market_cap
sort cusip quarter
tempfile stock_quarter
save `stock_quarter', replace

**********************************************
* 5. 合并基金持仓数据与股票数据，并计算持股比例
**********************************************
restore
sort cusip quarter
merge m:1 cusip quarter using `stock_quarter', nogenerate

* 计算各基金类型的持仓市值
gen holding_value = market_value

gen passive_val = holding_value if fund_type == "Passive"
gen active_val  = holding_value if fund_type == "Active"
gen unclass_val = holding_value if fund_type == "Unclassified"

replace passive_val = 0 if missing(passive_val)
replace active_val  = 0 if missing(active_val)
replace unclass_val = 0 if missing(unclass_val)

* 按季度和股票计算持仓总市值
collapse (sum) passive_val active_val unclass_val (first) ticker (first) market_cap, by(quarter cusip)

* 计算持股比例
gen passive_ownership_ratio     = passive_val   / market_cap
gen active_ownership_ratio      = active_val    / market_cap
gen unclassified_ownership_ratio= unclass_val   / market_cap

**********************************************
* 6. 数据导出
**********************************************
gen q_end_date = dofq(quarter + 1) - 1
format q_end_date %td
rename q_end_date date

keep date cusip ticker market_cap passive_ownership_ratio active_ownership_ratio unclassified_ownership_ratio
sort date cusip

save "ownership_ratios.dta", replace
