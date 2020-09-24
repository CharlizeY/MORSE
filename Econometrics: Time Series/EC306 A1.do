import delimited "/Users/Cherry0904/Desktop/Data_for_306Assignment_2020.csv", clear

tsset time

gen Lgdp = ln(gdp)
gen DLgdp = d.Lgdp

gen Lcpi = ln(cpi)
gen DLcpi = d.Lcpi

gen Ltbil_3m = ln(tbil_3m)
gen DLtbil_3m = d.Ltbil_3m

gen Lbaa_spread = ln(baa_spread)

gen Lspcs_hpi = ln(spcs_hpi)
gen DLspcs_hpi = d.Lspcs_hpi
gen Learning = ln(earning) 
gen Lmort_30yr = ln(mort_30yr)
gen Lreal_est_loan = ln(real_est_loan)


************************************
* Q1(a): Let's plot original times series 
************************************
* Real GDP
tsline Lgdp
gr save lgdp.gph, replace
tsline DLgdp
gr save dlgdp.gph, replace

* Inflation 
tsline DLcpi
gr save DLcpi.gph, replace

* Tbill rate
tsline Ltbil_3m
gr save ltbil_3m.gph, replace
tsline DLtbil_3m
gr save dltbil_3m.gph, replace

* Term Spread
tsline termspread_10yr 
gr save termspread_10yr.gph, replace

* Credit Spread
tsline Lbaa_spread
gr save lbaa_spread.gph, replace

graph combine Lgdp.gph Dlcpi.gph Ltbil_3m.gph termspread_10yr.gph Lbaa_spread.gph
graph combine dlgdp.gph dltbil_3m.gph
************************************
* Maximum lags? n obs / n years + 1
di 243/(2019-1959+1) //four lags


* Testing for unit roots in GDP, Inflation, the 3-Month Tbill, the Term Spread and the Credit Spread (ADF test)
* H0: unit root
dfgls Lgdp, maxlag(4)//opt lag 2
dfuller Lgdp, trend regress lags(2)//cons + trend => model C
dfgls DLgdp, maxlag(4)//opt lag 3
dfuller DLgdp, regress lags(3) //cons => model B
//dfuller DLgdp, drift regress lags(3)

dfgls DLcpi, maxlag(4)//opt lag 4
dfuller DLcpi, regress lags(4)  //cons => model B

dfgls Ltbil_3m, maxlag(4)//opt lag 4
dfuller Ltbil_3m, regress lags(4) //cons + trend => model C
dfgls DLtbil_3m, maxlag(4)//opt lag 4
dfuller DLtbil_3m, regress lags(4) //cons => model B

dfgls termspread_10yr, maxlag(4)//opt lag 3
dfuller termspread_10yr, regress lags(3) //cons => model B

dfgls Lbaa_spread, maxlag(4)//opt lag 1
dfuller Lbaa_spread, regress lags(1) //cons => model B

* Determine the optimal lag length - here is 2
varsoc DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread if time <= tq(2006q4) ,maxlag(4)

* Estimate a VAR up to 2006q4 (with the optimal lag length 2)
var DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread if time <= tq(2006q4), lags(1/2) // VAR(2)

* Check autocorrelation of redisuals
//varlmar, mlag(4)

* Granger causality test
vargranger




************************************
* Q1(b): 1-step forecasting
************************************
* Test for residual autocorrelation (LM tests) after estimating the VAR models (by default is iag order 2)
//varlmar

rolling, window(192) recursive saving(var1, replace): var DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread, lags(1/2)
use var1, clear

import delimited "/Users/Cherry0904/Desktop/Data_for_306Assignment_2020.csv", clear
tsset time
gen Lgdp = ln(gdp)
gen DLgdp = d.Lgdp

gen Lcpi = ln(cpi)
gen DLcpi = d.Lcpi

gen Ltbil_3m = ln(tbil_3m)
gen DLtbil_3m = d.Ltbil_3m

gen Lbaa_spread = ln(baa_spread)

gen Lspcs_hpi = ln(spcs_hpi)
gen DLspcs_hpi = d.Lspcs_hpi
gen Learning = ln(earning) 
gen Lmort_30yr = ln(mort_30yr)
gen Lreal_est_loan = ln(real_est_loan)

gen end=time
tsset end, quarterly
merge 1:1 end using var1

