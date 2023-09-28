#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# External validity and context - heat rate and co2 intensity distribution 
# Requires: 
# -- data/annual_emissions/annual-emissions-2022-TYPE.csv (annual emissions from CEMS)
# -- data/other/coal-type.csv (estimates for conversion rate from steam load to MW)
# last modified 09/05/23
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

# Load Annual Emissions Data ------------------------------------------------------------------

# load 2022 annual emissions data for coal, gas, oil, and other plants 
coal <- read.csv("data/annual_emissions/annual-emissions-2022-coal.csv")
coal <- coal %>% mutate(type = "1 coal")

gas <- read.csv("data/annual_emissions/annual-emissions-2022-gas.csv")
gas <- gas %>% mutate(type = "3 gas")

oil <- read.csv("data/annual_emissions/annual-emissions-2022-oil.csv")
oil <- oil %>% mutate(type = "2 oil")

other <- read.csv("data/annual_emissions/annual-emissions-2022-other.csv")
other <- other %>% mutate(type = "4 other")

data <- rbind(coal, gas, oil, other)
rm(coal, gas, oil, other)

# Data Processing ----------------------------------------------------------------------------

# coal type for conversion 
coalType <- read.csv("data/other/coal-type.csv")

# keep relevant variables and change units 
data <- left_join(data, coalType)

# keep relevant variables and change units 
data <- data %>% dplyr::select(state = State, name = Facility.Name, id = Facility.ID, type, heatInput = Heat.Input..mmBtu., grossLoad = Gross.Load..MWh., steamLoad = Steam.Load..1000.lb., so2Mass = SO2.Mass..short.tons., co2Mass = CO2.Mass..short.tons., noxMass = NOx.Mass..short.tons., coalType = Fuel.Type, energy = Energy)

data <- data  %>% mutate(steamInd = ifelse(!is.na(steamLoad)&is.na(grossLoad), 1, 0))
data <- data  %>% mutate(energyConvert = ifelse(steamInd == 1 & !is.na(energy), energy, 
                                                ifelse(steamInd == 1 & is.na(energy) & type == "1 coal", 9845,
                                                       ifelse(steamInd == 1 & is.na(energy) & type == "2 oil", 19750, 
                                                              ifelse(steamInd == 1 & is.na(energy) & type == "3 gas", 19750, NA)))))
data <- data  %>% dplyr::select(state, name, id, type, heatInput, grossLoad, steamLoad, so2Mass, co2Mass, noxMass, steamInd, energyConvert)
data <- data %>% mutate(heatInput = heatInput * 10^6, 
                        grossLoad = grossLoad * 10^3, 
                        steamLoad = steamLoad * 1000 * 1/24 * energyConvert * 0.000293, 
                        load = ifelse(is.na(grossLoad), steamLoad, grossLoad), 
                        co2Mass = co2Mass * 0.907185 * 1000, 
                        so2Mass = so2Mass * 0.907185 * 1000,
                        noxMass = noxMass * 0.907185 * 1000)
data <- data %>% dplyr::select(state, name, id, type, heatInput, load, co2Mass, so2Mass, noxMass)

# keep observations with no missing heat input and load 
data <- data %>% filter(!(is.na(heatInput)|is.na(load)))
data <- data %>% arrange(id, type)
data <- data %>% filter(load != 0)

# check whether separate data for separate types 
dataFacility <- data %>% group_by(state, name, id) %>% summarise(mean = mean(heatInput))
data <- left_join(data, dataFacility)
rm(dataFacility)
data <- data %>% mutate(ind = ifelse(heatInput == mean, 1, 0)) 
data <- data %>% group_by(state, name, id) %>% mutate(cumSum = cumsum(ind))
data <- data %>% filter(cumSum <= 1)
data <- data %>% dplyr::select(-c(mean, ind, cumSum)) %>% ungroup()

# now calculate heat rate and co2 rate for each plant 
data <- data %>% mutate(heatRate = heatInput / load, 
                        co2Rate = co2Mass / load)

# drop outliers 
data <- data %>% filter(heatRate < 100000)

# drop other types, these are too noisy 
data <- data %>% filter(type != "4 other")
data <- data %>% mutate(type = ifelse(type == "1 coal", "Coal", 
                                      ifelse(type == "2 oil", "Oil", "Gas")))

# Now Create Plots ---------------------------------------------------------------------------

colors <- c("Coal" = "#882255", "Oil" = "#44AA99", "Gas" = "#DDCC77")

a <- ggplot(data, aes(x=heatRate, fill=type)) + 
  geom_histogram( bins = 100, position = "stack") + 
  scale_fill_manual(values = colors, name = "Fuel Type")+
  geom_vline(xintercept = 14436.49, linetype = "dashed") + 
  geom_vline(xintercept = 15281.21, linetype = "dashed", color="red") +
  geom_vline(xintercept = 10709.49, linetype = "dashed", color="blue") +
  xlim(0, 40000)+
  xlab("Heat Rate (Btu / kWh)") + ylab("Count") + 
  theme_bw() + 
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

b <- ggplot(data, aes(x=co2Rate, fill=type)) + 
  geom_histogram( bins = 100, position = "stack") + 
  scale_fill_manual(values = colors, name="Fuel Type")+
  geom_vline(xintercept = 1.372427, linetype = "dashed") + 
  geom_vline(xintercept = 1.114522, linetype = "dashed", color="blue") +
  geom_vline(xintercept = 0.48, linetype = "solid", color="#117733", size = 1) +
  xlab("Carbon Intensity (kg CO2 per kWh)") + ylab(" ") + 
  theme_bw() + 
  xlim(0, 2)+
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 
# FIGURE 4
ggarrange(a, b, ncol=2, nrow=1, common.legend = TRUE, legend="bottom") +  bgcolor("white") + border("white") + labs(color="Fuel")
ggsave(file="output/03_context_extvalidity/03_plant_distribution.png", width=12, height = 6)


