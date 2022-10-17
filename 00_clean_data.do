**************************************************************
** Cryptocurrency Project 
** 00_clean_data: clean and combine raw data 
** Requires: raw data files 
** Anna Papp, ap3907@columbia.edu 
** Last modified: 10/12/22
**************************************************************

************* 00 - Setup *************************************

global path "/Volumes/GoogleDrive/My Drive/PhD/01_research/00_research/09_crypto/crypto_short/"
cd "$path"
set more off
set scheme plotplain

************* 01 - Load Data *********************************

*** Emissions Data : Scrubgrass *** 
import delimited "data/daily-emissions-scrubgrass.csv", varnames(1) clear 
keep date unitid operatingtimecount sumoftheoperatingtime steamload1000lb so2* co2* nox* heatinputmmbtu
split date, p("/")
rename date1 month 
rename date2 day 
rename date3 year 
destring year month day, replace 
replace year = year + 2000
order year month day
drop date 
sort year month day 
collapse (sum) operatingtimecount sumoftheoperatingtime heatinputmmbtu steamload1000lb so2massshorttons co2massshorttons noxmassshorttons, by(year month day)
tempfile emissions_daily 
save `emissions_daily'

*** Emissions Data : Other Waste Coal Power Plants *** 
local plantnames cambria colver gilberton mtcarmel northampton stnicholas 
foreach plantname of local plantnames{
	
	import delimited "data/daily-emissions-PAcoal.csv", varnames(1) clear 
	
	if "`plantname'" == "cambria" {
		local id 10641
	}
	if "`plantname'" == "colver" {
		local id 10143
	}
	if "`plantname'" == "gilberton" {
		local id 10113
	}
	if "`plantname'" == "mtcarmel" {
		local id 10343
	}
	if "`plantname'" == "northampton" {
		local id 50888
	}
	if "`plantname'" == "stnicholas" {
		local id 54634
	}
	
	keep if facilityid == `id'
	
	keep date unitid operatingtimecount sumoftheoperatingtime grossloadmwh steamload1000lb so2* co2* nox* heatinputmmbtu
	split date, p("/")
	rename date1 month 
	rename date2 day 
	rename date3 year 
	destring year month day, replace 
	replace year = year + 2000
	order year month day
	drop date 
	sort year month day 
	collapse (sum) operatingtimecount sumoftheoperatingtime heatinputmmbtu grossloadmwh steamload1000lb so2massshorttons co2massshorttons noxmassshorttons, by(year month day)
	rename heatinputmmbtu  `plantname'_heatinput
	rename steamload1000lb  `plantname'_steamload
	rename grossloadmwh  `plantname'_grossload
	rename so2massshorttons `plantname'_so2mass
	rename co2massshorttons `plantname'_co2mass
	rename noxmassshorttons `plantname'_noxmass
	tempfile `plantname'_emissions_daily 
	save ``plantname'_emissions_daily'
}

*** Cryptocurrency Prices *** 
import delimited "data/daily-bitcoin-coinbase.csv", varnames(1) clear
rename cbbtcusd btc
split date, p("/")
rename date1 month 
rename date2 day 
rename date3 year 
destring year month day, replace 
replace year = year + 2000
order year month day btc
drop date 
sort year month day 
tempfile bitcoin_daily 
save `bitcoin_daily'

*** Bitcoin Difficulty *** 
import delimited "data/bitcoin-difficulty.csv", varnames(1) clear 
rename ïtime date
split date, p("/")
rename date1 month 
rename date2 day 
rename date3 year 
split year, p(" ")
drop year year2
rename year1 year
destring year month day, replace 
replace year = year + 2000
order year month day difficulty 
drop date 
rename difficulty btcdiff
tempfile bitcoin_difficulty
save `bitcoin_difficulty'

