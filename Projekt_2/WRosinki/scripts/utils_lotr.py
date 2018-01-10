import itertools
import time

import numpy as np
import pandas as pd
import requests
import seaborn as sns
from bs4 import BeautifulSoup
from sklearn.decomposition import LatentDirichletAllocation, TruncatedSVD
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.manifold import TSNE
from utils_text import *


def scrape_lotr(base_url, scrape=False, save=False):
    start_time = time.time()
    r = requests.get(base_url)
    data = r.content
    soup = BeautifulSoup(data, 'lxml')
    parts = []
    for link in soup.find_all('a'):
        parts.append(link.get('href'))
    parts = parts[:-1]
    if scrape:
        script_subsets = []
        for i in parts:
            r_part = requests.get(base_url + i)
            data_part = r_part.content
            soup_part = BeautifulSoup(data_part, 'lxml')
            for link in soup_part.find_all('p'):
                if len(link.get_text()) == 0:
                    pass
                else:
                    script_subsets.append(link.get_text())
        if save:
            pd.to_pickle(script_subsets, 'script_subsets.pkl')
    else:
        script_subsets = pd.read_pickle('script_subsets.pkl')
    print('LoTR transcripts scraped, time it took: {:.3f}'.format(
        time.time() - start_time))
    return script_subsets


def clean_transcript(script_subsets):
    start_time = time.time()
    df = pd.DataFrame(script_subsets)
    df.columns = ['text']
    df = repair_words(df)
    df['character'] = df.apply(lambda x: x['text'].split(':')[0], axis=1)
    df['text'] = df.apply(lambda x: x['text'].split(':')[1] if len(x['text'].split(':')) > 1
                          else x['text'].split(':')[0],
                          axis=1)
    df['character'] = df.apply(lambda x: 'Narrator' if x['text'] == x['character']
                               else x['character'], axis=1)

    df['character'] = df.apply(lambda x: x['character'].split("(")[0] if "(" in x['character']
                               else x['character'], axis=1)
    df['character'] = df.character.str.strip()
    df = remove_nonalpha(df)
    df.iloc[1, 0] = df.iloc[2, 0]
    df.drop([2], inplace=True)
    df = df[df.character != 'Lord of the Rings']
    return df


def get_network_interactions_df(df):
    start_time = time.time()
    chars = df.character.unique().tolist()
    chars = [x for x in chars if len(x) > 0]

    dfc = df.copy()
    dfc['target'] = 'None'
    for i in range(df.shape[0]):
        text_row = df.iloc[i, 0]
        char_row = df.iloc[i, 1]
        for char in chars:
            if char in text_row:
                dfc.iloc[i, 2] += '_{}'.format(char)
    dfc['targets'] = dfc.apply(lambda x: x['target'].split('_')[1:], axis=1)
    dfc = dfc[dfc['target'] != 'None']
    dfc['target'] = dfc.apply(lambda x: x['targets'][0], axis=1)
    return dfc


def get_interactions_df(df):
    start_time = time.time()
    chars = df.character.unique().tolist()
    chars = [x for x in chars if len(x) > 0]
    interactions_matrix = pd.DataFrame(np.zeros((len(chars), len(chars))))
    interactions_matrix.index = chars
    interactions_matrix.columns = chars
    for i in range(df.shape[0]):
        text_row = df.iloc[i, 0]
        char_row = df.iloc[i, 1]
        for char in chars:
            if char in text_row:
                interactions_matrix.loc[char_row, char] += 1

    df_interactions = pd.DataFrame()
    df_interactions['characters'] = ''
    df_interactions['num_interactions'] = 0
    for comb in itertools.combinations(chars, 2):
        char_interact = comb[0] + "_" + comb[1]
        inter_oneside = interactions_matrix.loc[comb[0], comb[1]]
        inter_secondside = interactions_matrix.loc[comb[1], comb[0]]
        df_interactions.loc[char_interact, 'characters'] = char_interact
        df_interactions.loc[char_interact,
                            'num_interactions'] = inter_oneside + inter_secondside
    df_interactions = df_interactions[df_interactions['num_interactions'] > 0]
    print('Interactions computed, time it took: {:.3f}'.format(
        time.time() - start_time))
    return df_interactions, interactions_matrix


def transform_text_data(df2, n_dims, vect_params,
                        vect_mode='Tfidf',
                        transform_mode='LDA'):
    start_time = time.time()
    df = df2.copy()
    if vect_mode == 'Tfidf':
        cv = TfidfVectorizer(vect_params)
    else:
        cv = CountVectorizer(vect_params)
    bow = cv.fit_transform(df.text)
    if transform_mode == 'LDA':
        lda = LatentDirichletAllocation(n_topics=n_dims, random_state=1337)
        X_topics = lda.fit_transform(bow)
        print('LDA transformation done, time it took: {:.3f}'.format(
            time.time() - start_time))
        return X_topics, lda, cv
    if transform_mode == 'LSA':
        svd = TruncatedSVD(n_dims, random_state=1337)
        normalizer = Normalizer(copy=False)
        transformed_bow = svd.fit_transform(bow)
        X_topics = normalizer.fit_transform(transformed_bow)
        print('LSA transformation done, time it took: {:.3f}'.format(
            time.time() - start_time))
        return X_topics, svd, cv
