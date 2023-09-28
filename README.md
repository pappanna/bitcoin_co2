# Bitcoin and carbon dioxide emissions: Evidence from daily production decisions

Code and data for *Bitcoin and carbon dioxide emissions: Evidence from daily production decisions*, by Anna Papp, Shuang Zhang, and Douglas Almond, forthcoming in the *Journal of Public Economics*. 

*Abstract:* Environmental externalities from cryptomining may be large, but have not been linked causally to mining incentives. We exploit daily variation in Bitcoin price as a natural experiment for an 86 megawatt coal-fired power plant with on-site cryptomining. We find that carbon emissions respond swiftly to mining incentives, with price elasticities of 0.69-0.71 in the short-run and 0.33-0.40 in the longer run. A $1 increase in Bitcoin price leads to $3.11-$6.79 in external damages from carbon emissions alone, well exceeding cryptomining’s value added (using a $190 social cost of carbon, but ignoring increased local air pollution). As cryptomining requires ever more computing power to mine a given number of blocks, our study highlights both the revitalization of US fossil assets and the need for financial industry accounting to incorporate cryptomining externalities.

## Code for Replicating Paper

After downloading appropriate data files, run the following scripts in the below order.
### [__00_clean_data__](code/00_clean_data): Code related to data cleaning.
- [__00_clean_data.R__](code/00_clean_data/00_clean_data.R): Clean and combine various data sources into main data file.
  - Requires files in data/bitcoin, data/coal, data/grid, data/weather, and data/emissions folders.
  - Creates data/processed/00_data.rda and data/processed/00_data.csv
### [__01_regressions__](code/01_regressions): Code related to running regressions presented in main and appendix tables.
- [__01a_main_regressions.R__](code/01_regressions/01a_main_regressions.R): Creates Table 1 
- [__01b_appendix_bounding.R__](code/01_regressions/01b_appendix_bounding.R): Creates Appendix Table A2 
- [__01c_appendix_timeseries.do__](code/01_regressions/01c_appendix_timeseries.do): Creates Appendix Table A3 
- [__01d_appendix_timeseries_regressions.R__](code/01_regressions/01d_appendix_timeseries_regressions.R): Creates Appendix Table A4 
- [__01e_appendix_fixed_effects.R__](code/01_regressions/01e_appendix_fixed_effects.R): Creates Appendix Table A5 and A6 
- [__01f_appendix_other_robust.R__](code/01_regressions/01f_appendix_other_robust.R): Creates Appendix Tables A7 - A13, A16, A17
- [__01g_appendix_other_coal.R__](code/01_regressions/01g_appendix_other_coal.R): Creates Table A14
  - All scripts require data/processed/00_data.rda created in 00_clean_data.R
### [__02_charts__](code/02_charts): Code related to creating charts in paper.
- [__02a_hashrate_chart.do__](code/02_charts/02a_hashrate_chart.do): Creates Figures 1 and 2 
- [__02b_demean_charts.do__](code/02b_demean_charts.do): Creates Figure 3 and Appendix Figure A7
  - All scripts require data/processed/00_data.csv created in 00_clean_data.R
### [__03_context_extvalidity__](code/03_context_extvalidity): Code related to external validity / context figures.
- [__03a_context_extvalidity_all_plants.R__](code/03_context_extvalidity/03a_context_extvalidity_all_plants.R): Creates Figure 4
  - Requires files in data/annual_emissions and data/other folders.
- [__03b_context_extvalidity_ba.R__](code/03_context_extvalidity/03b_context_extvalidity_ba.R): Creates Appendix Figure A8
  - Requires files in data/ba_carbon_accounting folder.
- [__03c_context_extvalidity_pa.R__](code/03_context_extvalidity/03c_context_extvalidity_pa.R): Creates Appendix Figure A5
  - Requires files in data/annual_emissions and data/other folders.
### [__04_ripeforretirement__](code/04_ripeforretirement): Code related to ripe for retirement calculations and figures.
- [__04_rfr_distribution.R__](code/04_ripe_for_retirement/04_rfr_distribution.R): Created Appendix Figure A6
  - Requires files in data/annual_emissions, data/ripe_for_retirement, and data/other folders.