*** Energy Prices *** 
* PENELEC 
import delimited "data/hourly-penelec.csv", clear varnames(1)
keep datetime_beginning_utc total_lmp_da
split datetime_beginning_utc, p("/", " ", ":")
rename datetime_beginning_utc1 month 
rename datetime_beginning_utc3 year 
rename datetime_beginning_utc2 day 
destring month year day, replace 
replace year = year + 2000 
drop datetime_beginning_utc*
collapse (mean) total_lmp_da, by(year month day)
rename total_lmp_da penelec_lmp_da
tempfile penelec_daily
save `penelec_daily'

* PPL
import delimited "data/hourly-ppl.csv", clear varnames(1)
keep datetime_beginning_utc total_lmp_da
split datetime_beginning_utc, p("/", " ", ":")
rename datetime_beginning_utc1 month 
rename datetime_beginning_utc3 year 
rename datetime_beginning_utc2 day 
destring month year day, replace 
replace year = year + 2000 
drop datetime_beginning_utc*
collapse (mean) total_lmp_da, by(year month day)
rename total_lmp_da ppl_lmp_da
tempfile ppl_daily
save `ppl_daily'


* VENANGO 
import delimited "data/hourly-venango.csv", clear varnames(1)
keep datetime_beginning_utc total_lmp_da
split datetime_beginning_utc, p("/", " ", ":")
rename datetime_beginning_utc1 month 
rename datetime_beginning_utc3 year 
rename datetime_beginning_utc2 day 
destring month year day, replace 
replace year = year + 2000 
drop datetime_beginning_utc*
collapse (mean) total_lmp_da, by(year month day)
rename total_lmp_da venango_lmp_da
tempfile venango_daily
save `venango_daily'

*** Weather Data for PA Stations w/ Consistent Data*** 
import delimited "data/daily-weather-PA.csv", clear varnames(1)
keep station name date temp
split date, p("/")
rename date1 month 
rename date2 day 
rename date3 year 
destring year month day, replace 
replace year = year + 2000
order year month day
drop date 
split name, p(",")
split name2, p(" ")
keep if name21 == "PA"
drop name*
sort station year month day 
tempfile before 
save `before'
gen obscount = 1 
collapse (sum) obscount, by(station)
gen keepdata = 0 
replace keepdata = 1 if obscount == 2738
keep station keepdata 
tempfile keepfile 
save `keepfile'
use `before', clear 
merge m:1 station using `keepfile', keep(1 3)
keep if keepdata == 1
drop keepdata _merge 
collapse (mean) temp, by(year month day)
tempfile pa_temp 
save `pa_temp'

*** Coal Data *** 
import delimited "data/daily-coal.csv", varnames(1) clear 
keep date close
rename close coal 
split date, p("/")
rename date1 month 
rename date2 day 
rename date3 year 
destring year month day, replace 
replace year = year + 2000
order year month day
drop date 
sort year month day 
tempfile coal 
save `coal'

*** S&P 500 Data *** 
import delimited "data/daily-sp500.csv", varnames(1) clear 
keep date sp500
split date, p("-")
rename date1 year
rename date2 month
rename date3 day
destring year month day, replace 
order year month day
drop date 
sort year month day 
tempfile sp500
save `sp500'

************* 02 - Combine Data ******************************

