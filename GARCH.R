#GARCH
#setwd("C:/win32/Sourcecode")#setwd("C:/work")
#収益率ファイルの読み込み
ret<-read.table("6Portdai_VAR1_L0w1T250ret",header=F,sep=",",nrows=-1)
#ret<-read.table("25Portdai_ret.csv",header=F,sep=",",nrows=-1)
#期待収益率またはパラメータの読み込み
hat<-read.table("6Portdai_VAR1_L0w1T250par.csv",header=F,sep=",",nrows=-1)
#hat<-read.table("25Portdai_VAR1_L0w1T250_par.csv",header=F,sep=",",nrows=-1)
#header=F：1行目に列名が書かれていない。nrows=行目まで読み込む、マイナスの時すべて。skip=tau-1読み飛ばす Rは1から(pythonは0から)

ndim =dim(ret)[2]#資産数
nobs =250-1#学習期間数

#GARCHの予測するパラメータ初期値
a <- c(0.002,0.002,0.002,0.002,0.002,0.002)
A <- diag(c(0.2,0.2,0.2,0.2,0.2,0.2))
B <- diag(c(0.7,0.7,0.7,0.7,0.7,0.7))
ini.dcc <- c(0.2,0.2)
#残差を求める
for (tau in 1:2) { #250
  dvar = c()
  for (t in 1:nobs) {
    er <- as.numeric(ret[tau+nobs+1-t,])
          -colSums(matrix(as.numeric(hat[tau,])*c(1,as.numeric(ret[tau+nobs+2-t,])),ndim+1,ndim))
    dvar <- rbind(dvar,er)  
  }
  #as.numeric()ベクトル化。matrix(,行数,列数)行列化。colSums()列の総和
  In <- diag(ndim)
  #ファーストステージGARCHパラメータ推定
  first.stage <- dcc.estimation1(dvar = dvar, a = a, A = A, 
                                 B = B, model = "diagonal", method = "BFGS")
  if (first.stage$convergence != 0) {
    cat("* The first stage optimization has failed.    *\n")
    cat("* See the list variable 'second' for details. *\n")
  }
    
  tmp.para <- c(first.stage$par, In[lower.tri(In)])
  estimates <- p.mat(tmp.para, model = "diagonal", ndim = ndim)
  esta <- estimates$a
  estA <- estimates$A
  estB <- estimates$B
  h <- vector.garch(dvar, esta, estA, estB)
  std.resid <- dvar/sqrt(h)
  #予測
  h_t <-esta+diag(estA)*as.numeric(dvar[nobs,])*as.numeric(dvar[nobs,])+diag(estB)*as.numeric(h[nobs,])
  
  #セカンドステージDCCパラメータ推定
  second.stage <- dcc.estimation2(std.resid, ini.dcc, gradient = 1)
  if (second.stage$convergence != 0) {
    cat("* The second stage optimization has failed.   *\n")
    cat("* See the list variable 'second' for details. *\n")
  }
  
  dccpar <- second.stage$par
  q <- dcc.est(std.resid, second.stage$par)$Q
  q_t <- as.numeric(dccpar[1])*c(std.resid[nobs,])%*%t(c(std.resid[nobs,]))+(as.numeric(dccpar[2])+1)*matrix(c(q[nobs,]),ndim,ndim)-as.numeric(dccpar[1])*c(std.resid[(nobs-1),])%*%t(c(std.resid[(nobs-1),]))-as.numeric(dccpar[2])*matrix(c(q[(nobs-1),]),ndim,ndim)
  hij <- sqrt(diag(h_t))%*%diag((1/sqrt(diag(q_t))))%*%q_t%*%diag((1/sqrt(diag(q_t))))%*%sqrt(diag(h_t))
  H <- t(c(hij))
  write.table(H, "25Portdai_VAR1_L0w1T250_DCC.csv", quote=F, col.names=F, sep=',',append=T)
}
