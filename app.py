import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

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
        value=86400
    ),
    
    html.Div([
        html.Div([
            #html.H3( 'Close, ema10, ema20' ),
            dcc.Graph(id='main_chart')
        ], className="six columns"),

        html.Div([
            #html.H3('Forse index 2 and 13'),
            dcc.Graph(id='fi_chart')
        ], className="six columns"),
    ], className="row")
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

@app.callback(Output('main_chart', 'figure'), [Input('my-dropdown', 'value') ,Input('my-radio', 'value')])
def update_main_graph(selected_dropdown_value, selected_radio_value):
    
    param = {
	'q': selected_dropdown_value,   # Stock symbol (ex: "AAPL")
	'i': selected_radio_value,      # Interval size in seconds ("86400" = 1 day intervals)
	'x': "MCX",                     # Stock exchange symbol on which stock is traded (ex: "NASD")
	'p': "1Y"                       # Period (Ex: "1Y" = 1 year)
    }
    
    df = get_price_data(param)
    
    main_chart = {  
            'data': [ 
                 {'x': df.index, 'y': df.Close, 'type': 'line', 'name': 'Close'},
                 {'x': df.index, 'y': df.Close.ewm(span=10, adjust=False).mean(),'type': 'line', 'name': 'EMA10'},
                 {'x': df.index, 'y': df.Close.ewm(span=20, adjust=False).mean(),'type': 'line', 'name': 'EMA20'}
                    ],
            'layout': {
                'title': 'Close, ema10, ema20 for ' + selected_dropdown_value
            }
            }
    return main_chart

@app.callback(Output('fi_chart', 'figure'), [Input('my-dropdown', 'value') ,Input('my-radio', 'value')])
def update_fi_graph(selected_dropdown_value, selected_radio_value):
    
    param = {
	'q': selected_dropdown_value,   # Stock symbol (ex: "AAPL")
	'i': selected_radio_value,      # Interval size in seconds ("86400" = 1 day intervals)
	'x': "MCX",                     # Stock exchange symbol on which stock is traded (ex: "NASD")
	'p': "1Y"                       # Period (Ex: "1Y" = 1 year)
    }
    
    df = get_price_data(param)
    
    fi_chart = {
            'data': [
                {'x': df.index, 'y': rawfi(df).ewm(span=2, adjust=False).mean(), 'type': 'line', 'name': 'fi2'},
                {'x': df.index, 'y': rawfi(df).ewm(span=13, adjust=False).mean(), 'type': 'line', 'name': 'fi13'}
                    ],
            'layout': {
                'title': 'Forse index 2 and 13 for ' + selected_dropdown_value
            }
           }
    return fi_chart

def rawfi(x):
     P = x.Close
     V = x.Volume
     raw_fi = (P-P.shift(1))*V
     return raw_fi
    
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