gen DLgdp_F1= DLgdp_b_cons + _stat_1*DLgdp + _stat_3*DLcpi + _stat_5*DLtbil_3m + _stat_7*termspread_10yr +_stat_9*Lbaa_spread + _stat_2*l.DLgdp + _stat_4*l.DLcpi + _stat_6*l.DLtbil_3m + _stat_8*l.termspread_10yr + _stat_10*l.Lbaa_spread

gen DLgdp_F11=l.DLgdp_F1

//var DLgdp Linf DLtbil_3m termspread_10yr Lbaa_spread if time <= tq(2006q4), lags(1/2)
//fcast compute _var_06q4, nose
//fcast graph _var_06q4DLgdp


************************************
* Let' fit an AR(1) to data up to 2006q4
* ARIMA(p,d,q) => ARIMA(1,0,0)
arima DLgdp if time <= tq(2006q4), arima(1,0,0)

* Check residuals (acf,pacf on residuals)
//predict fe_DLgdp, residuals
//ac fe_DLgdp
//pac fe_DLgdp
//sktest fe_DLgdp

* Generating 1-step forecasts using an AR(1) for DLgdp
* We can use all the data on the dependent variable that is available right up to the time of each prediction 
predict f_DLgdp_ar1, y
predict fe_DLgdp_ar1, residuals
* Or we can use the data up to a particular time, after which the predicted value of the dependent variable is used recursively to make later predictions
//predict f_DLgdp_dyn_ar1, y dyn(tq(2006q4))
//predict fe_DLgdp_dyn_ar1, residuals

* Compare predictions: one-step VAR vs one-step AR(1). What do we observe?
tsline DLgdp DLgdp_F11 f_DLgdp_ar1 if time > tq(2006q4)
//tsline DLgdp DLgdp_F11 f_DLgdp_dyn_ar1 if time > tq(2006q4)

* Calculate RMSE for VAR and AR(1)
gen fe_var = (DLgdp-DLgdp_F11)^2
egen mse_var=total(fe_var) if time > tq(2006q4)
count if time>tq(2006q4) //56 observations
replace mse_var=mse_var/56
gen rmse_var=sqrt(mse_var)

gen fe2_ar1 = fe_DLgdp_ar1^2
egen mse_ar1=total(fe2_ar1) if time > tq(2006q4)
count if time>tq(2006q4) //56 observations
replace mse_ar1=mse_ar1/56 
gen rmse_ar1=sqrt(mse_ar1)

compare rmse_var rmse_ar1 if time > tq(2006q4)




************************************
* Q1(c)+(d): 1-step forecasting
************************************
* Estimate a SVAR based on Choleski decomposition - be aware of the ordering of variables
matrix A = (1,0,0,0,0\.,1,0,0,0\.,.,1,0,0\.,.,.,1,0\.,.,.,.,1)
matrix B = (.,0,0,0,0\0,.,0,0,0\0,0,.,0,0\0,0,0,.,0\0,0,0,0,.)
svar DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread,lags(1/2) aeq(A) beq(B) 
matrix Aest = e(A)
matrix Best = e(B)
matrix chol_est = inv(Aest)*Best
matrix list chol_est

* Draw the graph of OIRFs - be aware of the ordering of variables
varsoc DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread, maxlag(4)//opt lag 2
var DLgdp DLcpi DLtbil_3m termspread_10yr Lbaa_spread lags(1/2)
irf create var2, set(var2,replace)
irf graph oirf, set(var2) irf(var2) impulse(Lbaa_spread) response(DLgdp DLcpi DLtbil_3m) ustep(50) yline(0)

* Draw the graph of OIRFs of the new VAR
varsoc DLgdp DLcpi Lbaa_spread, maxlag(4)//opt lag 3
var DLgdp DLcpi Lbaa_spread, lags(1/3)
irf create var3, set(var3,replace)
irf graph oirf, set(var3) irf(var3) impulse(Lbaa_spread) response(DLgdp DLcpi) ustep(50) yline(0)





************************************
* Q2(a): test for bivariate cointegration - OLS
************************************
* Let's plot the time series and their first differences
tsline spcs_hpi
gr save spcs_hpi.gph, replace
tsline d.spcs_hpi
gr save dspcs_hpi.gph, replace

tsline Learning
gr save Learning.gph, replace
tsline d.Learning
gr save dLearning.gph, replace

tsline Lmort_30yr
gr save Lmort_30yr.gph, replace
tsline d.Lmort_30yr
gr save dLmort_30yr.gph, replace

tsline Lreal_est_loan
gr save Lreal_est_loan.gph, replace
tsline d.Lreal_est_loan
gr save dLreal_est_loan.gph, replace

