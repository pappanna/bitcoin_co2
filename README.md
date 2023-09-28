# Bitcoin and carbon dioxide emissions: Evidence from daily production decisions

Code and data for *Bitcoin and carbon dioxide emissions: Evidence from daily production decisions*, by Anna Papp, Shuang Zhang, and Douglas Almond, forthcoming in the *Journal of Public Economics*. 

## Code 

### [__00_clean_data__](code/00_clean_data): Code related to data cleaning.
- [__00_clean_data.R__](code/00_clean_data/00_clean_data.R): Clean and combine various data sources into main data file.
  - Requires files in data/bitcoin, data/coal, data/grid, data/weather, and data/emissions folders.
  - Creates data/processed/00_data.rda
### [__01_regressions__](code/01_regressions): Code related to running regressions presented in main and appendix tables.
- [__01a_main_regressions.R__](code/01_regressions/01a_main_regressions.R): Creates Table 1 
- [__01b_appendix_bounding.R__](code/01_regressions/01b_appendix_bounding.R): Creates Appendix Table A2 
- [__01c_appendix_timeseries.do__](code/01_regressions/01c_appendix_timeseries.do): Creates Appendix Table A3 
- [__01d_appendix_timeseries_regressions.R__](code/01_regressions/01d_appendix_timeseries_regressions.R): Creates Appendix Table A4 
- [__01e_appendix_fixed_effects.R__](code/01_regressions/01e_appendix_fixed_effects.R): Creates Appendix Table A5 and A6 
- [__01f_appendix_other_robust.R__](code/01_regressions/01f_appendix_other_robust.R): Creates Appendix Tables A7 - A13, A16, A17
- [__01g_appendix_other_coal.R__](code/01_regressions/01g_appendix_other_coal.R): Creates Table A14 
### __02_charts__: Code related to creating charts in paper.
- __02a_hashrate_chart.do__: Creates Figures 1 and 2 
- __02b_demean_charts.do__: Creates Figure 3 and Appendix Figure A7
### __03_context_extvalidity__:
### __04_ripeforretirement__: 

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

