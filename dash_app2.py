import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

import analizer

app = dash.Dash()

app.layout = html.Div([
    html.H1('Stock Tickers'),
    dcc.Dropdown(
        id='my-dropdown',
        options=[
            {'label': 'SBER', 'value': 'SBER'},
            {'label': 'GAZP', 'value': 'GAZP'},
            {'label': 'YNDX', 'value': 'YNDX'}
        ],
        value='SBER'
    ),
    dcc.Graph(id='close+emas chart')
])

@app.callback(Output('close+emas chart', 'figure'), [Input('my-dropdown', 'value')])
def update_graph(selected_dropdown_value):
    dbdata = analizer.get_data( selected_dropdown_value )
    return {
	        'data': [
                {'x': dbdata[2],'y': dbdata[1], 'type': 'line', 'name': 'close'},
                {'x': dbdata[2],'y': dbdata[3], 'type': 'line', 'name': 'ema10'},
                {'x': dbdata[2],'y': dbdata[4], 'type': 'line', 'name': 'ema20'},
                ] 
			}

if __name__ == '__main__':
    app.run_server()