## Data for Replicating Paper

### Bitcoin Data
- __bitcoin-daily-nasdaq.csv__: Bitcoin daily price downloaded from [NASDAQ](https://data.nasdaq.com/data/BCHAIN/MKPRU-bitcoin-market-price-usd)
- __bitcoin_difficulty.csv__: Bitcoin network difficulty downloaded from [NASDAQ](https://data.nasdaq.com/data/BCHAIN/DIFF-bitcoin-difficulty)
- __bitcoin-hashrate-reward.csv__: Bitcoin network hashrate downloaded from [NASDAQ](https://data.nasdaq.com/data/BCHAIN/HRATE-bitcoin-hash-rate)
- __country-hashrate.csv__: Countries' share of hashrate downloaded from [CCAF](https://ccaf.io/cbnsi/cbeci/mining_map)

### CEMS Emissions Data 
- __daily-emissions-scrubgrass.csv__: Emissions data for Scrubgrass, downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for Scrubgrass power plant
- __daily-emissions-panther.csv__: Emissions data for Panther Creek, downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for Panther Creek power plant
- __daily-emissions-PA-waste.csv__: Emissions data for other PA waste coal power plants, downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for state (PA) and type of fuel (Coal, Waste Coal)

### Coal Price 
- __weekly-coal-northern-appalachia.csv__: Weekly coal spot price collected from [the EIA](https://www.eia.gov/coal/markets/#tabs-prices-1)

### PJM Grid Data
- __hourly-penelec.csv__: Hourly day-ahead LMP for PENELEC zone of PJM downloaded from [PJM](https://dataminer2.pjm.com/feed/da_hrl_lmps)
- __hourly-pjm.csv__: Hourly day-ahead LMP for PENELEC zone of PJM downloaded from [PJM](https://dataminer2.pjm.com/feed/da_hrl_lmps)
- __hourly-marginal-emissions.csv__: Hourly marginal emissions (for recent months) downloaded from [PJM](https://dataminer2.pjm.com/feed/fivemin_marginal_emissions/definition)

### PJM Grid Weather Data 
- __GEE__: First, code is run on Google Earth Engine to calculate temperature in each grid cell. Use this code: https://code.earthengine.google.com/7b4aac9b43c339db67b8b8fec64ef18f to generate the below files
__sumpop.csv__: Population for each grid cell
__sumprecip_YEAR.csv__: Precipitation in each grid cell, for each year
__sumtemp_YEAR.csv__: Temperature in each grid cell, for each year

### Annual Emissions Data 
- __annual-emissions-2012-coal.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for 2012 and coal power plants
- __annual-emissions-2022-coal.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for 2022 and coal power plants 
- __annual-emissions-2022-gas.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for 2022 and gas power plants 
- __annual-emissions-2022-oil.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for 2022 and oil power plants 
- __annual-emissions-2022-other.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for 2022 and other power plants
- __annual-emissions-pa-coal.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for state (PA) and coal power plants 
- __annual-emissions-pa-coalpet.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for state (PA) and coal pet power plants 
- __annual-emissions-pa-coalrefuse.csv__: Annual emissions for all US power plants downloaded from [the EPA](https://campd.epa.gov/data/custom-data-download), filtering for state (PA) and coal refuse power plants 

### Carbon Accounting Data for Balancing Authorities 
- Download data for 2021 for each balancing authority from [Singularity](https://singularity.energy/data-download-page)

### Ripe for Retirement Data 
- __ripe-for-retirement-with-facility-id-high.csv__: Digitized version of table from this report (Table E-2) from [the Union of Concerned Scientists](https://www.ucsusa.org/sites/default/files/2019-09/Ripe-for-Retirement-Executive-Summary.pdf)
- __ripe-for-retirement-with-facility-id-low.csv__: Digitized version of table from this report (Table E-3) [the Union of Concerned Scientists](https://www.ucsusa.org/sites/default/files/2019-09/Ripe-for-Retirement-Executive-Summary.pdf)

### Other Data 
- __coal-type.csv__: This file collects information on the coal type used by certain power plants from [GEM Wiki](https://www.gem.wiki/Main_Page)


