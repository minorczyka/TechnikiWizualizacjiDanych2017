
# coding: utf-8

# In[2]:


import gc
import glob
import os

import numpy as np
import pandas as pd

import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')

import utils
import utils_fe
from gbm_pipeline import GBMPipeline
from tqdm import tqdm


# In[7]:


X = pd.read_pickle('../data/train_full_months.pkl')
X_test = pd.read_pickle('../data/test_lag_months.pkl')

assert(X.shape[1] == X_test.shape[1])

data = pd.concat([X, X_test], axis=0)
print(X.shape, X_test.shape, data.shape)


print('Number of intersecting customers:', len(np.intersect1d(X.customer_id, X_test.customer_id)))
print('Number of different customers:', len(np.setdiff1d(X.customer_id, X_test.customer_id)))


# In[3]:


important_feats = ['f_13', 'f_14', 'f_15', 'f_8', 'f_21', 'f_36', 'f_18', 'market',
                    'f_7', 'f_11']


year_mean = utils_fe.group_feat_by_feat(data, 'year', important_feats, 'mean')
year_max = utils_fe.group_feat_by_feat(data, 'year', important_feats, 'max')
year_count = utils_fe.group_feat_by_feat(data, 'year', important_feats, 'count')

month_mean = utils_fe.group_feat_by_feat(data, 'month', important_feats, 'mean')
month_max = utils_fe.group_feat_by_feat(data, 'month', important_feats, 'max')
month_count = utils_fe.group_feat_by_feat(data, 'month', important_feats, 'count')

market_mean = utils_fe.group_feat_by_feat(data, 'market', important_feats, 'mean')
market_max = utils_fe.group_feat_by_feat(data, 'market', important_feats, 'max')
market_count = utils_fe.group_feat_by_feat(data, 'market', important_feats, 'count')

customer_mean = utils_fe.group_feat_by_feat(data, 'customer_id', important_feats, 'mean')
customer_max = utils_fe.group_feat_by_feat(data, 'customer_id', important_feats, 'max')
customer_count = utils_fe.group_feat_by_feat(data, 'customer_id', important_feats, 'count')


# In[4]:


X = X.merge(month_mean, on=['month'], how='left', copy=False)
X = X.merge(month_max, on=['month'], how='left', copy=False)
X = X.merge(month_count, on=['month'], how='left', copy=False)
print('Merging done.')

X = X.merge(year_mean, on=['year'], how='left', copy=False)
X = X.merge(year_max, on=['year'], how='left', copy=False)
X = X.merge(year_count, on=['year'], how='left', copy=False)
print('Merging done.')

X = X.merge(market_mean, on=['market'], how='left', copy=False)
X = X.merge(market_max, on=['market'], how='left', copy=False)
X = X.merge(market_count, on=['market'], how='left', copy=False)

X = X.merge(customer_mean, on=['customer_id'], how='left', copy=False)
X = X.merge(customer_max, on=['customer_id'], how='left', copy=False)
X = X.merge(customer_count, on=['customer_id'], how='left', copy=False)
print('Merging done.')


X_test = X_test.merge(month_mean, on=['month'], how='left', copy=False)
X_test = X_test.merge(month_max, on=['month'], how='left', copy=False)
X_test = X_test.merge(month_count, on=['month'], how='left', copy=False)
print('Test merging done.')

X_test = X_test.merge(year_mean, on=['year'], how='left', copy=False)
X_test = X_test.merge(year_max, on=['year'], how='left', copy=False)
X_test = X_test.merge(year_count, on=['year'], how='left', copy=False)
print('Test merging done.')

X_test = X_test.merge(market_mean, on=['market'], how='left', copy=False)
X_test = X_test.merge(market_max, on=['market'], how='left', copy=False)
X_test = X_test.merge(market_count, on=['market'], how='left', copy=False)

X_test = X_test.merge(customer_mean, on=['customer_id'], how='left', copy=False)
X_test = X_test.merge(customer_max, on=['customer_id'], how='left', copy=False)
X_test = X_test.merge(customer_count, on=['customer_id'], how='left', copy=False)
print('Test merging done.')

from sklearn.preprocessing import StandardScaler, MinMaxScaler

def impute_mean_numerical(df2):
    df = df2.copy()
    numerical_features = df.select_dtypes(include=['number']).columns.values
    for i in numerical_features:
        # impute with mean of each column
        mean = df[i][~np.isnan(df[i])].mean()
        df[i] = df[i].replace(np.nan, mean)
    return df


ss = StandardScaler()
mm = MinMaxScaler()

scale_features = [f for f in data.columns[115:] if data[f].dtype == 'int32']


data[scale_features] = impute_mean_numerical(data[scale_features])
data[scale_features] = ss.fit_transform(data[scale_features].values)

X = data.iloc[:X.shape[0], :]
X_test = data.iloc[X.shape[0]:, :]

print(X.shape, X_test.shape)
# **CPMP drops:**
# 
# features = features.drop(['customer_id', 'target', 'date', 'id', 'f_1', 'f_9', 'f_34', 
#                           'last_market_customer_id', 'mean_market_customer_id'])
#                           
# **My drops:**
# 
# features = features.drop(['customer_id', 'target', 'date', 'id', 'f_10', 'f_30', 
#                           'last_market_customer_id', 'mean_market_customer_id'])
cat_features = [f for f in X.columns if X[f].dtype == 'int32']
num_features = [f for f in X.columns if X[f].dtype == 'float32']
cat_features.remove('date')

for i in X.columns[2:]:
    if X[i].nunique() < 100 and 'month' not in i and 'year' not in i:
        cat_features.append(i)
    print(i, X[i].nunique())
