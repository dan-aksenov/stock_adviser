# -*- coding: utf-8 -*-
import dash
import dash_core_components as dcc
import dash_html_components as html
import analizer

app = dash.Dash()

a = analizer.get_data('SBER')

app.layout = html.Div(children=[
    html.H1(children='Hello Dash'),

    html.Div(children='''
        Dash: A web application framework for Python.
    '''),

    dcc.Graph(
        id='close+emas chart',
        figure={
            'data': [
                {'x': a[2],'y': a[1], 'type': 'line', 'name': 'close'},
                {'x': a[2],'y': a[3], 'type': 'line', 'name': 'ema10'},
                {'x': a[2],'y': a[4], 'type': 'line', 'name': 'ema20'},
            ],      
            'layout': {
                'title': 'Dash Data Visualization'
            }
        }
    ),

    dcc.Graph(
        id='fi',
        figure={
            'data': [
                {'x': a[2],'y': a[5], 'type': 'line', 'name': 'fi2'},
                {'x': a[2],'y': a[6], 'type': 'line', 'name': 'fi13'},
            ],      
            'layout': {
                'title': 'Dash Data Visualization'
            }
        }
    )
])

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')