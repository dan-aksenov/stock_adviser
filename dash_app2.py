import dash
import dash_html_components as html
import dash_core_components as dcc
import analizer

app = dash.Dash()
stock_data = analizer.get_data( 'SBER' )
app.layout = html.Div([
    html.Div([
        html.Div([
            html.H3('Column 1'),
            dcc.Graph(id='g1', figure={ 
            'data': [
                {'x': stock_data[0],'y': stock_data[2], 'type': 'line', 'name': 'close'},
                {'x': stock_data[0],'y': stock_data[5], 'type': 'line', 'name': 'ema10'},
                {'x': stock_data[0],'y': stock_data[6], 'type': 'line', 'name': 'ema20'},
                ] 
            })
        ], className="six columns"),

        html.Div([
            html.H3('Column 2'),
            dcc.Graph(id='g2', figure={
            'data': [
                {'x': stock_data[0],'y': stock_data[7], 'type': 'line', 'name': 'fi2'},
                {'x': stock_data[0],'y': stock_data[8], 'type': 'line', 'name': 'fi13'},
                ]
           })
        ], className="six columns"),
    ], className="row")
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
