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
    #dcc.Graph(id='close+emas chart')
    html.Div(id='close+emas chart')
])

@app.callback(Output('close+emas chart', 'children'), [Input('my-dropdown', 'value')])
def update_graph(selected_dropdown_value):
    stock_data = analizer.get_data( selected_dropdown_value )
    graph_data = {    
            'data': [
                {'x': stock_data[2],'y': stock_data[1], 'type': 'line', 'name': 'close'},
                {'x': stock_data[2],'y': stock_data[3], 'type': 'line', 'name': 'ema10'},
                {'x': stock_data[2],'y': stock_data[4], 'type': 'line', 'name': 'ema20'},
                ] 
            }
    graph = dcc.Graph(
        id=ticker,
        figure= graph_data)
    return graph
            
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
