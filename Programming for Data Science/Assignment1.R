#question1
#merge algorithm
merge <- function(x,y){
  x<-c(x,Inf)
  y<-c(y,Inf)
  i=1
  j=1
  z<-c() #ordered array containing elements from x and y
  for (k in 1:(length(x)+length(y)-2)){
    if(x[i]<=y[j]){
      z[k]<-x[i]
      i<-i+1
    }else{
      z[k]<-y[j]
      j<-j+1
    }
  }
  z
}

#mergesort algorithm
mergesort <- function(x){
  if(length(x)>1){
    q<-ceiling(length(x)/2) #deal with the case when length(x) is odd
    a<-mergesort(x[1:q])
    b<-mergesort(x[(q+1):length(x)])
    merge(a,b)
  }else{
    x
  }
}



#question2
#majority element problem
 majority <- function(a){
  if(length(a) == 1){
    return(a[1])
    break()
  }
  if(length(a) > 1){
  half = length(a)/2
  left = majority(a[1:half])
  right = majority(a[(half+1):length(a)])
  if(left==right){
    return(left)
    }
  if(sum(a==left) > half){
    return(left)
    }
  if(sum(a==right) > half){
    return(right)
   }
  else{
    return("No majority")
  }
  }
}


#question3
#compress the nightingale picture
load("pictures.rdata") 
source("svd.image.compression.R")

img <- images[[4]] # saying that we're only interested in the Nightingale picture 
dims <- dim(img); m <- dims[1]; n <- dims[2]  #getting dimension of Nightingale. It should be m*n=767*584
if (length(dims) > 2) {
  # convert the image into greyscale (this is our matrix A)
  mtx <- matrix(0,m,n)
  for (i in 1:m) {
    for (j in 1:n) {
      mtx[i,j] <- sum(img[i,j,])/3
    }
  }
} else {
  mtx <- img
}

#define the function we are trying to minimise. This does not depend on B!
obj.fun<-function(k){
  decomposition<-svd(mtx)
  f.norm<-sqrt(sum(decomposition$d[(k+1):n]^2))
  return(exp(f.norm)+ k*(m+n+1))
}

#find the optimal value of k that minimises the objective function
optimise(obj.fun, interval=c(1,n))
#k<-c()
#for(i in 1:n){
#  k[i]<-obj.fun(i)
#}
#which.min(k)
