#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# External validity and context - PA plants generation / retirement 
# Requires: 
# -- data/annual_emissions/annual-emissions-pa-TYPE.csv (annual emissions from CEMS)
# -- data/other/coal-type.csv (estimates for conversion rate from steam load to MW)
# last modified 09/05/23
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

# PA Coal Power Plant Data  -----------------------------------------------------------------

coal <- read.csv("data/annual_emissions/annual-emissions-pa-coal.csv")
coal <- coal %>% mutate(type = "Coal")
coalPet <- read.csv("data/annual_emissions/annual-emissions-pa-coalpet.csv")
coalPet <- coalPet %>% mutate(type = "Petroleum Coke")
coalRefuse <- read.csv("data/annual_emissions/annual-emissions-pa-coalrefuse.csv")
coalRefuse <- coalRefuse %>% mutate(type = "Coal Refuse")

data <- rbind(coal, coalPet, coalRefuse)
rm(coal, coalPet, coalRefuse)
data <- data %>% arrange(Facility.ID, Year)

# coal type for conversion 
coalType <- read.csv("data/other/coal-type.csv")
data <- left_join(data, coalType)
rm(coalType)

# keep relevant variables and change units 
data <- data %>% dplyr::select(state = State, name = Facility.Name, id = Facility.ID, type, year = Year, heatInput = Heat.Input..mmBtu., grossLoad = Gross.Load..MWh., steamLoad = Steam.Load..1000.lb., so2Mass = SO2.Mass..short.tons., co2Mass = CO2.Mass..short.tons., noxMass = NOx.Mass..short.tons., coalType = Fuel.Type, energy = Energy)
data <- data %>% mutate(steamInd = ifelse(!is.na(steamLoad)&is.na(grossLoad), 1, 0))
data <- data %>% mutate(energyConvert = ifelse(steamInd == 1 & !is.na(energy), energy, 
                                               ifelse(steamInd == 1 & is.na(energy), 9845, NA)))
data <- data %>% dplyr::select(state, name, id, type, year, heatInput, grossLoad, steamLoad, so2Mass, co2Mass, noxMass, steamInd, energyConvert)
data <- data %>% mutate(heatInput = heatInput * 10^6, 
                        grossLoad = grossLoad * 10^3, 
                        steamLoad = steamLoad * 1000 * 1/24 * energyConvert * 0.000293, 
                        load = ifelse(is.na(grossLoad), steamLoad, grossLoad), 
                        co2Mass = co2Mass * 0.907185 * 1000, 
                        so2Mass = so2Mass * 0.907185 * 1000,
                        noxMass = noxMass * 0.907185 * 1000)
data <- data %>% dplyr::select(state, name, id, type, year, heatInput, load, co2Mass, so2Mass, noxMass)
data <- data %>% filter(year >= 2000)

# drop repeats
data <- data %>% filter(!(name == "Gilberton Power Company" & type == "Coal Refuse" & year < 2003))
data <- data %>% filter(!(name == "Mt. Carmel Cogeneration" & type == "Coal Refuse" & year == 2014))
data <- data %>% filter(!(name == "Cambria Cogen" & type == "Coal Refuse" & year <= 2003))
data <- data %>% filter(!(name == "Northampton Generating Plant" & type == "Coal Refuse"))
data <- data %>% filter(!(name == "Northampton Generating Plant" & type == "Petroleum Coke"))
data <- data %>% filter(!(name == "Seward" & type == "Coal Refuse" & year == 2003))
data <- data %>% filter(!(name == "Gilberton Power Company" & type == "Coal Refuse" & year == 2003))
data <- data %>% filter(!(name == "St. Nicholas Cogeneration Project" & type == "Coal Refuse" & year == 2009))

# check for any other repeats 
# data <- data %>% mutate(ind = 1) %>% group_by(id, year) %>% mutate(count = sum(ind))

# calculate heat rate, co2 rate and so2rate,
data <- data %>% mutate(heatRate = heatInput / load, 
                        co2Rate = co2Mass / load, 
                        so2Rate = so2Mass / load,
                        noxRate = noxMass / load, 
                        )

# get minimum and maximum years 
data <- data %>% group_by(id) %>% mutate(minYear = min(year), maxYear = max(year)) %>% ungroup()

# retired vs. nonretired plants 
data <- data %>% mutate(retiredInd = ifelse(maxYear < 2022, 1, 0))

dataDist <- data %>% group_by(name, id, retiredInd) %>% summarise(meanHeatRate = mean(heatRate, na.rm=TRUE), 
                                                       meanCo2Rate = mean(co2Rate, na.rm=TRUE)) %>% ungroup()
dataDist <- dataDist %>% mutate(meanHeatRate = ifelse(is.nan(meanHeatRate) | meanHeatRate == Inf, NA, meanHeatRate), 
                                meanCo2Rate = ifelse(is.nan(meanCo2Rate), NA, meanCo2Rate))
dataDist <- dataDist %>% mutate(retired = ifelse(retiredInd == 1, "Retired", "Active"))

# Charts  ---------------------------------------------------------------------------

colors <- c("Retired"="#CC6677", "Active"="#44AA99")

# PA coal generation over the years 
dataYear <- data %>% filter(id != 50974 & id != 50776) %>% group_by(year) %>% summarise(sum = sum(load, na.rm=TRUE)/(10^9))
dataScrubYear <- data %>% filter(id == 50974) %>% group_by(year) %>% summarise(sum = sum(load, na.rm=TRUE)/(10^9))

a <- ggplot() + 
  geom_line(data=dataYear, aes(x = year, y = sum)) + 
  geom_smooth(data=dataYear, aes(x = year, y = sum), color = "darkgray", size = 0.5, alpha=0.3) + 
  ylim(0, 150) + theme_bw() + xlab("Year") + ylab("Coal Generation (Million MWh)") +
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

b <- ggplot() +
  geom_line(data=dataScrubYear, aes(x = year, y = sum)) + 
  geom_smooth(data=dataScrubYear %>% filter(year != 2020), aes(x = year, y = sum), color="#882255", size=0.5, alpha=0.3) + 
  ylim(0, 0.8) + theme_bw() + xlab("Year") + ylab(" ")+
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

# APPENDIX FIGURE A5
ggarrange(a, b, nrow=1, common.legend = TRUE, legend="bottom") +  bgcolor("white") + border("white") + labs(color="Fuel")
ggsave("output/03_context_extvalidity/03_pa_trends.png", width=12, height = 6)

