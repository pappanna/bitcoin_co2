**************************************************************************************
** Cryptocurrency Project 
** 01_regressions: run regressions and create tables 
** Requires: 00_data.dta from 00_clean_data.do 
** Anna Papp, ap3907@columbia.edu 
** Last modified: 10/15/22
**************************************************************************************

************* 00 - Setup *************************************************************

global path "/Volumes/GoogleDrive/My Drive/PhD/01_research/00_research/09_crypto/crypto_short/"
cd "$path"
set more off
set scheme plotplain
local c1 "213 94 0"
local c2 "0 158 115"

************* MAIN RESULTS: CO2, TABLE 1 **************************************************

*** AFTER BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly {
eststo: reg co2mass btc coal i.btcdiffera i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

eststo: reg co2mass btc coal i.btcdiffera penelec_lmp_da i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
}

*** BEFORE BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date < 21305
quietly{
eststo: reg co2mass btc coal i.btcdiffera i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

eststo: reg co2mass btc coal penelec_lmp_da i.btcdiffera i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
}

esttab using "output/01_btc.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean co2mean elast, labels(R-squared "Observations" "Mean Bitcoin Price (\$)" "Mean CO$_2$ Emissions (Metric Ton)" "Elasticity") fmt(2 0 0 0 2)) drop(_cons *.btcdiffera penelec_lmp_da coal *.dow *.year *.month t*) title("Daily Bitcoin Price and CO$_2$ Emissions at Scrubgrass Power Plant")  legend label replace

************* GENERATION, TABLE A3 **************************************************

*** AFTER BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly {
eststo: reg steamload btc coal i.btcdiffera i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum steamload
local steamm = `r(mean)'
estadd scalar steammean `steamm'
local elasticity = (`coeff' * `btcm' / `steamm')
estadd scalar elast `elasticity'

eststo: reg steamload btc coal i.btcdiffera penelec_lmp_da coal i.dow i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum steamload
local steamm = `r(mean)'
estadd scalar steammean `steamm'
local elasticity = (`coeff' * `btcm' / `steamm')
estadd scalar elast `elasticity'
}

*** BEFORE BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date < 21305
quietly{
eststo: reg steamload btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum steamload
local steamm = `r(mean)'
estadd scalar steammean `steamm'
local elasticity = (`coeff' * `btcm' / `steamm')
estadd scalar elast `elasticity'

eststo: reg steamload btc coal i.btcdiffera penelec_lmp_da coal i.dow  i.year i.month t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum steamload
local steamm = `r(mean)'
estadd scalar steammean `steamm'
local elasticity = (`coeff' * `btcm' / `steamm')
estadd scalar elast `elasticity'
}

esttab using "output/01b_btc_generation.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean steammean elast, labels(R-squared "Observations" "Mean Bitcoin Price (\$)" "Mean Load (Metric Ton)" "Elasticity") fmt(2 0 0 0 2)) drop(_cons *.dow *.btcdiffera penelec_lmp_da coal *.dow *.year *.month t*) title("Daily Bitcoin Price and Electricity Generation at Scrubgrass Power Plant")  legend label replace


************* OTHER POWER PLANTS, TABLE 2 *****************************************

use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly{
eststo: reg cambria_co2mass btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)
eststo: reg colver_co2mass btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)
eststo: reg gilberton_co2mass btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)
eststo: reg mtcarmel_co2mass btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)
eststo: reg stnicholas_co2mass btc coal i.btcdiffera i.dow  i.year i.month t t2 t3 t4, vce(robust)

}

esttab using "output/02_btc_other.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(N, labels("Observations") fmt(0)) drop(_cons coal *.btcdiffera *.dow *.year *.month t*) title("Daily Bitcoin Price and CO$_2$ Emissions at Non-Cryptomining Pennsylvania Waste Coal Plants")  legend replace


************* OTHER POWER PLANTS: Northampton, TABLE A6 *****************************************

use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly{
eststo: reg northampton_co2mass btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum northampton_co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

eststo: reg northampton_co2mass btc coal penelec_lmp_da i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum northampton_co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
}

