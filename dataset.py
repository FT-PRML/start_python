# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd

#%% scikit-learnを使ってarray形式のサンプルデータセットを読み込む
from sklearn.datasets import load_diabetes
diabetes = load_diabetes().data

#%% csvからデータフレーム形式で読み込む
df = pd.read_csv('.csv')

#%% Excelからデータフレーム形式で読み込む
xls = pd.ExcelFile('.xlsx')
df = xls.parse(xls.sheet_names[0],header=0,index_col=0)