* combine data 
use `emissions_daily', clear 
merge 1:1 year month day using `bitcoin_daily', keep(1 3) nogen 
merge 1:1 year month day using `bitcoin_difficulty', keep(1 3) nogen 
merge 1:1 year month day using `penelec_daily', keep(1 3) nogen 
merge 1:1 year month day using `ppl_daily', keep(1 3) nogen 
merge 1:1 year month day using `venango_daily', keep(1 3) nogen 
merge 1:1 year month day using `pa_temp', keep(1 3) nogen
merge 1:1 year month day using `coal', keep(1 3) nogen 
merge 1:1 year month day using `sp500', keep(1 3) nogen 
local plantnames cambria colver gilberton mtcarmel northampton stnicholas 
foreach plantname of local plantnames{
	merge 1:1 year month day using ``plantname'_emissions_daily', keep(1 3) nogen 
}

* difficulty era variable 
fillmissing btcdiff, with(previous)
replace btcdiff = btcdiff / 10^13
egen btcdiffera = group(btcdiff)

* time variables 
gen t = _n
gen t2 = t * t 
gen t3 = t * t * t
gen t4 = t * t * t * t
gen t5 = t * t * t * t * t
gen date = mdy(month, day, year)
order date
format date %td
gen dow = dow(date)

* renames
rename heatinputmmbtu heatinput 
rename steamload1000lb steamload 
rename so2massshorttons so2mass 
rename co2massshorttons co2mass 
rename noxmassshorttons noxmass

* unit fixes, convert to metric tons
replace steamload = steamload * 0.453592 
replace so2mass = so2mass * 907.19 / 1000 
replace co2mass = co2mass * 907.19 / 1000 
replace noxmass = noxmass * 907.19 / 1000 
foreach plantname of local plantnames{
	replace `plantname'_steamload = `plantname'_steamload * 0.453592 
	replace `plantname'_so2mass = `plantname'_so2mass * 907.19 / 1000 
	replace `plantname'_co2mass = `plantname'_co2mass * 907.19 / 1000 
	replace `plantname'_noxmass = `plantname'_noxmass * 907.19 / 1000 
}

* fill missing market prices 
fillmissing coal, with(previous)
fillmissing sp500, with(previous)

* average PA grid prices 
gen pa_lmp_da = (penelec_lmp_da + ppl_lmp_da) / 2

* label variables
order date year month day dow operatingtimecount sumoftheoperatingtime heatinput steamload so2mass co2mass noxmass btc btcdiff btcdiffera penelec_lmp_da ppl_lmp_da pa_lmp_da temp coal t t2 t3 t4 t5 
label var date "Date"
label var year "Year"
label var month "Month"
label var day "Day"
label var dow "Day of Week"
label var operatingtimecount "Hours Operating (2 Units)"
label var sumoftheoperatingtime "Sum of Operating Time (2 Units)"
label var heatinput "Heat Input (mmBtu)"
label var steamload "Steam Load (Metric Ton)"
label var so2mass "SO2 Mass (Metric Ton)"
label var co2mass "CO2 Mass (Metric Ton)"
label var noxmass "NOX Mass (Metric Ton)"
label var btc "Bitcoin Price ($)"
label var btcdiff "Bitcoin Difficulty"
label var btcdiffera "Bitcoin Difficulty Era"
label var penelec_lmp_da "Penelec Day-Ahead LMP ($)"
label var ppl_lmp_da "PPL Day-Ahead LMP ($)"
label var pa_lmp_da "PA Day-Ahead LMP ($)"
label var venango_lmp_da "Venango Day-Ahead LMP ($)"
label var temp "Temperature (F)"
label var coal "Coal per Ton($)"
label var sp500 "S&P 500 Price ($)"
foreach plantname of local plantnames{
	
	if "`plantname'" == "cambria" {
		local name "Cambria"
	}
	if "`plantname'" == "colver" {
		local name "Colver"
	}
	if "`plantname'" == "gilberton" {
		local name "Gilberton"
	}
	if "`plantname'" == "mtcarmel" {
		local name "Mt. Carmel"
	}
	if "`plantname'" == "northampton" {
		local name "Northampton"
	}
	if "`plantname'" == "stnicholas" {
		local name "St. Nicholas"
	}
	
	label var `plantname'_heatinput "`name' - Heat Input (mmBtu)"
	label var `plantname'_steamload "`name' - Steam Load (Metric Ton)"
	label var `plantname'_grossload "`name' - Gross Load (MWh)"
	label var `plantname'_so2mass "`name' - SO2 Mass (Metric Ton)"
	label var `plantname'_co2mass "`name' - CO2 Mass (Metric Ton)"
	label var `plantname'_noxmass "`name' - NOX Mass (Metric Ton)"
}

* save 
save "data/processed/00_data", replace 
export delimited "data/processed/00_data.csv", replace 
