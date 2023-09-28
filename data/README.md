# Data for Paper 

## Bitcoin Data
- __bitcoin-daily-nasdaq.csv__: Bitcoin daily price downloaded from https://data.nasdaq.com/data/BCHAIN/MKPRU-bitcoin-market-price-usd
- __bitcoin_difficulty.csv__: Bitcoin network difficulty downloaded from https://data.nasdaq.com/data/BCHAIN/DIFF-bitcoin-difficulty
- __bitcoin-hashrate-reward.csv__: Bitcoin network hashrate downloaded from https://data.nasdaq.com/data/BCHAIN/HRATE-bitcoin-hash-rate
- __country-hashrate.csv__: Countries' share of hashrate downloaded from https://ccaf.io/cbnsi/cbeci/mining_map

## CEMS Emissions Data 
- __daily-emissions-scrubgrass.csv__: Emissions data for Scrubgrass, downloaded from https://campd.epa.gov/data/custom-data-download, filtering for Scrubgrass power plant
- __daily-emissions-panther.csv__: Emissions data for Panther Creek, downloaded from https://campd.epa.gov/data/custom-data-download, filtering for Panther Creek power plant
- __daily-emissions-PA-waste.csv__: Emissions data for other PA waste coal power plants, downloaded from https://campd.epa.gov/data/custom-data-download, filtering for state (PA) and type of fuel (Coal, Waste Coal)

## Coal Price 
- __weekly-coal-northern-appalachia.csv__: Weekly coal spot price collected from: https://www.eia.gov/coal/markets/#tabs-prices-1

## PJM Grid Data
- __hourly-penelec.csv__: Hourly day-ahead LMP for PENELEC zone of PJM downloaded from: https://dataminer2.pjm.com/feed/da_hrl_lmps
- __hourly-pjm.csv__: Hourly day-ahead LMP for PENELEC zone of PJM downloaded from: https://dataminer2.pjm.com/feed/da_hrl_lmps
- __hourly-marginal-emissions.csv__: Hourly marginal emissions (for recent months) downloaded from: https://dataminer2.pjm.com/feed/fivemin_marginal_emissions/definition

## PJM Grid Weather Data 
- __GEE__: First, code is run on Google Earth Engine to calculate temperature in each grid cell. Use this code: https://code.earthengine.google.com/7b4aac9b43c339db67b8b8fec64ef18f to generate the below files
__sumpop.csv__: Population for each grid cell
__sumprecip_YEAR.csv__: Precipitation in each grid cell, for each year
__sumtemp_YEAR.csv__: Temperature in each grid cell, for each year

## Annual Emissions Data 
- __annual-emissions-2022-coal.csv__: Annual emissions for all US power plants downloaded from https://campd.epa.gov/data/custom-data-download, filtering for 2022 and coal power plants 
- __annual-emissions-2022-gas.csv__: Annual emissions for all US power plants downloaded from https://campd.epa.gov/data/custom-data-download, filtering for 2022 and gas power plants 
- __annual-emissions-2022-oil.csv__: Annual emissions for all US power plants downloaded from https://campd.epa.gov/data/custom-data-download, filtering for 2022 and oil power plants 
- __annual-emissions-2022-other.csv__: Annual emissions for all US power plants downloaded from https://campd.epa.gov/data/custom-data-download, filtering for 2022 and other power plants 
