#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# External validity and context - plants ripe for retirement analysis
# Requires: 
# -- data/annual_emissions/annual-emissions-[2012/2022].csv (annual emissions from CEMS)
# -- data/ripe_for_retirement/ripe-for-retirement-with-facility-id-high.csv
# -- data/ripe_for_retirement/ripe-for-retirement-with-facility-id-low.csv
# -- data/other/coal-type.csv
# last modified 08/15/23
#############################################################################################

# Setup -------------------------------------------------------------------------------------

## clear variables in environment and script 
rm(list=ls(all=TRUE)); cat("\014") 


## load packages
if(!require(pacman)) install.packages('pacman') 
pacman::p_load( data.table,ggplot2, dplyr, gamlr, nnet, imputeTS, caret, scales, ggthemes, foreign, ggrepel, readr, tidyr, plm, broom, dplyr, Hmisc, sqldf, stargazer, stringr, zoo, glmnet, import, lubridate, ncdf4, raster, lfe, sjPlot, tigris, rgdal, GGally, dotwhisker,choroplethr, choroplethrMaps, splines, fixest, sf,ggpubr, car, geojsonsf, rgeos, rmapshaper, readxl, usmap, tidysynth)    

## directory 
if(Sys.info()["user"] == "annapapp") {
  setwd('/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube') # anna WD
} else {
  setwd('/[OTHER USER]') 
}

# Coal Power Plant Data  --------------------------------------------------------------------

# coal type for conversion 
coalType <- read.csv("data/other/coal-type.csv")

# 2012
coal2012 <- read.csv("data/annual_emissions/annual-emissions-2012-coal.csv")

# keep relevant variables and change units 
coal2012 <- left_join(coal2012, coalType)
coal2012 <- coal2012 %>% dplyr::select(state = State, name = Facility.Name, id = Facility.ID, year = Year, heatInput = Heat.Input..mmBtu., grossLoad = Gross.Load..MWh., steamLoad = Steam.Load..1000.lb., so2Mass = SO2.Mass..short.tons., co2Mass = CO2.Mass..short.tons., noxMass = NOx.Mass..short.tons., coalType = Fuel.Type, energy = Energy)
coal2012 <- coal2012 %>% mutate(steamInd = ifelse(!is.na(steamLoad)&is.na(grossLoad), 1, 0))
coal2012 <- coal2012 %>% mutate(energyConvert = ifelse(steamInd == 1 & !is.na(energy), energy, 
                                               ifelse(steamInd == 1 & is.na(energy), 9845, NA)))
coal2012 <- coal2012 %>% dplyr::select(state, name, id, year, heatInput, grossLoad, steamLoad, so2Mass, co2Mass, noxMass, steamInd, energyConvert)

# keep relevant variables and change units 
coal2012 <- coal2012 %>% mutate(heatInput = heatInput * 10^6, 
                        grossLoad = grossLoad * 10^3, 
                        steamLoad = steamLoad * 1000 * 1/24 * energyConvert * 0.000293,
                        load = ifelse(is.na(grossLoad), steamLoad, grossLoad), 
                        co2Mass = co2Mass * 0.907185 * 1000, 
                        so2Mass = so2Mass * 0.907185 * 1000,
                        noxMass = noxMass * 0.907185 * 1000)
coal2012 <- coal2012 %>% mutate(heatRate = heatInput / load, 
                                co2Rate = co2Mass / load, 
                                so2Rate = so2Mass / load,
                                noxRate = noxMass / load)
coal2012 <- coal2012 %>% dplyr::select(state, name, id, heatRate2012 = heatRate, co2Rate2012 = co2Rate)
coal2012 <- coal2012 %>% filter(!is.na(heatRate2012) & !is.na(co2Rate2012))

# 2022
coal2022 <- read.csv("data/annual_emissions/annual-emissions-2022-coal.csv")

# keep relevant variables and change units 
coal2022 <- left_join(coal2022, coalType)
coal2022 <- coal2022 %>% dplyr::select(state = State, name = Facility.Name, id = Facility.ID, year = Year, heatInput = Heat.Input..mmBtu., grossLoad = Gross.Load..MWh., steamLoad = Steam.Load..1000.lb., so2Mass = SO2.Mass..short.tons., co2Mass = CO2.Mass..short.tons., noxMass = NOx.Mass..short.tons., coalType = Fuel.Type, energy = Energy)
coal2022 <- coal2022 %>% mutate(steamInd = ifelse(!is.na(steamLoad)&is.na(grossLoad), 1, 0))
coal2022 <- coal2022 %>% mutate(energyConvert = ifelse(steamInd == 1 & !is.na(energy), energy, 
                                                       ifelse(steamInd == 1 & is.na(energy), 9845, NA)))
