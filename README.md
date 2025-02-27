# Passive
## How to replicate my write up
### Raw data used
`raw data`file includes all the raw data needed for replication. Detailed dataset descriptions are as following:
- `crsp_fund_summary.dta`is monthly summary table in CRSP, serves as identifying the unclassified mutual fund.
- `issdir.dta``issgov.dta``issvote.dta` includes all the ISS data needed for replication including variables like *Independent Director %*, *Poison Pill Removol*
- `mflink1_raw.dta` and `mflink2_raw.dta` are the tables in MFLINK connecting Thomson and CRSP.
- `R2000` includes the Russell 2000 Index
- `thomson.dta` is fund-firm-time level data, including *shrout1* and *shrout2*, from which we generate *shrout*=*shrout2* and replace missing *shrout* with *1000shrout1* 
- `ownershipcrsp` documents the shareholdings of different mutual fund, which is key for generating heterogeneous fund type ownership.
see write-up for detailed generation process of the dataset
### Do file Structure
By running `0main.do`, you are expected to get all the results of this replication paper. and the detailed do file structure are as following:
- `0main.do` is the main do file, by running it, you are expected to get all the replication results of this replication work
- `1clean.do` is the data cleaning file, by running it, you are expected to get the final dataset for table output. It connected with the following do file:
 -  `2iss_dir` generates ISS variables
 -  `2passive` generates heterogeneous ownership percentage variables
 -  `2roa` generates roa from the data in Compustat
 -  `2thomason` generates fund ownership percentage variables and merge all the data, and winsorize at 1%
- `3tablei*` ($i=1,2,...,7$)ouput the corresponding table in Appel et al(2016)
## Key Process in identifying the type of mutual fund
- Following Appel et al.(2016), we first generate *passive flag=0* to indicates whether a mutual fund is a passive fund or not.
- And the strings we use to identify index funds are: Index, Idx, Indx, Ind_ (where_ indicates a space), Russell, S & P, S and P, S&P, SandP, SP, DOW, Dow, DJ, MSCI, Bloomberg, KBW, NASDAQ, NYSE, STOXX, FTSE, Wilshire, Morningstar, 100, 400, 500, 600, 900, 1000, 1500, 2000, and 5000.
- However, to fully capture the passive mutual fund and avoid the mismatch because of the case problems with letters, we first generate *fund_name* which is the lower case of the *fund_name* in MFLINK. Sepcifically,
```
replace passive_flag = 1 if regexm(fund_name, "index|idx|indx|ind_|russell|s & p|s and p|s&p|sandp|sp|dow|dj|msci|bloomberg|kbw|nasdaq|nyse|stoxx|ftse|wilshire|morningstar|100|400|500|600|900|1000|1500|2000|5000")
```
the regular expression we used here ensures the clear match.
- Then we use the data generating from above process (`homson_mflink_for_passive1.dta`) merge with `crsp_fund_summary.dta`, and
```
replace fund_type = "Unclassified" if _merge == 2
```
