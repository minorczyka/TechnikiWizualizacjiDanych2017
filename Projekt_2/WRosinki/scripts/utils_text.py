
import itertools
import random
import re

import nltk
import numpy as np
import pandas as pd
import sklearn
from gensim import corpora
from gensim.models import KeyedVectors
from keras.preprocessing.text import Tokenizer
from nltk import ngrams, word_tokenize
from nltk.corpus import stopwords
from nltk.stem import *
from nltk.tag import AffixTagger
from scipy.spatial import distance
from scipy.stats import boxcox
from sklearn.feature_extraction import FeatureHasher
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.preprocessing import (MinMaxScaler, Normalizer,
                                   PolynomialFeatures, StandardScaler)

seed = 1337

stemmer = snowball.SnowballStemmer('english')
lemmatizer = WordNetLemmatizer()
stopwords_eng = stopwords.words('english')
words = re.compile(r"\w+", re.I)


def row_statistics_others(df2):
    df = df2.copy()
    df['zeros'] = np.sum(df == 0, axis=1)
    df['non-zeros'] = np.sum(df == 0, axis=1)
    df['NaNs'] = np.sum(np.isnan(df), axis=1)
    df['negatives'] = np.sum(df < 0, axis=1)
    df['sum_row'] = df.sum(axis=1)
    df['mean_row'] = df.mean(axis=1)
    df['std_row'] = df.std(axis=1)
    df['max_row'] = np.amax(df, axis=1)
    return df


def interactions_others(df2):
    df = df2.copy()
    cols = df2.columns
    for comb in itertools.combinations(cols, 2):
        feat = comb[0] + "_plus_" + comb[1]
        # addition can be changed to any other interaction like subtraction, multiplication, division
        df[feat] = df[comb[0]] + df[comb[1]]
    return df


def target_engineering_others(df2):
    df = df2.copy()
    df['target'] = np.log(df['target'])  # log-transform
    df['target'] = (df['target'] ** 0.25) + 1
    df['target'] = df['target'] ** 2  # square-transform
    df['target'], _ = boxcox(df['target'])  # Box-Cox transform

    # Bin target variable in case of regression
    target_range = np.arange(0, np.max(df['target']), 100)
    df['target'] = np.digitize(df.target.values, bins=target_range)
    return df


# Vol 4 - Text

# Cleaning


def lowercase(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].str.lower()
    return df


def unidecode(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].str.encode('ascii', 'ignore')
    return df


def remove_nonalpha(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].str.replace('\W+', ' ')
    return df


def repair_words(df2):
    # https://www.analyticsvidhya.com/blog/2014/11/text-data-cleaning-steps-python/
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: (''.join(''.join(s)[:2]
                                               for _, s in itertools.groupby(x))))
    return df

# Tokenizing


def tokenize(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: word_tokenize(x))
    return df


def ngram(df2, n):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [i for i in ngrams(word_tokenize(x), n)])
    return df


def skipgram(df2, ngram_n, skip_n):
    def random_sample(words_list, skip_n):
        return [words_list[i] for i in sorted(random.sample(range(len(words_list)), skip_n))]

    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(
            lambda x: [i for i in ngrams(word_tokenize(x), ngram_n)])
        df[i] = df[i].apply(lambda x: random_sample(x, skip_n))
    return df


def chargram(df2, n):
    # http://stackoverflow.com/questions/18658106/quick-implementation-of-character-n-grams-using-python
    def chargram_generate(string, n):
        return [string[i:i + n] for i in range(len(string) - n + 1)]
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [i for i in chargram_generate(x, 3)])
    return df

# Removing


def remove_stops(df2, stopwords):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(
            lambda x: [i for i in word_tokenize(x) if i not in stopwords])
    return df


def remove_extremes(df2, stopwords, min_count=3, max_frequency=0.75):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(
            lambda x: [i for i in word_tokenize(x) if i not in stopwords])
    tokenized = []
    for i in text_feats:
        tokenized += df[i].tolist()
    dictionary = corpora.Dictionary(tokenized)
    dictionary.filter_extremes(no_below=min_count, no_above=max_frequency)
    dictionary.compactify()
    df = df2.copy()
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [i for i in word_tokenize(x) if i not in stopwords and i not in
                                       list(dictionary.token2id.keys())])
    return df

# Roots


def chop(df2, n):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [i[:n] for i in word_tokenize(x)])
    return df


def stem(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [stemmer.stem(i)
                                       for i in word_tokenize(x)])
    return df


def lemmat(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: [lemmatizer.lemmatize(i)
                                       for i in word_tokenize(x)])
    return df

