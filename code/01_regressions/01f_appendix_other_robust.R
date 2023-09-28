#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# Various robustness checks 
# Requires: 
# -- data/processed/00_data.rda (created in 00_clean_data.R)
# -- data/grid/hourly-marginal-emissions.csv
# last modified 08/16/23
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

# Load Data ---------------------------------------------------------------------------------

# load PJM marginal emissions 
pjmME <- read.csv("data/grid/hourly-marginal_emissions.csv")

# load main data 
load("data/processed/00_data.rda")

# create trend variables 
data <- data %>% mutate(t = as.numeric(row_number()))
data <- data %>% mutate(t2 = t * t)
data <- data %>% mutate(t3 = t2 * t)
data <- data %>% mutate(t4 = t3 * t)
data <- data %>% mutate(t5 = t4 * t)

# data before and after 
dataBefore <- data %>% filter(date >= as.Date("2013-01-01", format="%Y-%m-%d")) %>% filter(date <= as.Date("2017-12-31", format="%Y-%m-%d")) 
dataAfter <- data %>% filter(date >= as.Date("2018-05-01", format="%Y-%m-%d")) %>% filter(date <= as.Date("2023-03-31", format="%Y-%m-%d"))

# add percentile for electricity prices 
dataAfter <- dataAfter %>% mutate(paLMPQ = ntile(paLMP, 4))

# weekly data 
dataWeek <- dataAfter %>% mutate(week = week(date))
dataWeek <- dataWeek %>% group_by(year, week) %>% summarise(co2Mass = mean(co2Mass), 
                                                            btc = mean(btc), 
                                                            costMWh = mean(costMWh), 
                                                            paLMP = mean(paLMP), 
                                                            mWhPerBTC = mean(mWhPerBTC), 
                                                            month = min(month), 
                                                            costMWh = mean(costMWh))

# Summary stats used in elasticity calculations text -----------------------------------------------------------------

meanBTC <- mean(dataAfter$btc)
meanCO2 <- mean(dataAfter$co2Mass)

dataAfterNonZero <- dataAfter %>% filter(co2Mass > 0)
meanBTCNonZero <- mean(dataAfterNonZero$btc)
meanCO2NonZero <- mean(dataAfterNonZero$co2Mass)

dataAfterHigh <- dataAfter %>% filter(paLMPQ == 4)
meanBTCHigh <- mean(dataAfterHigh$btc)
meanCO2High <- mean(dataAfterHigh$co2Mass)

dataAfterNo20 <- dataAfter %>% filter(year != 2020)
meanBTCNo20 <- mean(dataAfterNo20$btc)
meanCO2No20 <- mean(dataAfterNo20$co2Mass)

meanBTCWeek <- mean(dataWeek$btc)
meanCO2Week <- mean(dataWeek$co2Mass)

meanME <- mean(pjmME$marginal_co2_rate) * (1/ 1000) * 0.453592
meanLoad <- mean(dataAfter$load)

meanCO2North <- mean(dataAfter$co2MassNorthampton)

meanSO2 <- mean(dataAfter$so2Mass) * 1000 
meanNOX <- mean(dataAfter$noxMass) * 1000 


# Regressions-----------------------------------------------------------------------------------

