#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# Data cleaning file 
# Requires: 
# -- data/bitcoin/bitcoin-daily-nasdaq.csv (Bitcoin daily price )
# -- data/bitcoin/bitcoin-hashrate-reward.csv (Bitcoin hashrate)
# -- data/bitcoin/bitcoin-difficulty.csv (Bitcoin difficulty)
# -- data/coal/weekly-coal-northern-appalachia.csv (North Appalachian coal price)
# -- data/grid/hourly-penelec.csv (hourlay day-ahead LMP for PENELEC)
# -- data/grid/hourly-ppl.csv (hourly day-ahead LMP for PPL)
# -- data/weather/sumpop.csv (gridded population data for PJM)
# -- data/weather/sumtemp_YEAR.csv (gridded temperature data for PJM)
# -- data/weather/sumprecip_YEAR.csv (gridded precipitation data for PJM)
# -- data/emissions/daily-emissions-scrubgrass.csv (Scrubgrass emissions)
# -- data/emissions/daily-emissions-panther.csv (Panther creek emissions)
# -- data/emissions/daily-emissions-PA-waste.csv (other PA waste coal plant emissions)
# Last modified 07/09/23
#############################################################################################

# Setup -------------------------------------------------------------------------------------

## clear variables in environment and script 
rm(list=ls(all=TRUE)); cat("\014") 

## load packages
if(!require(pacman)) install.packages('pacman') 
pacman::p_load( data.table,ggplot2, dplyr, gamlr, nnet, imputeTS, caret, scales, ggthemes, foreign, ggrepel, readr, tidyr, plm, broom, dplyr, Hmisc, sqldf, stargazer, stringr, zoo, glmnet, import, lubridate, ncdf4, raster, lfe, sjPlot, tigris, rgdal, GGally, dotwhisker,choroplethr, choroplethrMaps, splines, fixest, sf,ggpubr, car, geojsonsf, rgeos, rmapshaper, readxl, usmap)    

## directory 
if(Sys.info()["user"] == "annapapp") {
  setwd('/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube') # anna WD
} else {
  setwd('/[OTHER USER]') 
}

# Bitcoin Data ---------------------------------------------------------------------------------

##  Load BTC Data -----

# bitcoin price 
btc <- read.csv("data/bitcoin/bitcoin-daily-nasdaq.csv")
btc <- btc %>% mutate(date = as.Date(Date, format="%m/%d/%y"), btc = as.numeric(Value))
btc <- btc %>% dplyr::select(date, btc) %>% filter(year(date) >= 2013) %>% filter(date <= as.Date("03/31/2023", format="%m/%d/%Y")) %>% arrange(date)

# bitcoin hashrate and reward 
hashrate <- read.csv("data/bitcoin/bitcoin-hashrate-reward.csv")
hashrate <- hashrate %>% dplyr::select(date, hashrate, btcReward = btcreward) %>% filter(date != "")
hashrate <- hashrate %>% mutate(date = as.Date(date, format="%Y-%m-%d")) %>% arrange(date)

# bitcoin mining difficulty 
diff <- read.csv("data/bitcoin/bitcoin-difficulty.csv")
diff <- diff %>% mutate(date = as.Date(date, format="%m/%d/%y"))
diff <- diff %>% dplyr::select(date, difficulty, btcDiffEra = btcdiffera)
diff <- diff %>% fill(btcDiffEra, .direction="down")
diff <- diff %>% filter(!is.na(date))

##  Combine BTC Data -----

# start with btc 
data <- left_join(btc, hashrate)
data <- left_join(data, diff)
rm(btc, hashrate, diff)


## Calculate Approximate BTC Reward per MWh -----

# miner capacity estimation, see data/BTC-calculation.xlsx for details 
minerCap <- 28.31

# calculate MWh required to mine 1 BTC under current network difficulty 
data <- data %>% mutate(mWhPerBTC = hashrate * (1 / (btcReward * 52560)) * (1 / (minerCap * 1000)) * 24 * 365 )