coal2022 <- coal2022 %>% dplyr::select(state, name, id, year, heatInput, grossLoad, steamLoad, so2Mass, co2Mass, noxMass, steamInd, energyConvert)

# keep relevant variables and change units 
coal2022 <- coal2022 %>% mutate(heatInput = heatInput * 10^6, 
                                grossLoad = grossLoad * 10^3, 
                                steamLoad = steamLoad * 1000 * 1/24 * energyConvert * 0.000293,
                                load = ifelse(is.na(grossLoad), steamLoad, grossLoad), 
                                co2Mass = co2Mass * 0.907185 * 1000, 
                                so2Mass = so2Mass * 0.907185 * 1000,
                                noxMass = noxMass * 0.907185 * 1000)
coal2022 <- coal2022 %>% mutate(heatRate = heatInput / load, 
                                co2Rate = co2Mass / load, 
                                so2Rate = so2Mass / load,
                                noxRate = noxMass / load)
coal2022 <- coal2022 %>% dplyr::select(id, heatRate2022 = heatRate, co2Rate2022 = co2Rate)
coal2022 <- coal2022 %>% filter(!is.na(heatRate2022) & !is.na(co2Rate2022))

# combine 
coal <- left_join(coal2012, coal2022)
rm(coal2012, coal2022, coalType)

# Ripe for Retirement Data  -----------------------------------------------------------------

# ripe for retirement, full 
rfrFull <- read.csv("data/ripe_for_retirement/ripe-for-retirement-with-facility-id-high.csv")
rfrFull <- rfrFull %>% dplyr::select(state, id) %>% mutate(rfrFull = 1) %>% filter(!is.na(id))

# ripe for retirement, short 
rfrShort <- read.csv("data/ripe_for_retirement/ripe-for-retirement-with-facility-id-low.csv")
rfrShort <- rfrShort %>% dplyr::select(state, id) %>% mutate(rfrShort = 1) %>% filter(!is.na(id))

rfr <- left_join(rfrFull, rfrShort)
rm(rfrFull, rfrShort)

# Merge  ------------------------------------------------------------------------------------

data <- left_join(coal, rfr)

data <- data %>% mutate(retiredInd = ifelse(is.na(heatRate2022) & is.na(co2Rate2022), 1, 0), 
                        rfrFull = ifelse(is.na(rfrFull), 0, rfrFull), 
                        rfrShort = ifelse(is.na(rfrShort), 0, rfrShort))

dataRfr <- data %>% filter(rfrFull == 1)
dataRfr <- dataRfr %>% mutate(retired = ifelse(retiredInd == 1, "Retired", "Active"))
dataRfr <- dataRfr %>% mutate(retired = ifelse(id == 50974, "Scrubgrass", retired))

sum(dataRfr$retiredInd)

# Charts  ------------------------------------------------------------------------------------

colors <- c("Retired"="#CC6677", "Active"="#44AA99", "Scrubgrass" = "#117733")

# distribution of PA retired and active coal plant heat rates and CO2 rates
a <- ggplot(dataRfr, aes(x=heatRate2012, fill=retired)) + 
  geom_histogram(position = "stack") + 
  scale_fill_manual(values = colors, name = "Retirement Status")+
  geom_vline(xintercept = 15374.51, linetype = "dashed") + 
  xlab("Heat Rate (Btu / kWh)") + ylab("Count") + 
  xlim(7500, 22500)+
  theme_bw() + 
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

b <- ggplot(dataRfr, aes(x=co2Rate2012, fill=retired)) + 
  geom_histogram(position = "stack") + 
  scale_fill_manual(values = colors, name = "Retirement Status")+
  geom_vline(xintercept = 1.393182, linetype = "dashed") + 
  xlab("Carbon Intensity (kg CO2 per kWh)") + ylab(" ") + 
  xlim(0.5, 2)+
  theme_bw() + 
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

# APPENDIX FIGURE A6
ggarrange(a, b, nrow=1, common.legend = TRUE, legend="bottom") +  bgcolor("white") + border("white") 
ggsave("output/04_ripe_for_retirement04_rfr_distribution.png", width=12, height = 6)


