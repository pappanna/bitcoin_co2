**************************************************************************************
** Cryptocurrency Project 
** 02_charts: create graphs 
** Requires: 
** -- data/processed/00_data.csv (created in 00_clean_data.R)
** -- data/bitcoin/country-hashrate.csv 
** Anna Papp, ap3907@columbia.edu 
** Last modified: 8/16/23
**************************************************************************************

************* 00 - Setup *************************************************************

global path "/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube"
cd "$path"
set more off
set scheme plotplain
local c1 "136 34 85"
local c2 "51 34 136"

************* GRAPH 1: Hashrates **************************************************

import delimited "data/bitcoin/country-hashrate.csv", clear

* format 
split date, p("/")
destring date1 date2 date3, force replace
replace date3 = date3 + 2000
gen newdate = mdy(date1,date2,date3)
format newdate %tdMon_CCYY

* monthly date 
replace monthly_hashrate_ =subinstr(monthly_hashrate_, "%", "",.)
rename monthly_hashrate_ hashrate
destring hashrate, replace force

* countries -- keep China and US 
keep if country == "Mainland China" | country == "United States"
drop date*
drop monthly_*

* label 
sort newdate country
gen china = hashrate[_n-1]
keep if country == "United States"
rename hashrate us 
label var us "US Share (%)"
label var china "China Share (%)"
gen world = 100 - us -  china 
label var world "Remaning Hashrate Share"

* for display 
gen tag = newdate == newdate[_N]
gen chinaperc = china 
gen usperc = us 
tostring chinaperc usperc, replace force
replace chinaperc = substr(chinaperc, 1, 4) + "%"
replace usperc = substr(usperc, 1, 4) + "%"

graph twoway (connected us newdate, msymbol(O) mcolor("`c2'") lcolor("`c2'")) (scatter us newdate if tag, msymbol(O) mcolor("`c2'") lcolor("`c2'") mlabel(usperc) mlabpos(12) mlabcolor("`c2'") mlabsize(vsmall) ) (connected china newdate, msymbol(O) mcolor("`c1'") lcolor("`c1'")) (scatter china newdate if tag, msymbol(O) mcolor("`c1'") lcolor("`c1'")  mlabel(chinaperc) mlabpos(12) mlabcolor("`c1'") mlabsize(vsmall) legend(order(1 3))), xtitle("Month") legend(pos(6)) ytitle("Bitcoin Hashrate Share (%)") 
graph export output/02_charts/02_country_share.png, replace

************* GRAPH 4: Bitcoin Difficulty *******************************************

import delimited "data/processed/00_data.csv", clear 
keep date btc difficulty 
gen datenew = date(date, "YMD" )
format datenew %tdMon_CCYY
drop date 
rename datenew date 
tsset date 
replace difficulty = difficulty / (10^12)
label var difficulty "Bitcoin Network Difficulty (Trillion Units)"

graph twoway (tsline difficulty, yaxis (1) xtitle("Date") lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) legend(pos(6)) ) 
graph export output/02_charts/02_difficulty.png, replace