# calculate $ per MWh from Bitcoin mining 
data <- data %>% mutate(revPerMWhBTC = btc / mWhPerBTC)

# Coal Data -----------------------------------------------------------------------------

## Load Weekly Northern Appalachia Coal Price --- 
coal <- read.csv("data/coal/weekly-coal-northern-appalachia.csv")
coal <- coal %>% mutate(date = as.Date(week, format="%m/%d/%y")) %>% dplyr::select(date, coal = price)
coal <- coal %>% mutate(coal = as.numeric(coal))

## Merge with Main Data ---- 
data <- left_join(data, coal)
rm(coal)
data <- data %>% fill(coal, .direction="up")
data <- data %>% mutate(coalLag = dplyr::lag(coal, 91))

## Estimate Cost of Generating Electricity  ---- 
# scaled to March 31, 2023 value ($83 for coal and $209.70 for lagged)
data <- data %>% mutate(costMWh =  ((((coal / 83.00)-1)*0.78)+1) * 47.50 )
data <- data %>% mutate(costMWhLag =  ((((coalLag / 209.70)-1)*0.78)+1) * 47.50 )

# Electricity Data -----------------------------------------------------------------------

## Load Electricity Data ----- 
# penelec 
penelec <- read.csv("data/grid/hourly-penelec.csv")
penelec <- penelec %>% dplyr::select(hour = datetime_beginning_utc, penelecLMP = total_lmp_da)
penelec <- penelec %>% mutate(date = gsub( " .*$", "", hour))
penelec <- penelec %>% mutate(date = as.Date(date,format="%m/%d/%y")) %>% dplyr::select(date, penelecLMP)
penelec <- penelec %>% group_by(date) %>% summarise(penelecLMP = mean(penelecLMP, na.rm=TRUE))

# ppl
ppl <- read.csv("data/grid/hourly-ppl.csv")
ppl <- ppl %>% dplyr::select(hour = datetime_beginning_utc, pplLMP = total_lmp_da)
ppl <- ppl %>% mutate(date = gsub( " .*$", "", hour))
ppl <- ppl %>% mutate(date = as.Date(date,format="%m/%d/%y")) %>% dplyr::select(date, pplLMP)
ppl <- ppl %>% group_by(date) %>% summarise(pplLMP = mean(pplLMP, na.rm=TRUE))

## Merge with Main Data ---- 
data <- left_join(data, penelec)
data <- left_join(data, ppl)
rm(penelec, ppl)

## Mean PENELEC / PPL ---- 
data <- data %>% mutate(paLMP = (penelecLMP + pplLMP)/2)

## Calculate deciles ---- 
data <- data %>% mutate(paLMPQuantile = ntile(paLMP, 10))

# Weighted Temperature Data --------------------------------------------------------------

## Get population ---- 
# gridded population data downloaded from GEE 
pop <- read.csv("data/weather/sumpop.csv")
population <- pop$population
rm(pop)

## Get temperature data ----
temperature <- data.frame()

for (year in 2013:2023){
  
  # gridded temperature data downloaded from GEE 
  weather <- read.csv(paste0("data/weather/sumtemp_", year, ".csv"))  
  
  if (year < 2023){
    weather <- weather %>% pivot_longer(
      cols = paste0('X', year, '0101_', year, '0101'):paste0('X', year, '1231_', year, '1231'), 
      names_to = "date",
      values_to = "temp"
    ) %>% dplyr::select(date, temp)
  }
  
  if (year == 2023){
    weather <- weather %>% pivot_longer(
      cols = paste0('X', year, '0101_', year, '0101'):paste0('X', year, '0331_', year, '0331'), 
      names_to = "date",
      values_to = "temp"
    ) %>% dplyr::select(date, temp) 
  }
  
  weather <- weather %>% mutate(date = as.Date(substr(date,2, 9), format="%Y%m%d"))
  weather <- weather %>% mutate(temp = temp / population -273.15)
  
  temperature <- rbind(temperature, weather)
  
}

