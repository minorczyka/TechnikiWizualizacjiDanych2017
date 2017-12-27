df_inter_highest = df_interactions[df_interactions.num_interactions >= 20].reset_index(
    drop=True).sort_values('num_interactions', ascending=False).reset_index(drop=True)


N = df_inter_highest.characters.nunique()
N2 = df_inter_highest.shape[0]

c = ['hsl(' + str(h) + ',50%' + ',50%)' for h in np.linspace(0, 240, N)]
l = []

colors_df = pd.DataFrame()
colors_df['color'] = c
colors_df['characters'] = df_inter_highest.characters.unique()

df_inter_highest = df_inter_highest.merge(
    colors_df, how='inner', on='characters')


for i in range(N2):
    trace = go.Scatter(
        x=df_inter_highest.characters[i],
        y=df_inter_highest.num_interactions[i],
        mode='markers',
        marker=dict(size=10,
                    color=df_inter_highest.color[i],
                    opacity=0.95,
                    colorscale='Viridis',
                    showscale=False
                    ),
        text=(' & '.join([df_inter_highest.characters[i].split('_')[0],
                          df_inter_highest.characters[i].split('_')[1]]))
    )
    l.append(trace)


layout = go.Layout(
    title='Interactions between characters',
    hovermode='closest',
    xaxis=dict(
        title='Character Pair',
        ticklen=5,
        zeroline=False,
        gridwidth=2,
    ),
    yaxis=dict(
        title='Number of mentions',
        ticklen=5,
        gridwidth=2,
    ),
    showlegend=False,
    autosize=False,
    width=1000,
    height=800,
    margin=go.Margin(
        l=70,
        r=50,
        b=250,
        t=50,
        pad=4
    ),

)


fig = go.Figure(data=l, layout=layout)
py.iplot(fig)
