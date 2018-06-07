import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

import analizer

from googlefinance.client import get_price_data

app = dash.Dash()

tickers = analizer.get_all_tickers()

app.layout = html.Div([
    dcc.Dropdown(
        id='my-dropdown',
        options=[{'label': ticker, 'value': ticker        }
                 for ticker in tickers],
        value='ALRS'
    ),
    html.Div([
        html.Div([
            html.H3( 'Close, ema10, ema20'),
            dcc.Graph(id='main_chart')
        ], className="six columns"),

        html.Div([
            html.H3('Forse index 2 and 13'),
            dcc.Graph(id='fi_chart')
        ], className="six columns"),
    ], className="row")
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

@app.callback(Output('main_chart', 'figure'), [Input('my-dropdown', 'value')])
def update_main_graph(selected_dropdown_value):
    param = {
	'q': selected_dropdown_value, # Stock symbol (ex: "AAPL")
	'i': "86400", # Interval size in seconds ("86400" = 1 day intervals)
	'x': "MCX", # Stock exchange symbol on which stock is traded (ex: "NASD")
	'p': "1Y" # Period (Ex: "1Y" = 1 year)
    }
    
    df = get_price_data(param)
    
    main_chart = {    
            'data': [{ 
                 'x': df.index,
                 'y': df.Close
                    }]
            }
    return main_chart

#@app.callback(Output('fi_chart', 'figure'), [Input('my-dropdown', 'value')])
#def update_fi_graph(selected_dropdown_value):
#    stock_data = analizer.get_data_dash( selected_dropdown_value )
#    fi_chart = {
#            'data': [
#                {'x': stock_data[0],'y': stock_data[7], 'type': 'line', 'name': 'fi2'},
#                {'x': stock_data[0],'y': stock_data[8], 'type': 'line', 'name': 'fi13'},
#                ]
#           }
#    return fi_chart

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