# Enriching


def extract_entity(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i in text_feats:
        df[i] = df[i].apply(lambda x: word_tokenize(x))
        df[i] = df[i].apply(lambda x: nltk.pos_tag(x))
        df[i] = df[i].apply(lambda x: [i[1:] for i in x])
    return df


def doc_features(df2):
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    for i, col in enumerate(text_feats):
        df['num_characters_{}'.format(i)] = df[col].map(
            lambda x: len(str(x)))  # length of sentence
        df['num_words_{}'.format(i)] = df[col].map(
            lambda x: len(str(x).split()))  # number of words
        df['num_spaces_{}'.format(i)] = df[col].map(lambda x: x.count(' '))
        df['num_alpha_{}'.format(i)] = df[col].apply(
            lambda x: sum(i.isalpha()for i in x))
        df['num_nonalpha_{}'.format(i)] = df[col].apply(
            lambda x: sum(1 - i.isalpha()for i in x))
    return df

# Similarities & transformations


def token_similarity(df2):

    # https://www.kaggle.com/the1owl/quora-question-pairs/matching-que-for-quora-end-to-end-0-33719-pb
    def word_match_share(row, col1, col2, stopwords):
        q1words = {}
        q2words = {}
        for word in str(row[col1]).lower().split():
            if word not in stopwords:
                q1words[word] = 1
        for word in str(row[col2]).lower().split():
            if word not in stopwords:
                q2words[word] = 1
        if len(q1words) == 0 or len(q2words) == 0:
            return 0
        shared_words_in_q1 = [w for w in q1words.keys() if w in q2words]
        shared_words_in_q2 = [w for w in q2words.keys() if w in q1words]
        R = (len(shared_words_in_q1) + len(shared_words_in_q2)) / \
            (len(q1words) + len(q2words))
        return R

    df = df2.copy()
    df['word_match_share'] = df.apply(lambda x: word_match_share(x, 'question1', 'question2', stopwords_eng),
                                      axis=1, raw=True)
    return df


def bag_of_words(df2):
    df = df2.copy()
    cv = CountVectorizer()
    bow = cv.fit_transform(df.text).toarray()
    return pd.DataFrame(bow, columns=cv.get_feature_names())


def tf_idf(df2):
    df = df2.copy()
    tf = TfidfVectorizer()
    tfidf = tf.fit_transform(df.text).toarray()
    return pd.DataFrame(tfidf, columns=tf.get_feature_names())


def PCA_text(df2, ndims):
    df = df2.copy()
    bow = CountVectorizer().fit_transform(df.text
                                          ).toarray()
    pca_bow = PCA(ndims, random_state=seed).fit_transform(bow)
    return pd.DataFrame(pca_bow)


def SVD_text(df2, ndims):
    df = df2.copy()
    bow = CountVectorizer().fit_transform(df.text)
    svd_bow = TruncatedSVD(ndims, random_state=seed).fit_transform(bow)
    return pd.DataFrame(svd_bow)


def LDA_text(df2, ntopics):
    df = df2.copy()
    bow = CountVectorizer().fit_transform(df.text)
    lda_bow = LatentDirichletAllocation(
        ntopics, random_state=seed).fit_transform(bow)
    return pd.DataFrame(lda_bow)


def LDA_text2(df2, ntopics):
    cv = CountVectorizer(stop_words='english', min_df=1, max_df=0.999)
    lda = LatentDirichletAllocation(ntopics, random_state=seed, n_jobs=1)
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    cv.fit(df.text)
    bow = cv.transform(df.text)
    lda.fit(bow)
    ldas = []
    for i in text_feats:
        bow_i = cv.transform(df[i])
        ldas.append(pd.DataFrame(lda.transform(bow_i), index=df[i]))
    return ldas


def LSA_text(df2, ndims):
    cv = CountVectorizer(stop_words='english', min_df=1, max_df=0.999)
    svd = TruncatedSVD(ndims, random_state=1337)
    normalizer = Normalizer(copy=False)
    df = df2.copy()
    text_feats = df.select_dtypes(include=['object']).columns.values
    cv.fit(df.text)
    bow = cv.transform(df.text)
    svd.fit(bow)
    transformed_bow = svd.transform(bow)
    normed_bow = normalizer.fit(transformed_bow)
    svds = []
    for i in text_feats:
        bow_i = cv.transform(df[i])
        svd_i = svd.transform(bow_i)
        normed_i = pd.DataFrame(normalizer.transform(svd_i), index=df[i])
        svds.append(normed_i)
    return svds
