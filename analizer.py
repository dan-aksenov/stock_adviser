from psycopg2 import connect
import pygal
from pygal.style import CleanStyle
import sys

db_name = 'stocker'

def postgres_exec( sql_query ):
    ''' Выполенение произвольного sql в базе '''
    
    conn_string = 'dbname= ' + db_name + ' user=''postgres'' password=''1'' host=localhost'
    try:
        conn = connect( conn_string )
    except:
        print '\nERROR: unable to connect to the database!'
        sys.exit()
    cur = conn.cursor()
    cur.execute( sql_query )
    query_results = cur.fetchall()
    cur.close()
    conn.close()
    return query_results

def get_data( ticker ):
    db_data = postgres_exec( "select dt,close,ema10,ema20,fi2,fi13, AO,Volume from stock_w_fi where ticker = '" + ticker +"'")
    # select all, and render separately. Additional columns fi2, fi13, AO, Volume
    # line chart for FI, bar for Volume and AO
    return db_data
    
    close_prices = []
    close_dates = []
    ema10=[]
    ema20=[]

def main_chart( db_data ):    
    close_prices = []
    close_dates = []
    ema10=[]
    ema20=[]

    for row in db_data:
        close_dates.append(row[0])
        close_prices.append(row[1])
        ema10.append(row[2])
        ema20.append(row[3])
        
    chart = pygal.Line(style=CleanStyle)
    chart.x_labels = (map(lambda d: d.strftime('%Y-%m-%d'), close_dates))
    chart.add('close', close_prices)
    chart.add('ema10', ema10)
    chart.add('ema20', ema20)

    return chart.render()
    #chart.render_in_browser()
    #chart.render_to_file('/tmp/chart.svg')
    #chart.render_to_png('/tmp/chart.svg')

'''
def AO():
    ticker = request.args[0]
    db_data = db(db.stock_w_fi.ticker == ticker).select(db.stock_w_fi.dt,db.stock_w_fi.ao)

    close_dates = []
    ao=[]

    for row in db_data:
        close_dates.append(row.dt)
        ao.append(row.ao)

    response.files.append(URL('default','static/js/pygal-tooltips.min.js'))
    response.headers['Content-Type']='image/svg+xml'
    import pygal
    from pygal.style import CleanStyle
    chart = pygal.Bar(style=CleanStyle)
    chart.x_labels = (map(lambda d: d.strftime('%Y-%m-%d'), close_dates))
    chart.add('AO', ao)
    return chart.render()
'''