graph combine spcs_hpi.gph Learning.gph Lmort_30yr.gph Lreal_est_loan.gph

* Maximum lags? n obs / n years + 1
di 131/(2019-1987+1) //four lags

* Testing for unit roots in US house price, earnings, mortgage rates and loans (ADF test)
* H0: unit root
dfuller spcs_hpi, trend regress lags(4)//cons + trend => model C
dfuller d.spcs_hpi, regress lags(4)//cons => model B

dfuller Learning, trend regress lags(4) //cons + trend => model C
dfuller d.Learning, regress lags(4) //cons => model B

dfuller Lmort_30yr, regress lags(4) //cons => model B
dfuller d.Lmort_30yr, regress lags(4) //cons => model B

dfuller real_est_loan, trend regress lags(4)//cons + trend => model C
dfuller d.real_est_loan, regress lags(4)//cons => model B

* Estimate a cointegrating equation of US earnings and house prices by regression
reg spcs_hpi Learning 
predict s, resid
tsline s if time >= 113
gr save s.gph, replace

* Test the stationarity of the residuals 
dfgls s, maxlag(4)//opt lag 2
dfuller s,regress lags(2)//cons => model B

* Estimate the time for the structural break(s) in house price
reg spcs_hpi Learning
estat sbsingle//test one break
//regress spcs_hpi Learning
//estat sbcusum//test multiple breaks

* New regression with a structural break
* Create dummy variables
gen consdummy=0
replace consdummy=1 if time>200
gen redummy=Learning
replace redummy=0 if time<=200

reg spcs_hpi Learning consdummy redummy
predict ss, resid
tsline ss if time >= 113
gr save ss.gph, replace

* Test the stationarity of the residuals 
dfgls ss, maxlag(4)//opt lag 2
dfuller ss,regress lags(2)//cons => model B



************************************
* Q2(b): test for multivariate cointegration - VECM
************************************
* Determine the optimal lag length - here is 2 based on HQIC and SBIC
varsoc Lspcs_hpi Learning Lmort_30yr Lreal_est_loan, maxlag(4)

* Perform Johansen cointegration test with the opt lag 
vecrank Lspcs_hpi Learning Lmort_30yr Lreal_est_loan, lags(2) trend(constant)//no trend, max rank is 1
vecrank Lspcs_hpi Learning Lmort_30yr Lreal_est_loan, lags(2) trend(rtrend)//with trend, max rank is 1

* Estimate the corresponding VECM
vec Lspcs_hpi Learning Lmort_30yr Lreal_est_loan, trend(constant) rank(1) lags(2)
//vec Lspcs_hpi Learning Lmort_30yr Lreal_est_loan, trend(rtrend) rank(1) lags(2)





************************************
* Q3: ARCH and GARCH models
************************************
* ADF test for house price growth - indeed stationary
dfgls DLspcs_hpi, maxlag(4)//opt lag 3
dfuller DLspcs_hpi, regress lags(3)//cons => model B

* Plot ACF and PACF to estimate a suitable ARMA model
ac DLspcs_hpi
gr save ac_dlspcs_hpi.gph, replace
pac DLspcs_hpi
gr save pac_dlspcs_hpi, replace
graph combine ac_dlspcs_hpi.gph pac_dlspcs_hpi.gph
//the suitable model here is AR(4)
arima Lspcs_hpi if time >= 113, arima(4,0,0)

* Check the residuals
predict fe_DLspcs, residuals

* Plot the square of residuals
gen fe_DLspcs2 = fe_DLspcs^2
tsline fe_DLspcs2 if time >= 115
gr save fe_DLspcs.gph, replace

* LM test on ARCH effects, choose maxlag=15 as if beyond this, better use GARCH
regress fe_DLspcs
estat archlm, lags(1/15)
display chi2tail(1,6.548) //0.0105
display chi2tail(1,-5.067)//0.000
display chi2tail(1,19.854)//8.359e-06

* Plot the residuals against the square residuals and check any TARCH effects
scatter fe_DLspcs fe_DLspcs2 if time >= 115

* Estimate sensible GARCH models - ARCH(1), ARCH(2), GARCH(1,1), TARCH(1,1)
arch DLspcs_hpi if time >= 116, ar(1/4) arch(1/1)
arch DLspcs_hpi if time >= 116, ar(1/4) arch(1/2)
arch DLspcs_hpi if time >= 116, ar(1/4) arch(1/1) garch(1/1)
//arch DLspcs_hpi if time >= 116, ar(1/4) arch(1/1) tarch(1/1)