## Get rainfall data ---- 
rainfall <- data.frame()

for (year in 2013:2023){
  
  # gridded precipitation data downloaded from GEE 
  weather <- read.csv(paste0("data/weather/sumprecip_", year, ".csv"))  
  
  if (year < 2023){
    weather <- weather %>% pivot_longer(
      cols = paste0('X', year, '0101_', year, '0101'):paste0('X', year, '1231_', year, '1231'), 
      names_to = "date",
      values_to = "precip"
    ) %>% dplyr::select(date, precip)
  }
  
  if (year == 2023){
    weather <- weather %>% pivot_longer(
      cols = paste0('X', year, '0101_', year, '0101'):paste0('X', year, '0331_', year, '0331'), 
      names_to = "date",
      values_to = "precip"
    ) %>% dplyr::select(date, precip) 
  }
  
  weather <- weather %>% mutate(date = as.Date(substr(date,2, 9), format="%Y%m%d"))
  weather <- weather %>% mutate(precip = precip / population * 1000)
  
  rainfall <- rbind(rainfall, weather)
  
}

## Merge ---- 
weather <- left_join(temperature, rainfall)
rm(temperature, rainfall)

data <- left_join(data, weather)
rm(weather)

# Estimation of Scrubgrass Behavior -------------------------------------------------------

# 1) if LMP < estimated net cost of power : MOSTLY BUY FROM GRID 
## 2a) if BTC revenue per MWh > LMP > net cost of power: ONLY MINE BTC 
## 2b) if LMP > BTC revenue per MWh > net cost of power: MIX OF MINE AND SELL TO GRID 

# dummy variable based on price 
data <- data %>% mutate(dummyBuy = ifelse(paLMP < costMWh, 1, 0), 
                        dummySell = ifelse(paLMP > revPerMWhBTC, 1, 0))

# Scrubgrass Generation Data -------------------------------------------------------------

## Load Data ----- 
scrub <- read.csv("data/emissions/daily-emissions-scrubgrass.csv")
scrub <- scrub %>% dplyr::select(date = Date, heatInput = Heat.Input..mmBtu., load = Steam.Load..1000.lb., co2Mass = CO2.Mass..short.tons., so2Mass = SO2.Mass..short.tons., noxMass = NOx.Mass..short.tons.)
scrub <- scrub %>% mutate(date = as.Date(date, format="%m/%d/%y"))
scrub <- scrub %>% filter(year(date) >= 2013)
scrub <- scrub %>% mutate(heatInput = ifelse(is.na(heatInput), 0, heatInput), 
                          load = ifelse(is.na(load), 0, load), 
                          co2Mass = ifelse(is.na(co2Mass), 0, co2Mass), 
                          so2Mass = ifelse(is.na(so2Mass), 0, so2Mass), 
                          noxMass = ifelse(is.na(noxMass), 0, noxMass))

# units 
# for steam load, convert to comparable load based on coal heat rate averages 
scrub <- scrub  %>% mutate(heatInput = heatInput * 10^6, 
                           load = load * 1000 * 8491 * 1/24 * 0.000293, 
                           co2Mass = co2Mass * 0.907185 , 
                           so2Mass = so2Mass * 0.907185 ,
                           noxMass = noxMass * 0.907185 )

# merge to final 
data <- left_join(data, scrub)
rm(scrub)

# Other PA Generation Data -------------------------------------------------------------

## Load Data for Panther (also owned by Scrubgrass) ----- 
panther <- read.csv("data/emissions/daily-emissions-panther.csv")
panther <- panther %>% dplyr::select(date = Date, loadPanther = Steam.Load..1000.lb.)
panther <- panther %>% mutate(date = as.Date(date, format="%m/%d/%y"))
panther <- panther %>% filter(year(date) >= 2013)
panther <- panther %>% mutate(loadPanther = ifelse(is.na(loadPanther), 0, loadPanther))
# for steam load, convert to comparable load based on coal heat rate averages 
panther <- panther  %>% mutate(loadPanther = loadPanther * 1000 * 8491 * 1/24 * 0.000293)

