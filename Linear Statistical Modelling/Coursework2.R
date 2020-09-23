#question1
data1 <- read.csv("2019A2Q1.csv")
lm1 <- lm(formula = Time ~ Location)
lm2 <- lm(formula = Time ~ 0 + Team + Location)
summary(lm2)

#compare models and calculate F statistics using the ANOVA function
anova(lm1,lm2)


#question2
lm_1 <- lm(formula = ST115 ~ .)
summary(lm_1)
sum(residuals(lm_1)^2)/(100-5)

#select the best univariate model by looking at deviance and R^2
summary(lm(formula = ST115 ~ EC106)
summary(lm(formula = ST115 ~ IB104)
summary(lm(formula = ST115 ~ MA137)
summary(lm(formula = ST115 ~ MA106)

#equivalently use the 'Best Subset Selection' to find the best model
#library(leaps)
#summary(regsubsets(ST115 ~ .,data = `2019A2Q2`,nvmax=3))

#best bivariate model
lm_3 <- lm(formula = ST115 ~ EC106 + MA137)
summary(lm_3)

#best trivariate model 
summary(lm(formula = ST115 ~ EC106 + IB104 + MA137)

#calculate R^2,adj R^2,Mallow Cp to find the best model
x <- as.matrix(`2019A2Q2`[1:4])
y <- as.matrix(`2019A2Q2`[5])
leaps(x,y,method=c("Cp")

#prediction
predict(lm_3,newdata=list(EC106=45,IB104=47,ma137=50,MA106=54)
