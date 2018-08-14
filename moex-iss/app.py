import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pandas_datareader import data as web
from datetime import datetime as dt

from plotly import tools
import plotly.graph_objs as go

#import analizer

from iss_simple_main import get_price_data

app = dash.Dash()

tickers = [
#BLUE CHIPS AND INDEX
'SBER',
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
'TATNP',
'FIVE',
'YNDX',
'POLY',
'PLZL',
'PHOR',
'RUAL',
'MFON',
'HYDR',
'RTKM',
'FEES',
'PIKK',
'AFKS',
'RNFT',
'UPRO',
'TRMK',
'SFIN',
'DSKY',
'MTLR',
'UWGN',
'MVID',
'RASP',
#DIV HISTORY
'LSNGP',
'VSMO',
'MTLRP',
'BANEP',
'MGTSP'
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
        {'label': 'Small scale', 'value': 30*2},
        {'label': 'Large scale', 'value': 365*2}
    ],
        value=365*2
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
    ticker = selected_dropdown_value	
    if selected_radio_value == 30*2:
    	days_befoure = 30*2
        scale_title = "Daily"
    else:
    	days_befoure = 365*2
        scale_title = "Weekly"
 
    df = get_price_data(ticker, days_befoure)
    
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
    
    stacked_chart['layout'].update(height=800, width=1280, title= scale_title + ' analytics for ' + selected_dropdown_value)
    
    return stacked_chart

def rawfi(x):
     P = x.Close
     V = x.Volume
     raw_fi = (P-P.shift(1))*V
     return raw_fi
    
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
