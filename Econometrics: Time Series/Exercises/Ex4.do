*************************************
*** Exercise Sheet # 4 Answer Key ***
*************************************

cd "~/Sync/U Warwick Fall 2017/EC306/seminar4/"

* UK/US exchange rate, monthly 1971m1 to 2009m8

use "rxd.dta", clear

tsset time
gen Drxd = d.rxd
gen Drxd_1 = l.Drxd
gen Drxd_2 = l2.Drxd

* Let's look at time series first
tsline Drxd, tline(1999m12)

* ACF/PACF
ac Drxd
gr save acf.gph, replace
pac Drxd
gr save pacf.gph, replace
graph combine acf.gph pacf.gph

* ARCH effects: test
reg Drxd
estat archlm, lags(6)

*****************
** Question 1: **
*****************

*Estimate up to the end of 1999
*Statistics > Time Series > ARCH/GARCH
*Statistics > Postestimation > Predictions, residuals, etc. > 
*predict ..., variance -> Predicted values for the conditional variance.
*Plot the two on the same graph.
*Statistics > Time Series > Graphs > Time-series line plots

arch Drxd Drxd_1 Drxd_2 if time < tm(2000m1), arch(1/6)
predict v_archf if time > tm(1999m12), variance

arch Drxd if time < tm(2000m1), arch(1/6) arima(2, 0, 0)

arch Drxd Drxd_1 Drxd_2 if time < tm(2000m1), arch(1/1) garch(1/1)
predict v_garchf if time > tm(1999m12), variance

twoway (tsline v_archf v_garchf if time > tm(1999m12))


*****************
** Question 2: **
*****************
	
*Estimate a threshold ARCH model (TARCH)
arch Drxd Drxd_1 Drxd_2, abarch(1/1) atarch(1/1) sdgarch(1/1)

*abarch = absolute value ARCH terms
*sdgarch = lags of sigma_t
*atarch = absolute threshold ARCH terms

*Is there any evidence that good and bad news impact differently on volatility?

*Coefficient on ATARCH should significantly different from zero for an asymmetric effect
*Coefficient on ATARCH positive => bad news has a bigger effect on future volatility than good news


*****************
** Question 3: **
*****************

*Estimate an ARCH in mean model
arch Drxd Drxd_1 Drxd_2, arch(1/1) garch(1/1) archm
*Does the conditional variance have a significant effect in the mean equation?

*Investors may require higher returns to hold assets known to have higher variance, 
*i.e. to face conditional volatility in their protfolio

*The coefficient on archm measures the relationship between risk and return 
*Higher expected variance should be rewarded with higher expected returns

*****************
** Question 4: **
*****************

*As an additional exercise, 
*The data set CD.dta contains monthly data on the 1-month Certificate of Deposit, 1965:12 to 2009:10
*Estimate an ARCH model up to 1980

*Compare with estimates of the model that include 1965 to 1989
use "cd.dta", clear
*gen time = tm(1965m12) + _n  - 1
*format time %tm

tsset time
*gen Dcd = d.cd
*gen Dcd1 = l.Dcd
*gen Dcd2 = l2.Dcd
*gen Dcd3 = l3.Dcd
*gen Dcd4 = l4.Dcd

tsline Dcd, tline(1980m1) tline(1990m1)

arch Dcd Dcd1 Dcd2 Dcd3 Dcd4 if time < tm(1980m1), arch(1/1) garch(1/1)
predict archf80 if time > tm(1980m1), variance

arch Dcd Dcd1 Dcd2 Dcd3 Dcd4 if time < tm(1990m1), arch(1/1) garch(1/1)
predict archf89 if time > tm(1980m1), variance

twoway (tsline archf80 archf89 if time > tm(1980m1) & time < tm(1990m1))

*Is the model constant over the 1980's?

 
