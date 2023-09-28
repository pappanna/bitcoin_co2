#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# Other coal power plants 
# Requires: 
# -- data/processed/00_data.rda (created in 00_clean_data.R)
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

# Regressions-----------------------------------------------------------------------------------

# APPENDIX TABLE A14 - non-cryptomining waste coal plants 
reg1 <- felm(data = dataAfter, co2MassCambria ~ btc + costMWh + paLMP| factor(year) + factor(month) + factor(dow) |0|0)
reg2 <- felm(data = dataAfter, co2MassCambria ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow)  |0|0)

reg3 <- felm(data = dataAfter, co2MassColver ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)  |0|0)
reg4 <- felm(data = dataAfter, co2MassColver ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow) |0|0)

reg5 <- felm(data = dataAfter, co2MassGilberton ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow)|0|0)
reg6 <- felm(data = dataAfter, co2MassGilberton ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow) |0|0)

reg7 <- felm(data = dataAfter, co2MassMtCarmel ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow) |0|0)
reg8 <- felm(data = dataAfter, co2MassMtCarmel ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow) |0|0)

reg9 <- felm(data = dataAfter, co2MassStNicholas ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow) |0|0)
reg10<- felm(data = dataAfter, co2MassStNicholas ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow) |0|0)

reg11 <- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + paLMP | factor(year) + factor(month) + factor(dow) |0|0)
reg12<- felm(data = dataAfter, co2MassNorthampton ~ btc + costMWh + mWhPerBTC | factor(year) + factor(month) + factor(dow) |0|0)

stargazer(reg1, reg3, reg5, reg7,  reg9,
          type="text", df=F,report=("vc*sp"), 
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          keep = c("btc"),
          title="Non-Cryptomining Pennsylvania Waste Coal Plants",
          add.lines = list(c("$C_{gen}$ Control", "Y", "Y", "Y", "Y", "Y"),
                           c("$P_{elec}$ Control", "Y", "Y", "Y", "Y", "Y"),
                           c("$E_{BTC}$ Control", "-", "-", "-", "-", "-")),
          out="output/01_regressions/01_appendix_waste.tex")
