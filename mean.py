# -*- coding: utf-8 -*-
"""
Created on Sun Aug 28 10:22:26 2016

@author: Ryo
"""
import time
start_time = time.time()
process_time = time.time() - start_time

import os
wd='C:'
os.chdir(wd)

import numpy as np
import pandas as pd

#糖尿病データセットを読み込む
from sklearn.datasets import load_diabetes
diabetes = load_diabetes().data#ndarray型(ディクショナリ{'data':ndarray型}という形式のデータセット)

#次元数D
D=len(diabetes[0])
#データ数(観測値の数)N
N=len(diabetes)

print(diabetes.nbytes,'bytes')

#列名(map:MeanAorticPressure)
columns=['age','sex','bmi','map','tc','ldl','hdl','tch','ltg','glu']

X = np.matrix(diabetes[:,:D-1])
t = diabetes[:,D-1]


#2.3.5逐次推定
#実行時間が早い．メモリ消費が少ない
N_1 = 999
X = np.random.randn(N_1)#標準正規乱数

mu_ML_N_1 = X.mean()

N = N_1 + 1
x_N = np.random.randn()


start_clock = time.clock()
mu_ML_N = mu_ML_N_1 + (x_N - mu_ML_N_1)/N
process_clock1 = time.clock() - start_clock

np.append(X,x_N)

start_clock = time.clock()
mu_ML_N = 0
for n in list(X):
    mu_ML_N += n
mu_ML_N = mu_ML_N/N
process_clock2 = time.clock() - start_clock

start_clock = time.clock()
mu_ML_N = X.mean()
process_clock3 = time.clock() - start_clock
