#install.packages("foreach")
#install.packages("doMC")

library("foreach")
library(doMC)

df<-data.frame("a"=c(1,3,5),"b"=c(2,4,6))

X<-function(x){
  return(x*x)
}

# A basic, nonparallel, foreach loop looks like this:
result<-foreach (n = 1:nrow(df), .combine=rbind) %do% {
  X(n)
}
result

# loop in parallel
registerDoMC(2)
result2<-foreach (n = 1:nrow(df), .combine=rbind) %dopar% {
  X(n)
}
result2







