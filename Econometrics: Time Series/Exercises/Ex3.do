*************************************
*** Exercise Sheet # 3 Answer Key ***
*************************************

cd "~/Sync/U Warwick Fall 2017/EC306/seminar3/"

use "money.dta", clear

* rm = real money (log of nominal money minus log of price deflator)
* i = log of real GDP (real income)
* dp = difference in log of price deflator (inflation)
* r = rate of interest 

bro timevar if dumy==1
bro timevar if dumo==1

tsset time

* Let's look at time series first
tsline rm, tline(1973q1)
gr save rm.gph, replace
tsline i
gr save i.gph, replace
tsline dp
gr save dp.gph, replace
tsline r
gr save r.gph, replace
graph combine rm.gph i.gph dp.gph r.gph

* ADF test
dfuller rm, trend regress lags(4) // model C
dfuller i, trend regress lags(4) // model C
dfuller dp, drift regress lags(4) // model B
dfuller r, drift regress lags(4) // model B

*****************
** Question 1: **
*****************

* Estimate a VAR(1) and a VAR(2) for the four variables, including two dummy variables (dumy, dumo)
var rm i dp r, lags(1) exog(dumy dumo) // VAR(1)
var rm i dp r, lags(1/2) exog(dumy dumo) // VAR(2)

* Which is preferred on AIC?
* VAR(1) => -24.70192
* VAR(2) => -24.77215

* Alternatively, use STATA to suggest the lag order based on different information criteria:
varsoc rm i dp r, exog(dumy dumo) maxlag(4)

* varsoc allows to obtain lag-order selection statistics for VARs and VECMs
*    reports the final prediction error (FPE), Akaike's
*    information criterion (AIC), Schwarz's Bayesian information
*    criterion (SBIC), and the Hannan and Quinn information criterion
*    (HQIC) lag-order selection statistics for a series of vector
*    autoregressions of order 1 through a requested maximum lag.  A
*    sequence of likelihood-ratio test statistics for all the full
*    VARs of order less than or equal to the highest lag order is
*    also reported.

* Let's look at the covariance matrix of epsilons

matlist e(Sigma)

*****************
** Question 2: **
*****************

* Test for residual autocorrelation (LM tests) after estimating the VAR models

var rm i dp r, lags(1) exog(dumy dumo)
varlmar

var rm i dp r, lags(1/2) exog(dumy dumo)
varlmar, mlag(2) // default number of lags = 2, mlag = maximum order of autocorrelation

* What do these tests suggest?

** Note: Granger causality

vargranger

*****************
** Question 3: **
*****************

* Estimate the cointegrating rank for a second order VAR, including a constant but not a trend
vecrank rm i dp r, trend(constant) // trend(constant) is the default option

* What do you find the cointegrating rank to be?
 
* Repeat with a restricted trend (this allows for a trend in the cointegrating relationships) 
* How do the results concerning the cointegrating rank change?
vecrank rm i dp r, trend(rtrend)


** vecrank implements three types of methods for determining r = the number of cointegrating equations in a VECM
** The first is Johansen’s “trace” statistic method
** The second is his “maximum eigenvalue” statistic method
** The third method chooses r to minimize an information criterion

** trend(none) do not include a trend or a constant => 
** (i) No deterministic terms in VAR model and cointegrating eqs (not typical in economics !!)

** trend(rconstant) include a restricted constant in model => 
** (ii) Restricted constant: zero growth rates, but a constant in cointegrating  eqns

** trend(constant) include an unrestricted constant in model; the default => 
**  (iii) Unrestricted constant: non-zero growth rates, i.e. constant in VAR model and cointegrating eqns

** trend(rtrend) include a restricted trend in model =>
** (iv) Restricted trend: the variables cointegrate but this ratio changes deterministically with time,
**      i.e. constant and trend in cointegrating eqns

** trend(trend) include a linear trend in the cointegrating equations and a
** quadratic trend in the undifferenced data => 
** (v) Unrestricted trend and constant: quadratic time trend, not typical in economics !!

** H0 for "trace" statistic: no more than r cointegrating equations
** Ha: > than r

** sequential test, when we do not reject H0 then stop
** when "trace" statistic > 5% critical value we reject H0
** e.g. maximum rank = 0 means H0 no cointegrating equations


*****************
** Question 4: **
*****************

* Estimate the corresponding VECM
vec rm i dp r, trend(rtrend) rank(2) lags(2)

* Note 1: Identification of the parameters in the cointegrating equation is achieved by constraining 
* some of them to be fixed, and fixed parameters do not have standard errors.

* Note 2: the constant term in the cointegrating equation is not directly estimated in this trend specification 
* but rather is backed out from other estimates. 
* Not all the elements of the VCE that correspond to this parameter are readily available, 
* so the standard error for the cons parameter is missing.

* But now apply restrictions to B to make the long-run relationships more interpretable. 
* So set the coefficients on rm and i in the first cointegrating vector to be 1 and -1, respectively.
* And exclude these two variables from the second cointegrating vector.
* How many restrictions have we imposed?

constraint 1 [_ce1]rm=1
constraint 2 [_ce1]i=-1
constraint 3 [_ce2]rm=0
constraint 4 [_ce2]i= 0
vec rm i dp r, rank(2) lags(2) dforce bconstraints (1/4) trend(rtrend)

* What is the economic interpretation of the first cointegrating vector? (note: rm is real money, and i is real income)
* The first cointegrating vector implies the velocity of circulation is I(0): Ln(RM) - Ln(Income)



