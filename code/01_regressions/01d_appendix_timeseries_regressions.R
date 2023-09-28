#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# Polynomial time trend robustness 
# Requires: 
# -- data/processed/00_data.rda (created in 00_clean_data.R)
# last modified 08/17/23
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

# Summary stats used in text -----------------------------------------------------------------

meanBTC <- mean(dataAfter$btc)
meanCO2 <- mean(dataAfter$co2Mass)

meanDiff <- dataAfter  %>% group_by(btcDiffEra) %>% summarise(btcMin = min(btc), btcMax = max(btc))
meanDiff <- meanDiff %>% mutate(diff = btcMax - btcMin)
meanDiff <- mean(meanDiff$diff)

meanBTCBefore <- mean(dataBefore$btc)
meanCO2Before <- mean(dataBefore$co2Mass)

# Regressions-----------------------------------------------------------------------------------

# after 
reg0 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + t + t2 + t3 + t4 + t5 | 0|0|0)

reg1 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + paLMP + t + t2 + t3 + t4 + t5|0|0|0)
reg2 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + mWhPerBTC + t + t2 + t3 + t4 + t5 |0|0|0)

reg3 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + paLMP + t + t2 + t3 + t4 + t5 |factor(btcDiffEra)|0|0)
reg4 <- felm(data = dataAfter, co2Mass ~ btc + costMWh + mWhPerBTC + t + t2 + t3 + t4 + t5  |factor(btcDiffEra)|0|0)

# 5th order polynomial time trend robustness 
# APPENDIX TABLE A4 
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
                           c("Elasticity", round(summary(reg1)$coefficients[2] * (meanBTC/meanCO2), 2), round(summary(reg2)$coefficients[2] * (meanBTC/meanCO2), 2),  round(summary(reg3)$coefficients[1] * (meanBTC/meanCO2), 2),  round(summary(reg4)$coefficients[1] * (meanBTC/meanCO2), 2)), 
                           c("Social Cost", round(summary(reg1)$coefficients[2] * (190), 2), round(summary(reg2)$coefficients[2] * (190), 2),  round(summary(reg3)$coefficients[1] * (190), 2),  round(summary(reg4)$coefficients[1] * (190), 2))),
          out="output/01_regressions/01_robust_poly_reg_panelA.tex")


