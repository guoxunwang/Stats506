##Stats 506, F18, Problem Set 4, Question 2, Part c
##
##using mclapply to calculate four quantities
##rho=.25,.5,1 respectively
##
##Author: Xun Wang, xunwang@umich.edu
##Updated: December 9,2018- Lasted modified date

#80:--------------------------------------------------------------------------
##Library:--------------------------------------------------------------------
library(parallel)
library(future)

#Source code:-----------------------------------------------------------------
source("ps4_q2_funcs.R")

##read arguments from input:--------------------------------------------------
##default arguments
args_list = list(
  n_cores=1,
  mc_rep=1e4,
  sigma=1
)

##get parameters from command line
args = commandArgs(trailingOnly = TRUE)

##functions for finding named arguments
args_to_list = function(args){
  ind = grep('=', args)  
  args_list = strsplit(args[ind], '=')
  names(args_list) = sapply(args_list, function(x) x[1])
  
  args_list = lapply(args_list, function(x) as.numeric(x[2]))
  args_list
}

##get named arguments
args_list_in=args_to_list(args)

##update non default arguments
ignored = c()
for (arg in names(args_list_in)) {
  ##Check for unknown argument
  if (is.null(args_list[[arg]])) {
    ignored = c(ignored, arg)
  }else{
   ##update if known
    args_list[[arg]]=args_list_in[[arg]]
  }
}

##Part c:---------------------------------------------------------------------
n=1000; p=100
beta=c(rep(.1,10), rep(0,p-10)) 
dim(beta)=c(p, 1)

X_0=matrix(rnorm(n*p),n,p)
sigma_beta=function(i){
  M=beta%*%t(beta)*i*.25
  diag(M)=c(rep(1,p))
  X_0%*%chol(M)}

##generate X for this function
plan(multisession)
X=list()
for(i in 1:7){
  X[[i]]=future(sigma_beta(i-4))
}
X=with(args_list,mclapply(X, value,mc.cores=n_cores))

##compute p-values matrices
multi_comparison=function(i,n_cores,mc_rep,sigma){
  pvalue=sim_beta(X[[i]],beta=beta,sigma=sigma,mc_rep=mc_rep)
  m_adjust=mclapply(c('holm', 'bonferroni', 'BH', 'BY'),function(x){
    cbind(rho=0.25*(i-4),sigma=sigma,method=x,
          evaluate(apply(pvalue,2,p.adjust,method=x),tp_ind = 1:10))},mc.cores=n_cores)
  do.call(rbind,m_adjust)
}

plan(multisession)
results_q4c=list()
for(i in 1:7){
  results_q4c[[i]]=with(args_list,future(multi_comparison(i,
                   n_cores=n_cores,mc_rep=mc_rep,sigma=sigma)))
}
results_q4c=with(args_list,mclapply(results_q4c,value,mc.cores=n_cores))
results_q4c=do.call(rbind,results_q4c)
print(results_q4c)

#80:--------------------------------------------------------------------------
