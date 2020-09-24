use "....\Small_var_dataset.dta"
//small data set with obvious variables 

// I previously changed the scale of gdp growth and inflation to % changes:
//gen dgdp1=100*dgdp
//drop dgdp
//gen dgdp =dgdp1
//drop dgdp1
//gen infl1=100*infl
//drop infl
//gen infl=infl1
//drop infl1
//save "\\GOBO\User42\e\ecsmbs\Documents\2019_20\EC306\Assignment\Small_var_dataset.dta",replace

//I do a VAR(2) on this data for this exercise so that there is not too much typing to do later. I am not seriously interested in modelling this data

// First we make the recursive estimation of the var using 'rolling'
// !!!! If you run this anything called 'var1.dta' in your stata disk space will be overwritten !!!! Which is fine, unless that's something for your RAE. 
rolling, window(192) recursive saving(var1, replace): var dgdp infl dtbill, lags(1/2)

//inspect the rolling regression results
use var1, clear //if you got an r(4) error, it was because there was something called var1 on disk, you can destroy it with the ,clear option, but make sure you really want to. 

// The 3*(3*2+1)=21 parameters are stored in variables called _stat_i, and the named constants eg infl_b_const. The first 6 parameters are the GDP equation parameters at the first and second lags, grouped by variable, then there is the gdp constant, then we move onto the inflation equation, etc. Also notice the end of the estimation sample for each regressionis stored in a time variable called 'end'. 

//We need to get the main dataset and this set of parameters into the same workspace. Swap back to the main dataset
use "....\Small_var_dataset.dta"
//then add a new time variable called end to the main dataset, so that you can merge easily
gen end=newt
tsset end, quarterly
merge 1:1 end using var1
//you should see the parameters for the estimation ending in 2006q4 are added to the variables on line 192 of the dataset. 

//in this example I am going to forecast inflation

//for the 1-step forecast we can use the fact stata at this level works with variables rather than matrices to our advantage and 'gen' some forecasts
gen infl_F1= infl_b_cons + _stat_8*dgdp + _stat_10*infl + _stat_12*dtbill +_stat_9*l.dgdp +_stat_11*l.infl + _stat_13*l.dtbill


//to check our work set up a couple of estimations on the first two samples and estimate 1-step forecasts using the standard commands. 
var dgdp infl dtbill if tin(1959q3,2006q4), lags(1/2)
//compute 1 step ahead dynamic forecast for this estimation sample, no standard errors
fcast compute _var_06q4, nose
// now do the same thing for the next period so we have two inbuilt forecasts for checking our work
var dgdp infl dtbill if tin(1959q3,2007q1), lags(1/2)
fcast compute _var_07q1, nose
//inspect your data and you will see the forecasts. Notice that stata lines the forecast up against the outcome; preceeded by the fitted value in the forecast period. You can see the 1-step ahead inflation forecasts are the same, but the ones we made with rolling line up on information-date, not outcome-date. We can make our forecasts line up with outcomes using the lag operator
gen infl_F11=l.infl_F1

//It should now be easy to compute MSFE etc. 