esttab using "output/02b_btc_other_northampton.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean co2mean elast, labels(R-squared "Observations"  "Mean Bitcoin Price (\$)" "Mean CO$_2$ Emissions (Metric Ton)" "Elasticity") fmt(2 0 0 0 2)) drop(*.month *.year *.dow _cons t t2 t3 t4  *.btcdiffera penelec_lmp_da coal) title("Daily Bitcoin Price and CO$_2$ Emissions at Scrubgrass Power Plant")  legend replace


************* ROBUSTNESS CHECKS, TABLE A4 *********************************

*** AFTER BITCOIN MINING, VARIOUS CONTROLS 
use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly {
	
eststo: reg co2mass btc, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "-"
estadd local yearfe "-"
estadd local monthfe "-"
estadd local dow "-"
estadd local temp "-"
estadd local timetrend "-"

eststo: reg co2mass btc coal i.year i.month i.dow, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "-"
estadd local yearfe "Yes"
estadd local monthfe "Yes"
estadd local dow "Yes"
estadd local temp "-"
estadd local timetrend "-"

eststo: reg co2mass btc coal i.btcdiffera, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "Yes"
estadd local yearfe "-"
estadd local monthfe "-"
estadd local dow "-"
estadd local temp "-"
estadd local timetrend "-"

eststo: reg co2mass btc coal i.btcdiffera i.year i.month i.dow, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "Yes"
estadd local yearfe "Yes"
estadd local monthfe "Yes"
estadd local dow "Yes"
estadd local temp "-"
estadd local timetrend "-"

eststo: reg co2mass btc coal i.btcdiffera i.year i.month i.dow temp, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "Yes"
estadd local yearfe "Yes"
estadd local monthfe "Yes"
estadd local dow "Yes"
estadd local temp "Yes"
estadd local timetrend "-"

eststo: reg co2mass btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
estadd local differa "Yes"
estadd local yearfe "Yes"
estadd local monthfe "Yes"
estadd local dow "Yes"
estadd local temp "-"
estadd local timetrend "Yes"
}

esttab using "output/03_btc_robust_fes.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4)) ) stats(r2 N btcmean co2mean elast differa yearfe monthfe dow temp timetrend, labels(R-squared "Observations" "BTC" "CO2" "Elasticity" "Difficulty Era FEs" "Year FEs" "Month FEs" "Day-of-Week FEs" "Temperature Control" "4th Order Poly. Timetrend") fmt(2 0 0 0 2)) label title("Robustness Checks") drop(*.month *.year *temp *.dow _cons t t2 t3 t4  *.btcdiffera coal) legend replace


************* ROBUSTNESS CHECKS, TABLE A5 *********************************

*** DROPPING ZEROS

*** AFTER BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
quietly {
eststo: reg co2mass btc coal i.btcdiffera  i.year i.month i.dow t t2 t3 t4  if heatinput > 0, vce(robust)
local coeff = _b[btc]
sum btc if heatinput > 0
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass if heatinput > 0
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

eststo: reg co2mass btc coal penelec_lmp_da i.btcdiffera  i.year i.month i.dow t t2 t3 t4 if heatinput > 0, vce(robust)
local coeff = _b[btc]
sum btc  if heatinput > 0
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass if heatinput > 0
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
}

*** BEFORE BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date < 21305
quietly{
eststo: reg co2mass btc coal i.btcdiffera  i.year i.month i.dow t t2 t3 t4 if heatinput > 0, vce(robust)
local coeff = _b[btc]
sum btc  if heatinput > 0
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass if heatinput > 0
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

eststo: reg co2mass btc coal penelec_lmp_da i.btcdiffera  i.year i.month i.dow t t2 t3 t4 if heatinput > 0, vce(robust)
local coeff = _b[btc]
sum btc if heatinput > 0
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass if heatinput > 0
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
}

esttab using "output/04_btc_robust_zero.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean co2mean elast, labels(R-squared "Observations" "Mean Bitcoin Price (\$)" "Mean CO$_2$ Emissions (Metric Ton)" "Elasticity") fmt(2 0 0 0 2)) drop(*.month *.year *.dow _cons t t2 t3 t4  *.btcdiffera penelec_lmp_da coal) title("Daily Bitcoin Price and CO$_2$ Emissions at Scrubgrass Power Plant")  legend replace


************* OTHER POLLUTANTS, TABLE A7 **************************************************

