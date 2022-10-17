# Bitcoin and CO2 Emissions: Evidence from daily production decisions in Pennsylvania 

Code and data for *Bitcoin and CO2 Emissions: Evidence from daily production decisions in Pennsylvania*, by Anna Papp, Shuang Zhang, and Douglas Almond. 

## Code 

- __00_clean_data.do__ : Clean and combine various data sources into main data file. (Requires files in data folder.)
- __01_regressions.do__ : Run regressions and create paper and appendix tables. (Requires output from 00_clean_data.do.)
- __02_charts.do__ : Create paper charts. (Requires output frm 00_clean_data.do.)

## Data

- __bitcoin-difficulty.csv__ : Bitcoin difficulty from blockchain.com. (https://www.blockchain.com/charts/difficulty)
- __country-hashrate.csv__ : US and China Bitcoin hashrates. (https://campd.epa.gov/data/custom-download)
- __daily-bitcoin-coinbase.csv__ : Daily Bitcoin price from St. Louis Fed FRED Economic Data. (https://fred.stlouisfed.org/series/CBBTCUSD)
- __daily-coal.csv__ : Daily coal commodity price. (https://markets.businessinsider.com/commodities/coalprice)
- __daily-emissions-PAcoal.csv__ : Daily emissions from EPA Air Markets Data for waste coal power plants. (https://campd.epa.gov/data/custom-download)
- __daily-emissions-scrubgrass.csv__ : Daily emissions from EPA Air Markets Data for Scrubgrass power plant. (https://campd.epa.gov/data/custom-download)
- __daily-weather-PA.csv__ : Daily Pennsylvania weather data from NOAA's Global Summary of the Day weather data. (https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516)
- __hourly-penelec.csv__ : Hourly LMP prices from PJM's Data Miner application for PENELEC zone. (https://dataminer2.pjm.com/feed/da_hrl_lmps)
- __hourly-ppl.csv__ : Hourly LMP prices from PJM's Data Miner application for PPL zone. (https://dataminer2.pjm.com/feed/da_hrl_lmps)
- __hourly-venango.csv__ : Hourly LMP prices from PJM's Data Miner application for Venango zone. (https://dataminer2.pjm.com/feed/da_hrl_lmps)

