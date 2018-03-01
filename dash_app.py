import dash
import dash_core_components as dcc
import dash_html_components as html

import colorlover as cl
import datetime as dt
import flask
from flask_cors import CORS
import os
import pandas as pd
from pandas_datareader.data import DataReader
import time

import analizer

app = dash.Dash(
    'stock-tickers',
    url_base_pathname='/dash/gallery/stock-tickers/')
server = app.server
CORS(server)

tickers = analizer.get_all_tickers()

if 'DYNO' in os.environ:
    app.config.routes_pathname_prefix = '/dash/gallery/stock-tickers/'
    app.config.requests_pathname_prefix = 'https://dash-stock-tickers.herokuapp.com/dash/gallery/stock-tickers/'

app.scripts.config.serve_locally = False
dcc._js_dist[0]['external_url'] = 'https://cdn.plot.ly/plotly-finance-1.28.0.min.js'

colorscale = cl.scales['9']['qual']['Paired']

app.layout = html.Div([
    html.Div([
        html.H2('Google Finance Explorer',
                style={'display': 'inline',
                       'float': 'left',
                       'font-size': '2.65em',
                       'margin-left': '7px',
                       'font-weight': 'bolder',
                       'font-family': 'Product Sans',
                       'color': "rgba(117, 117, 117, 0.95)",
                       'margin-top': '20px',
                       'margin-bottom': '0'
                       }),
        html.Img(src="https://s3-us-west-1.amazonaws.com/plotly-tutorials/logo/new-branding/dash-logo-by-plotly-stripe.png",
                style={
                    'height': '100px',
                    'float': 'right'
                },
        ),
    ]),
    dcc.Dropdown(
        id='stock-ticker-input',
        options=[{'label': ticker, 'value': ticker        }
                 for ticker in tickers],
        value='SBER'
    ),
    html.Div(id='graphs')
], className="container")

@app.callback(
    dash.dependencies.Output('graphs','children'),
    [dash.dependencies.Input('stock-ticker-input', 'value')])
def update_graph( ticker ):
    df = analizer.get_data_1( ticker )
    graphs = []
    candlestick = {
        'x': df[0],
        'open': df[1],
        'high': df[3],
        'low': df[4],
        'close': df[2],
        'type': 'candlestick',
        'name': ticker,
        'legendgroup': ticker,
        'increasing': {'line': {'color': colorscale[0]}},
        'decreasing': {'line': {'color': colorscale[1]}}
        }
    graphs.append(dcc.Graph(
        id=ticker,
        figure={
            'data': [candlestick],
            'layout': {
                'margin': {'b': 0, 'r': 10, 'l': 60, 't': 0},
                'legend': {'x': 0}
            }
        }
    ))

    return graphs


external_css = ["https://fonts.googleapis.com/css?family=Product+Sans:400,400i,700,700i",
                "https://cdn.rawgit.com/plotly/dash-app-stylesheets/2cc54b8c03f4126569a3440aae611bbef1d7a5dd/stylesheet.css"]

for css in external_css:
    app.css.append_css({"external_url": css})


if 'DYNO' in os.environ:
    app.scripts.append_script({
        'external_url': 'https://cdn.rawgit.com/chriddyp/ca0d8f02a1659981a0ea7f013a378bbd/raw/e79f3f789517deec58f41251f7dbb6bee72c44ab/plotly_ga.js'
    })


if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')