*** AFTER BITCOIN MINING 
use "data/processed/00_data.dta", clear 
keep if date >= 21305
eststo clear 
replace noxmass = noxmass * 1000 
replace so2mass = so2mass * 1000

quietly {
eststo: reg noxmass btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum noxmass
local noxm = `r(mean)'
estadd scalar pollutantmean `noxm'
local elasticity = (`coeff' * `btcm' / `noxm')
estadd scalar elast `elasticity'

eststo: reg noxmass btc coal penelec_lmp_da i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum noxmass
local noxm = `r(mean)'
estadd scalar pollutantmean `noxm'
local elasticity = (`coeff' * `btcm' / `noxm')
estadd scalar elast `elasticity'

eststo: reg so2mass btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum so2mass
local so2m = `r(mean)'
estadd scalar pollutantmean `so2m'
local elasticity = (`coeff' * `btcm' / `so2m')
estadd scalar elast `elasticity'

eststo: reg so2mass btc coal penelec_lmp_da i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum so2mass
local so2m = `r(mean)'
estadd scalar pollutantmean `so2m'
local elasticity = (`coeff' * `btcm' / `so2m')
estadd scalar elast `elasticity'
}

esttab using "output/05_btc_nox_so2.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean pollutantmean elast, labels(R-squared "Observations" "Bitcoin Price (\$)" "Pollutant Mean (kg)" "Elasticity") fmt(2 0 0 0 2)) drop(*.month *.year  *.dow _cons t t2 t3 t4  *.btcdiffera penelec_lmp_da coal) title("Daily Bitcoin Price and NO$_X$ and SO$_2$ Emissions at Scrubgrass Power Plant")  legend replace


************* ENDOGENEITY: BTC AND GRID PRICES, TABLE A8 *******************************************

*** AFTER BITCOIN MINING
use "data/processed/00_data.dta", clear 
keep if date >= 21305

eststo clear 
quietly {
eststo: reg penelec_lmp_da btc coal, vce(robust)

eststo: reg penelec_lmp_da btc coal temp i.year i.month i.dow, vce(robust)

eststo: reg penelec_lmp_da btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)

}

esttab using "output/11_grid.tex", cells(b(star fmt(5)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N, labels(R-squared "Observations") fmt(2 0 0 0 2)) drop(*.month *.year *temp *.dow _cons *.btcdiffera coal t*) title("Bitcoin Price and Pennsylvania Electricity Prices")  legend label replace


************* RESULTS: CO2, HIGH AVERAGE GRID PRICE, TABLE A9 **************************************

use "data/processed/00_data.dta", clear 
keep if date >= 21305

collapse (mean) penelec_lmp_da, by(btcdiffera)

summarize penelec_lmp_da, detail 
local gridcutoff = `r(p75)' 

gen ind = 0 
replace ind = 1 if penelec_lmp_da >= `gridcutoff'

keep btcdiffera ind

tempfile btcdifferatop 
save `btcdifferatop'

use "data/processed/00_data.dta", clear 
keep if date >= 21305

merge m:1 btcdiffera using `btcdifferatop', keep(1 3) nogen

keep if ind == 1
eststo clear 
eststo: reg co2mass btc coal i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'
eststo: reg co2mass btc coal penelec_lmp_da i.btcdiffera i.year i.month i.dow t t2 t3 t4, vce(robust)
local coeff = _b[btc]
sum btc 
local btcm = `r(mean)'
estadd scalar btcmean `btcm'
sum co2mass
local co2m = `r(mean)'
estadd scalar co2mean `co2m'
local elasticity = (`coeff' * `btcm' / `co2m')
estadd scalar elast `elasticity'

esttab using "output/12_high_grid.tex", cells(b(star fmt(3)) se(par fmt(3)) p(par  fmt(4))) stats(r2 N btcmean co2mean elast, labels(R-squared "Observations" "Mean Bitcoin Price (\$)" "Mean CO$_2$ Emissions (Metric Ton)" "Elasticity") fmt(2 0 0 0 2)) drop(*.month *.year *.dow _cons t t2 t3 t4  *.btcdiffera penelec_lmp_da coal) title("Daily Bitcoin Price and CO$_2$ Emissions at Scrubgrass Power Plant")  legend label replace


