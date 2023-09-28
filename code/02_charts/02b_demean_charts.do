**************************************************************************************
** Cryptocurrency Project 
** 02_charts: create graphs 
** Requires: 
** -- data/processed/00_data.csv (created in 00_clean_data.R)
** Anna Papp, ap3907@columbia.edu 
** Last modified: 8/16/23
**************************************************************************************

************* 00 - Setup *************************************************************

global path "/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube"
cd "$path"
set more off
set scheme plotplain
local c1 "204 102 119"
local c2 "68 170 153"
graph drop _all 

************* GRAPH 2: Post-mining **************************************************

import delimited "data/processed/00_data.csv", clear 

* sum up and average 
collapse (sum) co2mass (mean) btc mwhperbtc costmwh palmp, by(year month)

* format 
gen date = 1 
gen newdate = mdy(month, date, year)
format newdate %tdMon_CCYY

* label 
keep if newdate >= 21305
replace co2mass = co2mass / 1000
label var co2mass "CO2 Mass (1000 Metric Tons)"
label var btc "Bitcoin Price ($)"

* raw graph  
graph twoway line co2mass newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btc newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 

* residuals 1
reg co2mass costmwh i.month, vce(robust)
predict co2masspred
reg btc costmwh i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

* residuals graph 1
graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6))  name(g1)

drop co2masspred co2massresid btcpred btcresid

* residuals 2
reg co2mass costmwh mwhperbtc palmp i.month, vce(robust)
predict co2masspred
reg btc costmwh mwhperbtc palmp i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

* residuals graph 2
graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6))  name(g2)
graph export output/02_charts/02_btc_co2_residuals.png, replace 

************* GRAPH 3: Pre-mining **************************************************
graph drop _all 

import delimited "data/processed/00_data.csv", clear 

* sum up and average 
collapse (sum) co2mass (mean) btc, by(year month)

* format 
gen date = 1 
gen newdate = mdy(month, date, year)
format newdate %tdMon_CCYY

* label 
keep if newdate < 21305 & year <= 2018
replace co2mass = co2mass / 1000
label var co2mass "CO2 Mass (1000 Metric Tons)"
label var btc "Bitcoin Price ($)"

* raw graph 
graph twoway line co2mass newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btc newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 

* residuals 1 
reg co2mass  i.month, vce(robust)
predict co2masspred
reg btc  i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

* residuals graph 1
graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6)) 

drop co2masspred co2massresid btcpred btcresid


* residuals 2
reg co2mass costmwh mwhperbtc palmp i.month, vce(robust)
predict co2masspred
reg btc costmwh mwhperbtc palmp i.month, vce(robust)
predict btcpred 
gen co2massresid = co2mass - co2masspred 
gen btcresid = btc - btcpred 
label var co2massresid "CO2 Mass Residual (1000 Metric Tons)"
label var btcresid "Bitcoin Price Residual ($)"

* residuals graph 2
graph twoway line co2massresid newdate, yaxis(1) lcolor("`c1'") ylabel(, labcolor("`c1'") tlcolor("`c1'")) yscale(lcolor("`c1'")) || line btcresid newdate, lcolor("`c2'") yaxis(2) ylabel(, ax(2) labcolor("`c2'") tlcolor("`c2'")) yscale(ax(2) lcolor("`c2'")) xtitle("Month") legend(pos(6))  name(g2)
graph export output/02_charts/02_btc_co2_residuals_pre.png, replace 