# In[5]:


split_for_validation = True

if split_for_validation:
    X_train = X[(X.date > 6) & (X.date < 10)].reset_index(drop=True)
    X_valid = X[X.date >= 10].reset_index(drop=True)
    print(X_train.shape, X_valid.shape)
else:
    X_train = X[(X.date >= 9)].reset_index(drop=True)
    X_valid = X[X.date >= 10].reset_index(drop=True)
    print(X_train.shape, X_valid.shape)

    
dup_cols = utils_fe.get_duplicate_cols(X_train)
print('Number of columns to drop:', dup_cols)
    
features = X_train.columns
features = features.drop(['customer_id', 'target', 'date', 'id', 'f_10', 'f_30', 
                          'last_market_customer_id', 'mean_market_customer_id'])
features = features.drop(dup_cols)
features_test = features.copy().tolist()
features_test.append('id')

#assert(len(np.setdiff1d(features, features_test))) == 0


del data
gc.collect()


# In[6]:


xgb_params = {
    'objective': 'reg:linear',
    'eta': 0.05,
    'max_depth': 10,
    'min_child_weight': 20,
    'subsample': 0.8,
    'lambda': 0,
    'tree_method': 'hist',
    'nthread': 10,
    'silent': True,
}

lgb_params = {
    'task': 'train',
    'boosting_type': 'gbdt',
    'objective': 'regression',
    'num_leaves': 255,
    'learning_rate': 0.02,
    'max_depth': 10,
    'min_child_weight': 20,
    'subsample': 0.8,
    'reg_lambda': 0,
    'nthread': 10,
}


if split_for_validation:
    
    train_params = {
        'boost_round': 10000,
        'stopping_rounds': 50,
        'verbose_eval': 50,
    }
    
else:
    
    train_params = {
        'boost_round': 2552,
        'stopping_rounds': 50,
        'verbose_eval': 50,
    }

    
pipeline_params = {
    'use_lgb': True,
    'predict_test': True,
    'eval_function': utils.qwk_eval_lgb,
    'seed': 1337,
    'shuffle': True,
    'verbose': True,
    'run_save_name': 'Valid_Seasonality2',
    'save_model': True,
    'save_history': True,
    'save_statistics': True,
    'output_statistics': True,
}


XGB_pipeline = GBMPipeline(
    use_lgb=pipeline_params['use_lgb'],
    predict_test=pipeline_params['predict_test'],
    eval_function=pipeline_params['eval_function'],
    seed=pipeline_params['seed'],
    shuffle=pipeline_params['shuffle'],
    verbose=pipeline_params['verbose'],
    run_save_name=pipeline_params['run_save_name'],
    save_model=pipeline_params['save_model'],
    save_history=pipeline_params['save_history'],
    save_statistics=pipeline_params['save_statistics'],
    output_statistics=pipeline_params['output_statistics'],
)


# In[7]:


if pipeline_params['use_lgb']:

    if pipeline_params['predict_test']:
        val_preds, test_preds, gbm = XGB_pipeline.bag_run(X_train[features], y_train=X_train.target.values,
                                               X_valid=X_valid[features], y_valid=X_valid.target.values,
                                               X_test=X_test[features_test],
                                               model_params=lgb_params,
                                               train_params=train_params,
                                               output_submission=True)
    else:
        val_preds, gbm = XGB_pipeline.bag_run(X_train[features], y_train=X_train.target.values,
                                   X_valid=X_valid[features], y_valid=X_valid.target.values,
                                   model_params=lgb_params,
                                   train_params=train_params)

else:

    if pipeline_params['predict_test']:
        val_preds, test_preds, gbm = XGB_pipeline.bag_run(X_train[features], y_train=X_train.target.values,
                                               X_valid=X_valid[features], y_valid=X_valid.target.values,
                                               X_test=X_test[features_test],
                                               model_params=xgb_params,
                                               train_params=train_params,
                                               output_submission=True)
    else:
        val_preds, gbm = XGB_pipeline.bag_run(X_train[features], y_train=X_train.target.values,
                                   X_valid=X_valid[features], y_valid=X_valid.target.values,
                                   model_params=xgb_params,
                                   train_params=train_params)

utils.save_parameter_dict(
    'checkpoints/{0}/{0}_gbm_parameters.txt'.format(pipeline_params['run_save_name']), xgb_params)
utils.save_parameter_dict('checkpoints/{0}/{0}_train_parameters.txt'.format(
    pipeline_params['run_save_name']), train_params)
utils.save_parameter_dict('checkpoints/{0}/{0}_pipeline_parameters.txt'.format(
    pipeline_params['run_save_name']), pipeline_params)

test_preds, gbm = XGB_pipeline.full_train_run(X_train[features], y_train=X_train.target.values,
                                               X_test=X_test[features_test],
                                               model_params=lgb_params,
                                               train_params=train_params,
                                               output_submission=True)val_preds = pd.read_pickle('preds/valid/Valid_3MonthsLags_GroupCustomer_v2_0.82020.pkl')
test_sub = pd.read_csv('../submissions/raw/FullTrain_3MonthsLags_GroupCustomer_v2_1_raw_QWK_nan.csv')

y_pred = pd.Series(val_preds).clip(0, 20)
y_true = X_valid.target.values
y_test = test_sub.target.clip(0, 20).values


sub_optim, best_qwk = utils.optimize_submission_greedy(y_true, y_pred, y_test, X_test[['id']],
                                            10000, 0.02)

sub_optim.to_csv('../submissions/optimized/{}_GreedyOpt_{:.5f}.csv'.format(pipeline_params['run_save_name'],
                                                                best_qwk), index=False)