import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt
import analizer

# from https://plot.ly/products/dash/

app = dash.Dash()

app.layout = html.Div([
    html.H1('Stock Tickers'),
    dcc.Dropdown(
        id='my-dropdown',
        options=[
            {'label': 'Sber', 'value': 'SBER'},
            {'label': 'Gazprom', 'value': 'GAZP'},
        ],
        value='SBER'
    ),
    dcc.Graph(id='my-graph')
])

@app.callback(Output('my-graph', 'figure'), [Input('my-dropdown', 'value')])
def update_graph(selected_dropdown_value):
    a = analizer.get_data(selected_dropdown_value)
    return {
        'data': [{
              {'x': a[2],'y': a[1], 'type': 'line', 'name': 'close'}
        }]
    }

if __name__ == '__main__':
    app.run_server()
