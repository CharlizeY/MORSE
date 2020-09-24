## Problem 1: Multiples of 3 and 5
#Find the sum of all the multiples of 3 or 5 below 1000
TotalSum <- 0
for (i in 1:999){
if (i%%3==0 | i%%5==0)
TotalSum<-TotalSum+i
}
print(TotalSum)


## Problem 2: Even Fibonacci numbers
#find the sum of the even-valued terms in the Fibonacci sequence whose values do not exceed four million
fibonacci <- numeric()
fibonacci[1] <- 1
fibonacci[2] <- 2
i <- 3
repeat {
  fibonacci[i] <- fibonacci[i-1] + fibonacci[i-2]
  if (fibonacci[i] > 4e6) break
  i <- i + 1
}
# calculate the sum
fibonacci <- fibonacci[-length(fibonacci)]   # remove the last term
flag <- fibonacci %% 2 == 0  # find the indexes of even numbers
result <- sum(fibonacci[flag])
cat("The result is:", result, "\n")


## Problem 3: Largest prime factor
#find the largest prime factor of the number 600851475143
install.packages("numbers")
library(numbers)
max(primeFactors(600851475143))


## Problem 4: Largest palindrome product
#a palindromic number reads the same both ways 
#find the largest palindrome made from the product of two 3-digit numbers
is.palindromic <- function(x) {
  x <- as.character(x)
  forward <- unlist(strsplit(x, split = ""))
  reverse <- rev(forward)
  flag <- all(forward == reverse)
  return(flag)
}
# calculate the all the products of 900:999 in a 100*100 matrix
mat <- matrix(900:999, nrow = 1)
mat <- t(mat) %*% (mat)
candidate <- as.vector(mat)
candidate <- unique(sort(candidate, decreasing = T))
# pick the largest palindrome
pali.max <- 0
i <- 1
n <- length(candidate)
while (i <= n) {
  if (is.palindromic(candidate[i])) {
    pali.max <- candidate[i]
  }
  i <- i + 1
}
cat("The result is:", pali.max, "\n")


## Problem 5: Smallest multiple
#find the smallest positive number that is evenly divisible by all of the numbers from 1 to 20
small.composite<-function(n){
  composite<-1
  for (i in 1:n){
    remainder<-(composite%%i)
    if(remainder!=0){
      if(i%%remainder==0){
        composite<-composite*i/remainder
      }
      else{
        composite<-composite*i
      }
    }
  }
return(composite)
}
cat("The result is:", small.composite(20), "\n")


## Problem 6: Sum square difference
#find the difference between the sum of the squares of the first one hundred 
natural numbers and the square of the sum.
sum1<-0
for(i in 1:100){
  sum1<-sum1+i^2
}
print(sum1)

sum2<-sum(1:100)^2
print(sum2)

Diff<-sum1-sum2
print(Diff)


## Problem 7: 10001st prime
#find the 10001st prime number

n <- 10001
prime.seq <- numeric(n)
prime.seq[1:2] <- c(2, 3)
candidate <- prime.seq[2] + 2
# test whether an odd number is a prime
for (i in 3: n) {
  while (any(candidate %% prime.seq[1:(i - 1)] == 0)) {
    candidate <- candidate + 2
  }
  prime.seq[i] <- candidate
  candidate <- candidate + 2
}
cat("The result is:", prime.seq[n], "\n")
