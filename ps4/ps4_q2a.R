##Stats 506, F18, Problem Set 4, Question 2, Part a
##
##using mclapply to calculate four quantities
##
##Author: Xun Wang, xunwang@umich.edu
##Updated: December 8,2018- Lasted modified date

#80:--------------------------------------------------------------------------
##Library:--------------------------------------------------------------------
library(parallel)

#Source code:-----------------------------------------------------------------
source("ps4_q2_funcs.R")

##Part a
n=1000; p=100
beta=c(rep(.1,10), rep(0,p-10)) 
dim(beta)=c(p, 1)

##generate X for this function
X_0=matrix(rnorm(n*p),n,p)
sigma_beta=function(i){
  M=beta%*%t(beta)*i*.25
  diag(M)=c(rep(1,p))
  X_0%*%chol(M)}
X=mclapply(-3:3,sigma_beta)

##compute p-values matrices
p_value=mclapply(X,function(x){sim_beta(x,beta=beta,sigma=1,mc_rep=1e4)})

##compute adjusted p-values
multi_comparison=function(i,sigma){
  m_adjust=mclapply(c('holm', 'bonferroni', 'BH', 'BY'),function(x){
    cbind(rho=0.25*(i-4),sigma=sigma,method=x,
          evaluate(apply(p_value[[i]],2,p.adjust,method=x),tp_ind = 1:10))})
  do.call(rbind,m_adjust)
}
results_q4a=mclapply(1:7,function(i) {multi_comparison(i,sigma=1)})
results_q4a=do.call(rbind,results_q4a)

#80:--------------------------------------------------------------------------
