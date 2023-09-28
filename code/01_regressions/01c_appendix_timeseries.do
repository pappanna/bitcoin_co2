**************************************************************************************
** Cryptocurrency Project 
** Time series collinearity checks 
** Requires: 
** -- data/processed/00_data.rda (created in 00_clean_data.R)
** Anna Papp, ap3907@columbia.edu 
** Last modified: 06/15/22
**************************************************************************************

************* 00 - Setup *************************************************************

global path "/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube/"
cd "$path"
set more off
set scheme plotplain
local c1 "213 94 0"
local c2 "0 158 115"

************* MAIN RESULTS: CO2, TABLE 1 **************************************************

*** AFTER BITCOIN MINING 
import delimited "data/processed/00_data.csv", clear 

gen dateReal = date(date, "YMD")
tsset dateReal

keep if v1 > 1947

gen t = v1
gen t2 = t * t 
gen t3 = t * t * t
gen t4 = t * t * t * t
gen t5 = t * t * t * t * t

*** RAW 
dfuller co2mass 
dfuller co2mass, trend
dfuller co2mass, drift 

dfuller btc
dfuller btc, trend
dfuller btc, drift 
dfuller btc, drift 

dfuller costmwh 
dfuller costmwh, trend
dfuller costmwh, drift 

dfuller mwhperbtc
dfuller mwhperbtc, trend
dfuller mwhperbtc, drift 

dfuller palmp
dfuller palmp, trend
dfuller palmp, drift 

*** FIRST DIFFERENCE 
gen co2lag = co2mass[_n-1]
gen co2diff = co2mass - co2lag

gen btclag = btc[_n-1]
gen btcdiff = btc - btclag 

gen costlag = costmwh[_n-1]
gen costdiff = costmwh- costlag 

gen mwhlag = mwhperbtc[_n-1]
gen mwhdiff = mwhperbtc - mwhlag 

gen lmplag = palmp[_n-1]
gen lmpdiff = palmp - lmplag 

dfuller co2diff 
dfuller co2diff, trend 
dfuller co2diff, drift 

dfuller btcdiff
dfuller btcdiff, trend 
dfuller btcdiff, drift

dfuller costdiff
dfuller costdiff, trend 
dfuller costdiff, drift 

dfuller mwhdiff
dfuller mwhdiff, trend 
dfuller mwhdiff, drift 

dfuller lmpdiff
dfuller lmpdiff, trend 
dfuller lmpdiff, drift 

*** RESIDUALS - fixed effects 

quietly reg co2mass i.dow i.year i.month, vce(robust)
predict co2pred
gen co2detrend = co2mass - co2pred

quietly reg btc i.dow i.year i.month, vce(robust)
predict btcpred
gen btcdetrend = btc - btcpred

quietly reg costmwh i.dow i.year i.month, vce(robust)
predict costpred
gen costdetrend = costmwh - costpred

quietly reg mwhperbtc i.dow i.year i.month, vce(robust)
predict mwhpred
gen mwhdetrend = mwhperbtc - mwhpred

quietly reg palmp i.dow i.year i.month, vce(robust)
predict lmppred
gen lmpdetrend = palmp - lmppred

dfuller co2detrend 
dfuller co2detrend, trend 
dfuller co2detrend, drift 

dfuller btcdetrend
dfuller btcdetrend, trend 
dfuller btcdetrend, drift

dfuller costdetrend
dfuller costdetrend, trend 
dfuller costdetrend, drift 

dfuller mwhdetrend
dfuller mwhdetrend, trend 
dfuller mwhdetrend, drift 

dfuller lmpdetrend
dfuller lmpdetrend, trend 
dfuller lmpdetrend, drift 


*** RESIDUALS - 5th order polynomial time 

quietly reg co2mass t t2 t3 t4 t5  , vce(robust)
predict co2pred
gen co2detrend = co2mass - co2pred

quietly reg btc t t2 t3 t4 t5 , vce(robust)
predict btcpred
gen btcdetrend = btc - btcpred

quietly reg costmwh t t2 t3 t4 t5  ,vce(robust)
predict costpred
gen costdetrend = costmwh - costpred

quietly reg mwhperbtc t t2 t3 t4 t5 , vce(robust)
predict mwhpred
gen mwhdetrend = mwhperbtc - mwhpred

quietly reg palmp t t2 t3 t4 t5 , vce(robust)
predict lmppred
gen lmpdetrend = palmp - lmppred

dfuller co2detrend 
dfuller co2detrend, trend 
dfuller co2detrend, drift 

dfuller btcdetrend
dfuller btcdetrend, trend 
dfuller btcdetrend, drift

dfuller costdetrend
dfuller costdetrend, trend 
dfuller costdetrend, drift 

dfuller mwhdetrend
dfuller mwhdetrend, trend 
dfuller mwhdetrend, drift 

dfuller lmpdetrend
dfuller lmpdetrend, trend 
dfuller lmpdetrend, drift 