# only non-zero generation days 
# APPENDIX TABLE A7
reg0 <- felm(data = dataAfter %>% filter(co2Mass > 0), co2Mass ~ btc + costMWh | factor(year) + factor(month) + factor(dow)|0|0)
reg1 <- felm(data = dataAfter %>% filter(co2Mass > 0), co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter %>% filter(co2Mass > 0), co2Mass ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter %>% filter(co2Mass > 0), co2Mass ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter %>% filter(co2Mass > 0), co2Mass ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTCNonZero,0), round(meanBTCNonZero,0), round(meanBTCNonZero,0), round(meanBTCNonZero,0)),
                           c("Mean CO2", round(meanCO2NonZero,0), round(meanCO2NonZero,0), round(meanCO2NonZero,0), round(meanCO2NonZero,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTCNonZero/meanCO2NonZero), 2), round(summary(reg2)$coefficients[1] * (meanBTCNonZero/meanCO2NonZero), 2),  round(summary(reg3)$coefficients[1] * (meanBTCNonZero/meanCO2NonZero), 2),  round(summary(reg4)$coefficients[1] * (meanBTCNonZero/meanCO2NonZero), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_nonzero.tex")


# only top quartile of electricity prices 
# APPENDIX TABLE A8 
reg0 <- felm(data = dataAfter %>% filter(paLMPQ == 4), co2Mass ~ btc + costMWh | factor(year) + factor(month) + factor(dow)|0|0)
reg1 <- felm(data = dataAfter %>% filter(paLMPQ == 4), co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter %>% filter(paLMPQ == 4), co2Mass ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter %>% filter(paLMPQ == 4), co2Mass ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter %>% filter(paLMPQ == 4), co2Mass ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTCHigh,0), round(meanBTCHigh,0), round(meanBTCHigh,0), round(meanBTCHigh,0)),
                           c("Mean CO2", round(meanCO2High,0), round(meanCO2High,0), round(meanCO2High,0), round(meanCO2High,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTCHigh/meanCO2High), 2), round(summary(reg2)$coefficients[1] * (meanBTCHigh/meanCO2High), 2),  round(summary(reg3)$coefficients[1] * (meanBTCHigh/meanCO2High), 2),  round(summary(reg4)$coefficients[1] * (meanBTCHigh/meanCO2High), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_highprice.tex")


# drop pandemic 
# APPENDIX TABLE A9 
reg0 <- felm(data = dataAfter %>% filter(year != 2020), co2Mass ~ btc + costMWh | factor(year) + factor(month) + factor(dow)|0|0)
reg1 <- felm(data = dataAfter %>% filter(year != 2020), co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter %>% filter(year != 2020), co2Mass ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter %>% filter(year != 2020), co2Mass ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter %>% filter(year != 2020), co2Mass ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTCNo20,0), round(meanBTCNo20,0), round(meanBTCNo20,0), round(meanBTCNo20,0)),
                           c("Mean CO2", round(meanCO2No20,0), round(meanCO2No20,0), round(meanCO2No20,0), round(meanCO2No20,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTCNo20/meanCO2No20), 2), round(summary(reg2)$coefficients[1] * (meanBTCNo20/meanCO2No20), 2),  round(summary(reg3)$coefficients[1] * (meanBTCNo20/meanCO2No20), 2),  round(summary(reg4)$coefficients[1] * (meanBTCNo20/meanCO2No20), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_droppandemic.tex")


# weekly
# APPENDIX TABLE A10
reg0 <- felm(data = dataWeek, co2Mass ~ btc + costMWh | factor(year) + factor(month)|0|0)
reg1 <- felm(data = dataWeek, co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) |0|0)
reg2 <- felm(data = dataWeek, co2Mass ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month)|0|0)
# table
stargazer(reg1, reg2, 
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTCWeek,0), round(meanBTCWeek,0)),
                           c("Mean CO2", round(meanCO2Week,0), round(meanCO2Week,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTCWeek/meanCO2Week), 2), round(summary(reg2)$coefficients[1] * (meanBTCWeek/meanCO2No20), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_weekly.tex")

# coal lag 
# APPENDIX TABLE A11 
reg0 <- felm(data = dataAfter, co2Mass ~ btc + costMWhLag | factor(year) + factor(month) + factor(dow)|0|0)
reg1 <- felm(data = dataAfter, co2Mass ~ btc + costMWhLag + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter, co2Mass ~ btc + costMWhLag + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter, co2Mass ~ btc + costMWhLag + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter, co2Mass ~ btc + costMWhLag + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"), 
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0)),
                           c("Mean CO2", round(meanCO2,0), round(meanCO2,0), round(meanCO2,0), round(meanCO2,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTC/meanCO2), 2), round(summary(reg2)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanCO2), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_coallag.tex")

