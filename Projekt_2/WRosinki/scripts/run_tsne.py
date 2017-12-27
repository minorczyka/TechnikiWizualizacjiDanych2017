import itertools
import time
from argparse import ArgumentParser

import bokeh
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from bokeh import palettes
from bokeh.embed import file_html
from bokeh.io import output_notebook, show
from bokeh.models import (ColorBar, ColumnDataSource, HoverTool, LabelSet,
                          LinearColorMapper, mappers)
from bokeh.palettes import Viridis256
from bokeh.plotting import figure, save
from bokeh.resources import CDN
from bokeh.sampledata.autompg import autompg
from bokeh.transform import factor_cmap
from nltk.corpus import stopwords
from utils_lotr import *

parser = ArgumentParser()
parser.add_argument("--topics",
                    help="Number of topics.",
                    type=int, default=15)
parser.add_argument("--perplexity",
                    help="t-SNE perplexity parameter.",
                    type=int, default=20)
parser.add_argument("--threshold",
                    help="LDA confidence threshold parameter.",
                    type=float, default=0.5)
args = parser.parse_args()
print('\nRunning with parameters: {}\n'.format(args))


n_top_words = 7
n_topics = args.topics
n_iter = 500
tsne_components = 2
tsne_perplexity = args.perplexity
threshold = args.threshold

vect_mode = 'Count'
transform_mode = 'LDA'
threshold_confidence = True


scrape = False
save_subsets = False
base_url = 'http://www.tk421.net/lotr/film/'


cv_params = {
    'stop_words': 'english',
    'min_df': 2,
    'max_df': 0.9,
    'ngram_range': (1, 3),
    'analyzer': 'word',
}

stops = set(stopwords.words('english'))

script_subsets = scrape_lotr(base_url, scrape, save_subsets)
df = clean_transcript(script_subsets)
df.drop_duplicates(['text'], inplace=True)

df = lowercase(df)
df = remove_stops(df, stops)
df['text'] = df.text.apply(lambda x: ' '.join(x))
df['character'] = df.character.apply(lambda x: ' '.join(x))

df_interactions, interact_matrix = get_interactions_df(df)


X_topics, reducer, cv = transform_text_data(df, n_topics, cv_params,
                                            vect_mode=vect_mode,
                                            transform_mode=transform_mode)

if threshold_confidence:
    idx_max = np.amax(X_topics, axis=1) > threshold
    X_topics = X_topics[idx_max]


tsne_model = TSNE(n_components=tsne_components, verbose=1, random_state=1337,
                  perplexity=tsne_perplexity, angle=.2, init='pca')
tsne_lda = tsne_model.fit_transform(X_topics)


colormap = np.array([
    "#1f77b4", "#aec7e8", "#ff7f0e", "#ffbb78", "#2ca02c",
    "#98df8a", "#d62728", "#ff9896", "#9467bd", "#c5b0d5",
    "#8c564b", "#c49c94", "#e377c2", "#f7b6d2", "#7f7f7f",
    "#c7c7c7", "#bcbd22", "#dbdb8d", "#17becf", "#9edae5"])


lda_keys = []
for i in range(X_topics.shape[0]):
    lda_keys.append(X_topics[i, :].argmax())

topic_summaries = []
topic_word = reducer.components_  # all topic words
vocab = cv.get_feature_names()
for i, topic_dist in enumerate(topic_word):
    topic_words = np.array(vocab)[np.argsort(
        topic_dist)][:-(n_top_words + 1):-1]  # get!
    topic_summaries.append(' '.join(topic_words))  # append!
print(topic_summaries)


dfb = pd.DataFrame()
dfb['content'] = df[idx_max].text.values.tolist()
dfb['topic_key'] = np.array(lda_keys)
dfb['X_tsne'] = tsne_lda[:, 0]
dfb['Y_tsne'] = tsne_lda[:, 1]


source = ColumnDataSource(dfb)
color_mapper = mappers.LinearColorMapper(
    palette=palettes.Category20_20, low=dfb.topic_key.min(), high=dfb.topic_key.max())


p = figure(plot_width=1200, plot_height=1000,
           title='t-SNE Lord of the Rings Topics',
           x_axis_label='X-coord', y_axis_label='Y-coord',
           tools="pan,wheel_zoom,box_zoom,reset,hover,previewsave", toolbar_location='above',
           min_border=1)
p.scatter(x='X_tsne', y='Y_tsne', color={'field': 'topic_key',
                                         'transform': color_mapper}, size=7, alpha=0.5, source=source)
p.title.text_font_size = '15pt'
p.xaxis.major_label_text_font_size = '0pt'
p.yaxis.major_label_text_font_size = '0pt'


topic_coord = np.empty((X_topics.shape[1], 2)) * np.nan
for topic_num in lda_keys:
    if not np.isnan(topic_coord).any():
        break
    topic_coord[topic_num] = tsne_lda[lda_keys.index(topic_num)]
for i in range(X_topics.shape[1]):
    p.text(topic_coord[i, 0], topic_coord[i, 1], [topic_summaries[i]],
           text_font_size='11pt', text_align='center',
           text_baseline='middle')

hover = p.select(dict(type=HoverTool))
hover.tooltips = {"Text": "@content - topic: @topic_key"}

bokeh.plotting.save(p, 'tSNE_topics{}_perplexity{}_threshold{}.html'.format(
    n_topics, tsne_perplexity, threshold))


html = file_html(p, CDN, "tSNE_lotr")
print(html)
