**************************************************************************************
** Cryptocurrency Project 
** 02_charts: create graphs 
** Requires: 00_data.dta from 00_clean_data.do 
** Anna Papp, ap3907@columbia.edu 
** Last modified: 9/8/22
**************************************************************************************

************* 00 - Setup *************************************************************

global path "/Volumes/GoogleDrive/My Drive/PhD/01_research/00_research/09_crypto/crypto_short/"
cd "$path"
set more off
set scheme plotplain
local c1 "213 94 0"
local c2 "0 158 115"

************* GRAPH 1: Hashrates **************************************************

import delimited "data/country-hashrate.csv", clear

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

graph twoway (connected us newdate, msymbol(O) mcolor(dknavy) lcolor(dknavy)) (scatter us newdate if tag, msymbol(O) mcolor(dknavy) lcolor(dknavy) mlabel(usperc) mlabpos(12) mlabcolor(dknavy) mlabsize(vsmall) ) (connected china newdate, msymbol(O) mcolor(cranberry) lcolor(cranberry)) (scatter china newdate if tag, msymbol(O) mcolor(cranberry) lcolor(cranberry)  mlabel(chinaperc) mlabpos(12) mlabcolor(cranberry) mlabsize(vsmall) legend(order(1 3))), xtitle("Month") legend(pos(6)) ytitle("Bitcoin Hashrate Share (%)") 
graph export output/06_country_share.png, replace

************* GRAPH 2: Post-mining **************************************************

use "data/processed/00_data.dta", clear 

* sum up and average 
collapse (sum) co2mass steamload (mean) btc btcdiffera, by(year month)

* format 
gen date = 1 
gen newdate = mdy(month, date, year)
format newdate %tdMon_CCYY

* label 
keep if newdate >= 21305
replace co2mass = co2mass / 1000
label var co2mass "CO2 Mass (1000 Metric Tons)"
label var steamload "Steam Load (Metric Ton)"
label var btc "Bitcoin Price ($)"

graph twoway line co2mass newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btc newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 
graph export output/07_btc_co2.png, replace 

reg co2mass btcdiffera i.month, vce(robust)
predict co2masspred
reg btc btcdiffera i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 
graph export output/08_btc_co2.png, replace 

************* GRAPH 3: Pre-mining **************************************************

use "data/processed/00_data.dta", clear 

* sum up and average 
collapse (sum) co2mass steamload (mean) btc btcdiffera, by(year month)

* format 
gen date = 1 
gen newdate = mdy(month, date, year)
format newdate %tdMon_CCYY

* label 
keep if newdate < 21305
replace co2mass = co2mass / 1000
label var co2mass "CO2 Mass (1000 Metric Tons)"
label var steamload "Steam Load (Metric Ton)"
label var btc "Bitcoin Price ($)"

graph twoway line co2mass newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btc newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 
graph export output/09_btc_co2_pre.png, replace 

reg co2mass btcdiffera i.month, vce(robust)
predict co2masspred
reg btc btcdiffera i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 
graph export output/10_btc_co2_pre.png, replace 




