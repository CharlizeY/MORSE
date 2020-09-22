#question 1
data1 <- read.csv("courseworkData1.csv")
data1 <- transform(data1, bmi=weight/height^2, whr=waist/hip)

#scatterplot and linear regression (BMI centred around 22)
plot(bodyfat ~ bmi, data=data1, xlab="BMI", ylab="% body fat")
lm1 <- lm(bodyfat ~ I(bmi - 22), data=data1) 
coef1 <- coefficients(lm1)
coef1
predict(lm1, newdata=list(bmi=82/1.78^2))

plot(bodyfat ~ bmi, data=data1, xlab="BMI", ylab="% body fat")
bmi.range <- seq(from=min(data1$bmi), to=max(data1$bmi), length=101)
lines(bmi.range, predict(lm1, newdata=list(bmi=bmi.range)))
#abline(coef(lm1))

#plot by age groups, with a fitted line for each age group
plot(bodyfat ~ bmi, xlab="BMI", ylab="% body fat", data=data1, pch=as.numeric(agegrp), col=agegrp)
legend("topleft", title="Age group", legend = levels(data1$agegrp),pch=1:3, col=1:3)
lm2 <- lm(bodyfat ~ 0 + agegrp + bmi, data=data1) 
age.levels <- levels(data1$agegrp)
for (i in 1:3) {
    lines(bmi.range,predict(lm2, newdata=data.frame(bmi=bmi.range,agegrp=age.levels[i])),col=i,lty=i)
}

#calculate the unbiased estimate of the residual variance
r <- residuals(lm2)
N <- nrow(data1)
p <- length(coefficients(lm2)) 
s2 <- sum(r^2)/(N-p)
s2
#s <- sigma(lm2)
#s2 <- s^2
#s2

#compare with alternative models (residual error and R-square)
lm3 <- lm(bodyfat ~ 0 + agegrp + whr, data=data1)
sigma(lm2)
sigma(lm3)
summary(lm2)$r.squared
summary(lm3)$r.squared



#question2
data2 <- read.csv("courseworkData2.csv")

lm.out1a <- lm(y1 ~ x1, data=data2)
plot(y1 ~ x1, data=data2)
abline(lm.out1a)

#check residual plot (if residuals are correlated)
plot(fitted(lm.out1a), residuals(lm.out1a))

#transform data to correct for correlated residuals
plot(y1 ~ sqrt(x1), data=data2)
lm.out1b <- lm(y1 ~ I(sqrt(x1)), data=data2) 
plot(fitted(lm.out1b), residuals(lm.out1b))

lm.out2a <- lm(y2 ~ x2, data=data2) 
coef2a <- coef(lm.out2a)
coef2a

plot(fitted(lm.out2a), residuals(lm.out2a))

plot(y2 ~ x2, data=data2)

#instead fit a quadratic model and check residual plot again
lm.out2b <- lm(y2 ~ x2 + I(x2^2), data=data2)
plot(fitted(lm.out2b), residuals(lm.out2b))

#try a log transformation of y2
lm.out2c <- lm(log(y2) ~ x2 + I(x2^2), data=data2)
plot(fitted(lm.out2c), residuals(lm.out2c))


