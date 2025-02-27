# Passive
## How to replicate my write up
### Raw data used
`raw data`file includes all the raw data needed for replication. Detailed dataset descriptions are as following:
- `crsp_fund_summary.dta`: The monthly summary table in CRSP, serves as identifying the unclassified mutual fund.
- `issdir.dta``issgov.dta``issvote.dta` includes all the ISS data needed for replication including variables like *Independent Director %*, *Poison Pill Removol*
- `mflink1_raw.dta` and `mflink2_raw.dta` are the tables in MFLINK connecting Thomson and CRSP.
- `R2000` includes the Russell 2000 Index
- `thomson.dta` is fund-firm-time level data, including *shrout1* and *shrout2*, from which we generate *shrout*=*shrout2* and replace missing *shrout* with *1000shrout1* 
- `ownershipcrsp` documents the shareholdings of different mutual fund, which is key for generating heterogeneous fund type ownership.
see write-up for detailed generation process of the dataset
### Do file Structure
By running `0main.do`, you are expected to get all the results of this replication paper. and the detailed do file structure are as following:
- `0main.do` is the main do file, by running it, you are expected to get all the replication results of this replication work
- `1clean.do` is the data cleaning file, by running it, you are expected to get the final dataset for table output.