## Load Data for Other Waste Coal ----- 
penn <- read.csv("data/emissions/daily-emissions-PA-waste.csv")
penn <- penn %>% dplyr::select(plant = Facility.Name, date = Date, load = Gross.Load..MWh., loadSteam = Steam.Load..1000.lb., co2Mass = CO2.Mass..short.tons.)
penn <- penn %>% mutate(date = as.Date(date, format="%m/%d/%y"))
penn <- penn %>% filter(year(date) >= 2013)
# for steam load, convert to comparable load based on coal heat rate averages 
penn <- penn %>% mutate(loadSteam= loadSteam * 1000 * 8491 * 1/24 * 0.000293, load = load * 10^3)
penn <- penn %>% mutate(load = ifelse(is.na(load), loadSteam, load))
penn <- penn %>% mutate(load = ifelse(is.na(load), 0, load))
penn <- penn %>% mutate(co2Mass = ifelse(is.na(co2Mass), 0, co2Mass))
penn <- penn %>% mutate(co2Mass = co2Mass * 0.907185)
penn <- penn %>% mutate(plant = ifelse(plant == "Gilberton Power Company", "Gilberton", 
                                       ifelse(plant == "Cambria Cogen", "Cambria", 
                                              ifelse(plant == "Colver Green Energy", "Colver", 
                                                     ifelse(plant == "Mt. Carmel Cogeneration", "MtCarmel", 
                                                            ifelse(plant == "St. Nicholas Cogeneration Project", "StNicholas", 
                                                                   ifelse(plant == "Northampton Generating Plant", "Northampton", "")))))))
penn1 <- penn %>% filter(plant == "Cambria") %>% dplyr::select(date, loadCambria = load, co2MassCambria = co2Mass)
penn2 <- penn %>% filter(plant == "Colver") %>% dplyr::select(date,loadColver = load, co2MassColver = co2Mass)
penn3 <- penn %>% filter(plant == "Gilberton") %>% dplyr::select(date,loadGilberton = load, co2MassGilberton = co2Mass)
penn4 <- penn %>% filter(plant == "MtCarmel") %>% dplyr::select(date,loadMtCarmel = load, co2MassMtCarmel = co2Mass)
penn5 <- penn %>% filter(plant == "StNicholas") %>% dplyr::select(date,loadStNicholas = load, co2MassStNicholas = co2Mass)
penn6 <- penn %>% filter(plant == "Northampton") %>% dplyr::select(date,loadNorthampton = load, co2MassNorthampton = co2Mass)

# merge to final 
data <- left_join(data, panther)
data <- left_join(data, penn1)
data <- left_join(data, penn2)
data <- left_join(data, penn3)
data <- left_join(data, penn4)
data <- left_join(data, penn5)
data <- left_join(data, penn6)
rm(panther, penn, penn1, penn2, penn3, penn4, penn5, penn6)

# Final Cleaning / Date Variables  -------------------------------------------------------

data <- data %>% mutate(year = year(date), 
                        month = month(date), 
                        dow = wday(date))
data <- data %>% dplyr::select(date, year, month, dow, btc, hashrate, btcReward, difficulty, btcDiffEra, mWhPerBTC, revPerMWhBTC, coal, coalLag, costMWh, costMWhLag, paLMP, paLMPQuantile, dummyBuy, dummySell, temp, precip, heatInput, load, co2Mass, so2Mass, noxMass, loadPanther, loadCambria, co2MassCambria, loadColver, co2MassColver, loadGilberton, co2MassGilberton, loadMtCarmel, co2MassMtCarmel, loadStNicholas, co2MassStNicholas, loadNorthampton, co2MassNorthampton)

# Save Data  -----------------------------------------------------------------------------

save(data, file="data/processed/00_data.rda")
write.csv(data, file="data/processed/00_data.csv")


