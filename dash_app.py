import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

import analizer

app = dash.Dash()

tickers = analizer.get_all_tickers()

app.layout = html.Div([
    html.H1('Stock Tickers'),
    dcc.Dropdown(
        id='my-dropdown',
        options=[{'label': ticker, 'value': ticker        }
                 for ticker in tickers],
        value='SBER'
    ),
    html.Div( id='close+emas chart' )
])

@app.callback(Output('close+emas chart', 'children'), [Input('my-dropdown', 'value')])
def update_main_graph(selected_dropdown_value):
    stock_data = analizer.get_data( selected_dropdown_value )
    main_chart = {    
            'data': [
                {'x': stock_data[0],'y': stock_data[2], 'type': 'line', 'name': 'close'},
                {'x': stock_data[0],'y': stock_data[5], 'type': 'line', 'name': 'ema10'},
                {'x': stock_data[0],'y': stock_data[6], 'type': 'line', 'name': 'ema20'},
                ] 
            }
    fi_chart = {
            'data': [
                {'x': stock_data[0],'y': stock_data[7], 'type': 'line', 'name': 'fi2'},
                {'x': stock_data[0],'y': stock_data[8], 'type': 'line', 'name': 'fi13'},
                ]
           }
    graph = dcc.Graph(
        id=ticker,
        figure= main_chart)
    return graph

#@app.callback(Output('fi chart', 'children'), [Input('my-dropdown', 'value')])
def update_fi_graph(selected_dropdown_value):
    stock_data = analizer.get_data( selected_dropdown_value )
    fi_chart = {
            'data': [
                {'x': stock_data[0],'y': stock_data[7], 'type': 'line', 'name': 'fi2'},
                {'x': stock_data[0],'y': stock_data[8], 'type': 'line', 'name': 'fi13'},
                ]
           }
    graph = dcc.Graph(
        id=ticker,
        figure= fi_chart)
    return graph

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
