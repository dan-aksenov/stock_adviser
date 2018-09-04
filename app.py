import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
from pandas_datareader import data as web
import datetime as dt
import colorlover as cl

from plotly import tools
import plotly.graph_objs as go

app = dash.Dash()

colorscale = cl.scales['9']['qual']['Paired']

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
        {'label': 'Daily chart', 'value': 'daily'},
        {'label': 'Weekly chart', 'value': 'weekly'}
    ],
        value='weekly'
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

@app.callback(Output('stacked_chart', 'figure'), [Input('my-dropdown', 'value'),Input('my-radio', 'value')])
def update_main_graph(selected_dropdown_value, selected_radio_value):
    
    # weekly data block
    if selected_radio_value == 'weekly':
        dtstart = dt.datetime.now() - dt.timedelta(days=365)
        dtstart = dtstart.strftime("%Y-%m-%d")
        f = web.DataReader(selected_dropdown_value, 'moex', start = dtstart)
        df = f.loc[(f['BOARDID'] == 'TQBR'), ['OPEN','CLOSE','LOW','HIGH','VOLUME']]
        CLOSE = df.CLOSE.resample('W-FRI').last()
        VOLUME = df.VOLUME.resample('W-FRI').last()
        OPEN = df.OPEN.resample('W-FRI').last()
        HIGH = df.HIGH.resample('W-FRI').last()
        LOW = df.LOW.resample('W-FRI').last()
        df = pd.concat([OPEN,CLOSE,HIGH,LOW,VOLUME], axis=1)
 
    # daily data block
    elif selected_radio_value == 'daily':
        dtstart = dt.datetime.now() - dt.timedelta(days=60)
        dtstart = dtstart.strftime("%Y-%m-%d")
        f = web.DataReader(selected_dropdown_value, 'moex', start= dtstart)
        df = f.loc[(f['BOARDID'] == 'TQBR'), ['OPEN','CLOSE','LOW','HIGH','VOLUME']]

    candlestick = {
            'x': df.index,
            'open': df.OPEN,
            'high': df.HIGH,
            'low': df.LOW,
            'close': df.CLOSE,
            'type': 'candlestick',
            'name': selected_dropdown_value,
            'legendgroup': selected_dropdown_value,
            'increasing': {'line': {'color': colorscale[0]}},
            'decreasing': {'line': {'color': colorscale[1]}}
        }

    # still present, but not used anymore     
    CLOSE_chart = go.Scatter(
        x = df.index,
        y = df.CLOSE,
        name='CLOSE'
    )
    
    ema10_chart = go.Scatter(
        x = df.index,
        y = df.CLOSE.ewm(span=10, adjust=False).mean(),
        name='ema10'
    )
    
    ema20_chart = go.Scatter(
        x = df.index,
        y = df.CLOSE.ewm(span=20, adjust=False).mean(),
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
        y = df.VOLUME,
        name='VOLUME'
    )

    stacked_chart = tools.make_subplots(rows=3, cols=1, specs=[[{}], [{}],[{}]],
                          shared_xaxes=True, shared_yaxes=False,
                          vertical_spacing=0.001)
    
#   stacked_chart.append_trace(CLOSE_chart, 1, 1)
    stacked_chart.append_trace(candlestick, 1, 1)
    stacked_chart.append_trace(ema10_chart, 1, 1)
    stacked_chart.append_trace(ema20_chart, 1, 1)
    stacked_chart.append_trace(fi2_chart, 2, 1)
    stacked_chart.append_trace(fi13_chart, 2, 1)
    stacked_chart.append_trace(vol_chart, 3, 1)
    
    stacked_chart['layout'].update(height=800, width=800, title= 'Analytics for ' + selected_dropdown_value)
    
    return stacked_chart

def rawfi(x):
     P = x.CLOSE
     V = x.VOLUME
     raw_fi = (P-P.shift(1))*V
     return raw_fi

def bbands(price, window_size=10, num_of_std=5):
    rolling_mean = price.rolling(window=window_size).mean()
    rolling_std  = price.rolling(window=window_size).std()
    upper_band = rolling_mean + (rolling_std*num_of_std)
    lower_band = rolling_mean - (rolling_std*num_of_std)
    return rolling_mean, upper_band, lower_band
    
if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0')