# electricity price robustness 
# APPENDIX TABLE A12
reg1 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + factor(paLMPQuantile)| factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + factor(dummyBuy) + factor(dummySell)| factor(year) + factor(month) + factor(dow)|0|0)
reg4 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg5 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + factor(paLMPQuantile)| factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg6 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + factor(dummyBuy) + factor(dummySell)| factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4, reg5, reg6, 
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Lin ", "Bin ", "D B/S","Lin ", "Bin ", "D B/S"),
                           c("$E_{BTC}$ Control", "-", "-", "-", "-", "-", "-"),
                           c("Mean BTC", round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0)),
                           c("Mean CO2", round(meanCO2,0), round(meanCO2,0), round(meanCO2,0), round(meanCO2,0), round(meanCO2,0), round(meanCO2,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTC/meanCO2), 2), round(summary(reg2)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg5)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg6)$coefficients[1] * (meanBTC/meanCO2), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2),  round(summary(reg5)$coefficients[1] * (190), 2),  round(summary(reg6)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_lmp.tex")

# generation  
# APPENDIX TABLE A13 
reg0 <- felm(data = dataAfter, load ~ btc + costMWh | factor(year) + factor(month) + factor(dow)|0|0)
reg1 <- felm(data = dataAfter, load ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter, load ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter, load ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter, load ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"), 
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0)),
                           c("Mean Load (kWh)", round(meanLoad,0), round(meanLoad,0), round(meanLoad,0), round(meanLoad,0), round(meanLoad,0), round(meanLoad,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTC/meanLoad), 2), round(summary(reg2)$coefficients[1] * (meanBTC/meanLoad), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanLoad), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanLoad), 2)), 
                           c("Mean PJM Marginal Emissions (kg per kWh)", round(meanME,3), round(meanME,3), round(meanME,3), round(meanME,3)),
                           c("Implied CO2 Emissions (Metric Tons)", round(meanME * 0.001 * summary(reg1)$coefficients[1] ,3), round(meanME * 0.001 * summary(reg2)$coefficients[1] ,3), round(meanME * 0.001 * summary(reg3)$coefficients[1] ,3), round(meanME * 0.001 * summary(reg4)$coefficients[1] ,3)),
                           c("Implied Social Cost", round(summary(reg1)$coefficients[1] * meanME * 0.001 * (190), 2), round(summary(reg2)$coefficients[1] * meanME * 0.001 * (190), 2), round(summary(reg3)$coefficients[1] * meanME * 0.001 * (190), 2), round(summary(reg4)$coefficients[1] * meanME * 0.001 * (190), 2))),
          out="output/01_regressions/01_robust_load.tex")

# Northampton
# APPENDIX TABLE A15 
reg1 <- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)+ factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) + factor(btcDiffEra)|0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"), 
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Carbon Dioxide Emissions (Metric Tons)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and CO2 Emissions at Northampton Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0)),
                           c("Mean CO2", round(meanCO2North,0), round(meanCO2North,0), round(meanCO2North,0), round(meanCO2North,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTC/meanCO2North), 2), round(summary(reg2)$coefficients[1] * (meanBTC/meanCO2North), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanCO2North), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanCO2North), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[1] * (190), 2), round(summary(reg2)$coefficients[1] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_northampton.tex")


# SO2 and NOX
# APPENDIX TABLE A16
dataAfter <- dataAfter %>% mutate(noxMass = noxMass * 1000, 
                                  so2Mass = so2Mass * 1000)
reg1 <- felm(data = dataAfter, noxMass ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow)|0|0)
reg2 <- felm(data = dataAfter, noxMass ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)|0|0)
reg3 <- felm(data = dataAfter, so2Mass ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)|0|0)
reg4 <- felm(data = dataAfter, so2Mass ~ btc + costMWh + mWhPerBTC  | factor(year) + factor(month) + factor(dow) |0|0)
# table
stargazer(reg1, reg2, reg3, reg4,
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("NOx Emissions (kg)", "SO2 Emissions (kg)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and NOx and SO2 Emissions at Scrubgrass Power Plant",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "-", "Y", "-"),
                           c("$E_{BTC}$ Control", "-", "Y", "-", "Y"),
                           c("Mean BTC", round(meanBTC,0), round(meanBTC,0), round(meanBTC,0), round(meanBTC,0)),
                           c("Mean Emissions (kg)", round(meanNOX,0), round(meanNOX,0), round(meanSO2,0), round(meanSO2,0)),
                           c("Elasticity", round(summary(reg1)$coefficients[1] * (meanBTC/meanNOX), 2), round(summary(reg2)$coefficients[1] * (meanBTC/meanNOX), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanSO2), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanSO2), 2))),
          out="output/01_regressions/01_appendix_nox_so2.tex")
