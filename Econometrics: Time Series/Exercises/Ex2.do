*************************************
*** Exercise Sheet 2 ***
*************************************

cd "~/Desktop/EC306/Exercises/Ex2/"

use cons_income.dta, clear

tsset time

gen Lrpdi = ln(rpdi)
gen DLrpdi = d.Lrpdi
gen Lrc = ln(rc)
gen DLrc = d.Lrc

gen Ls=Lrc-Lrpdi

************************************
* Let's plot original times series 
************************************

* Real personal disposable income, log
tsline Lrpdi
gr save lrpdi.gph, replace
tsline DLrpdi
gr save dlrpdi.gph, replace
graph combine lrpdi.gph dlrpdi.gph

* Real personal consumption, log
tsline Lrc
gr save lrc.gph, replace
tsline DLrc
gr save Dlrc.gph, replace
graph combine lrc.gph dlrc.gph

* Real personal savings rate
tsline Ls
gr save ls.gph, replace

************************************
* Q1: ACF and PACF
************************************

* Real personal disposable income, log - levels
ac Lrpdi
gr save ac_lrpdi.gph, replace
pac Lrpdi
gr save pac_lrpdi.gph, replace
graph combine ac_lrpdi.gph pac_lrpdi.gph

* Real personal disposable income, log - first differences
ac DLrpdi
gr save ac_dlrpdi.gph, replace
pac DLrpdi
gr save pac_dlrpdi.gph, replace
graph combine ac_dlrpdi.gph pac_dlrpdi.gph

* Real personal consumption, log - levels
ac Lrc
gr save ac_lrc.gph, replace
pac Lrc
gr save pac_lrc.gph, replace
graph combine ac_lrc.gph pac_lrc.gph

* Real personal consumption, log - first differences
ac DLrc
gr save ac_dlrc.gph, replace
pac DLrc
gr save pac_dlrc.gph, replace
graph combine ac_dlrc.gph pac_dlrc.gph

************************************
* Q2: Unit roots
************************************

* How many lags? n obs / n years + 1

di 250/(2009-1947+1)

* Testing for unit roots in consumption, income and the savings rate
* H0: unit root

dfuller Lrc, trend regress lags(4) //cons + trend => model C
dfuller DLrc, regress lags(4) //cons => model B

dfuller Lrpdi, trend regress lags(4)  //cons + trend => model C
dfuller Ls, trend regress lags(4)  //cons + trend => model C

* Test LS on two sub-samples 
dfuller Ls, trend regress lags(4)
dfuller Ls if time < tq(1980q1), trend regress lags(4)
dfuller Ls if time > tq(1980q1), trend regress lags(4)

************************************
* Q3: Univariate models
************************************

* Let' estimate possible models prior to 1999q4 and predit post-2000q1
* To illustrate:
tsline DLrc, tline(1999q4)
 
** Model 1 AR(2)
* ARIMA(p,d,q) => ARIMA(2,0,0)
arima DLrc if time < tq(1999q4), arima(2,0,0)
arima Lrc if time < tq(1999q4), arima(4,1,0) // this is the same model, but Stata takes first differences

* ARIMA(2,0,0)
arima DLrc if time < tq(1999q4), arima(2,0,0) 
* AIC/BIC information criteria
estat ic

arima DLrc if time < tq(1999q4), ar(2, 4) // can we skip lags? should we?

* Check residuals
predict fe_DLrc, residuals
ac fe_DLrc
pac fe_DLrc
sktest fe_DLrc

** Model 2 ARMA(2,2)
arima DLrc if time < tq(1999q4), arima(2,0,2)
* AIC/BIC information criteria
estat ic

** Model 3 ARMA(4,0)
arima DLrc if time < tq(1999q4), arima(4,0,0)
* AIC/BIC information criteria
estat ic

************************************
* Q4: Forecasting performance
************************************

* Generating 1-step forecasts and MSPE using an AR(2) for DLrc
* We can use all the data on the dependent variable that is available right up to the time of each prediction 
* (the default, which is often called a one-step prediction)
arima DLrc if time < tq(1999q4), arima(2,0,0)
predict f_DLrc_ar2, y
predict fe_DLrc_ar2, residuals

* or we can use the data up to a particular time, after which the predicted value of the dependent 
* variable is used recursively to make later predictions
predict f_DLrc_dyn_ar2, y dyn(tq(1999q4))

* Compare predictions: one-step and dynamic vs real data. What do we observe?
tsline DLrc f_DLrc_ar2 f_DLrc_dyn_ar2 if time >= tq(1999q4)

* Calculate RMSE
gen fe2_ar2 = fe_DLrc_ar2^2
egen mse_ar2=total(fe2_ar2) if time >= tq(1999q4)
count if time>=tq(1999q4) //39 observations
replace mse_ar2=mse_ar2/39 
gen rmse_ar2=sqrt(mse_ar2)

* RMSE for ARMA(2,2)
arima DLrc if time < tq(1999q4), arima(2,0,2)
predict fe_DLrc_arma22, residuals

gen fe2_arma22 = fe_DLrc_arma22^2
egen mse_arma22=total(fe2_arma22) if time >= tq(1999q4)
replace mse_arma22=mse_arma22/39 
gen rmse_arma22=sqrt(mse_arma22)

* RMSE for ARMA(4,0)
arima DLrc if time < tq(1999q4), arima(4,0,0)
predict fe_DLrc_ar4, residuals

gen fe2_ar4 = fe_DLrc_ar4^2
egen mse_ar4=total(fe2_ar4) if time >= tq(1999q4)
replace mse_ar4=mse_ar4/39 
gen rmse_ar4=sqrt(mse_ar4)

bro rmse_ar2 rmse_arma22 rmse_ar4 if time >= tq(1999q4)
