import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

from plotly import tools
import plotly.graph_objs as go

#import analizer

from googlefinance.client import get_price_data

app = dash.Dash()

tickers = ['SBER',
'SBERP',
'GAZP',
'LKOH',
'MGNT',
'GMKN',
'NVTK',
'SNGS',
'SNGSP',
'ROSN',
'VTBR',
'TATN',
'SIBN',
'AFLT',
'MTSS',
'MAGN',
'NLMK',
'ALRS',
'CHMF',
'MOEX',
'IRAO',
'RASP',
'LSNG',
'LSNGP',
'VSMO'
]

#todo make 'good' ticker list

app.layout = html.Div([
    dcc.Dropdown(
        id='my-dropdown',
        options=[{'label': ticker, 'value': ticker}
                 for ticker in sorted(tickers)],
        value=sorted(tickers)[0]
    ),
    
    dcc.RadioItems(
        id='my-radio',
        options=[
        {'label': 'Daily chart', 'value': 86400},
        {'label': 'Weekly chart', 'value': 86400*7}
    ],
        value=86400*7
    ),
    
    html.Div([
        html.Div([
            #html.H3( 'Close, ema10, ema20' ),
            dcc.Graph(id='stacked_chart')
        ], className="six columns"),
    ], className="row")
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

@app.callback(Output('stacked_chart', 'figure'), [Input('my-dropdown', 'value') ,Input('my-radio', 'value')])
def update_main_graph(selected_dropdown_value, selected_radio_value):

    if selected_radio_value == 86400*7:
    	scale = "2Y"
        scale_title = "Weekly"
    elif selected_radio_value == 86400:
    	scale = "2M"
        scale_title = "Daily"
    
    param = {
	'q': selected_dropdown_value,   # Stock symbol (ex: "AAPL")
	'i': selected_radio_value,      # Interval size in seconds ("86400" = 1 day intervals)
	'x': "MCX",                     # Stock exchange symbol on which stock is traded (ex: "NASD")
	'p': scale                       # Period (Ex: "1Y" = 1 year)
    }
    
    df = get_price_data(param)
    
    close_chart = go.Scatter(
        x = df.index,
        y = df.Close,
        name='Close'
    )
    
    ema10_chart = go.Scatter(
        x = df.index,
        y = df.Close.ewm(span=10, adjust=False).mean(),
        name='ema10'
    )
    
    ema20_chart = go.Scatter(
        x = df.index,
        y = df.Close.ewm(span=20, adjust=False).mean(),
        name='ema20'
    )
                
    fi2_chart = go.Scatter(
        x = df.index,
        y = rawfi(df).ewm(span=2, adjust=False).mean(),
        name='fi2'
    )
    
    fi13_chart = go.Scatter(
        x = df.index,
        y = rawfi(df).ewm(span=13, adjust=False).mean(),
        name='fi13'
    )
    
    vol_chart = go.Bar(
        x = df.index,
        y = df.Volume,
        name='Volume'
    )

    stacked_chart = tools.make_subplots(rows=3, cols=1, specs=[[{}], [{}],[{}]],
                          shared_xaxes=True, shared_yaxes=False,
                          vertical_spacing=0.001)
    
    stacked_chart.append_trace(close_chart, 1, 1)
    stacked_chart.append_trace(ema10_chart, 1, 1)
    stacked_chart.append_trace(ema20_chart, 1, 1)
    stacked_chart.append_trace(fi2_chart, 2, 1)
    stacked_chart.append_trace(fi13_chart, 2, 1)
    stacked_chart.append_trace(vol_chart, 3, 1)
    
    stacked_chart['layout'].update(height=800, width=800, title= scale_title + ' analytics for ' + selected_dropdown_value)
    
    return stacked_chart

def rawfi(x):
     P = x.Close
     V = x.Volume
     raw_fi = (P-P.shift(1))*V
     return raw_fi
    
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
