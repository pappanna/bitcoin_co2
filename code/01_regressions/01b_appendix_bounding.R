#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# Bounding exercise appendix tables 
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

# Regressions-----------------------------------------------------------------------------------

data <- data %>% mutate(hashrateEH = hashrate / 1000000)

# btc price and PA electricity prices 
reg0a <- felm(data = data, paLMP ~ btc + coal | 0|0|0)
reg1a <- felm(data = data, paLMP ~ btc + coal + temp | factor(year) + factor(month) + factor(dow)|0|0)

meanLMP <- round(mean(data$paLMP), 2)

# btc price and network hashrate 
reg0b <- felm(data = data, hashrateEH ~ btc + coal | 0|0|0)
reg1b <- felm(data = data, hashrateEH ~ btc + coal + temp | factor(year) + factor(month) + factor(dow)|0|0)

meanHR <- round(mean(data$hashrateEH), 2)

# appendix table for bounding exercise 
# APPENDIX TABLE A2 
stargazer(reg0a, reg1a, reg0b, reg1b, 
          type="text", df=F,
          report=("vc*sp"),
          column.sep.width = c("10pt"),
          omit.stat=c("ser","adj.rsq", "rsq"),
          digits=3,
          covariate.labels = c("Bitcoin Price"),
          dep.var.labels = c("Day-Ahead LMP ($)", "Network Hashrate (EH/s)"),
          keep = c("btc"),
          title="Daily Bitcoin Price and Electricity Prices and Network Hashrate",
          add.lines = list(c("Coal Price Control", "Y", "Y", "Y", "Y"),
                           c("Temperature Control", "-", "Y", "-", "Y"),
                           c("Mean Day-Ahead LMP", meanLMP, meanLMP, "-", "-"),
                           c("Mean Network HR", "-", "-", meanHR, meanHR)),
          out="output/01_regressions/appendix/01_appendix_bounding.tex")
