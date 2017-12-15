# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------
# This is a sample controller
# this file is released under public domain and you can use without limitations
# -------------------------------------------------------------------------

# ---- example index page ----
def index():
    tickers = db().select(db.stock_w_fi.ticker, distinct=db.stock_w_fi.ticker)
    return dict(tickers=tickers)

def main_chart():
    ticker = request.args[0]
    db_data = db(db.stock_w_fi.ticker == ticker).select(db.stock_w_fi.close,db.stock_w_fi.dt,db.stock_w_fi.ema10,db.stock_w_fi.ema20)

    close_prices = []
    close_dates = []
    ema10=[]
    ema20=[]
    for row in db_data:
        close_prices.append(row.close)
        close_dates.append(row.dt)
        ema20.append(row.ema20)
        ema10.append(row.ema10)

    response.files.append(URL('default','static/js/pygal-tooltips.min.js'))
    response.headers['Content-Type']='image/svg+xml'
    import pygal
    from pygal.style import CleanStyle
    chart = pygal.Line(style=CleanStyle)
    chart.x_labels = (map(lambda d: d.strftime('%Y-%m-%d'), close_dates))
    chart.add('close', close_prices)
    chart.add('ema10', ema10)
    chart.add('ema20', ema20)
    return chart.render()

def fi2():
    ticker = request.args[0]
    db_data = db(db.stock_w_fi.ticker == ticker).select(db.stock_w_fi.dt,db.stock_w_fi.fi2)

    close_dates = []
    fi2=[]

    for row in db_data:
        ema10.append(row.fi2)

    response.files.append(URL('default','static/js/pygal-tooltips.min.js'))
    response.headers['Content-Type']='image/svg+xml'
    import pygal
    from pygal.style import CleanStyle
    chart = pygal.Line(style=CleanStyle)
    chart.x_labels = (map(lambda d: d.strftime('%Y-%m-%d'), close_dates))
    chart.add('fi2', fi2)
    return chart.render()

def show_old():
    ticker = request.args[0]
                           #or redirect(URL('index')))
    #db.stock_w_fi.ticker.default = ticker
    #ticker=db().select(db.stock_w_fi.ticker, distinct=db.stock_w_fi.ticker)
    #if form.process().accepted:
    #    response.flash = 'your comment is posted'
    #comments = db(db.post.image_id == image.id).select()
    ticker = db(db.stock_w_fi.ticker == ticker).select()
    #ticker = request.args[0]
    return dict(ticker=ticker)

# <trainings
def displayTickers():
    #query=db().select(db.stock_w_fi.ticker, distinct=db.stock_w_fi.ticker)
    #return grid(SQLFORM.grid(query))
    tuples=db().select(db.stock_w_fi.ticker, distinct=db.stock_w_fi.ticker)
    return dict(grid=tuples)

def displayTickersG():
    #query=((db.stock_w_fi.ticker))
    #fields = (db.stock_w_fi.ticker)
    #default_sort_order=[db.stock_w_fi.ticker]
    #form = SQLFORM.grid(query=query,fields=fields,orderby=default_sort_order)
    #return dict(form=form)
    grid = SQLFORM.grid(db.stock_w_fi)
    return locals()

def TickerSelector():
    tickers = db().select(db.stock_w_fi.ticker, distinct=db.stock_w_fi.ticker)
    form = FORM(TR(tickers))
# /trainings>

# ---- API (example) -----
@auth.requires_login()
def api_get_user_email():
    if not request.env.request_method == 'GET': raise HTTP(403)
    return response.json({'status':'success', 'email':auth.user.email})

# ---- Smart Grid (example) -----
@auth.requires_membership('admin') # can only be accessed by members of admin groupd
def grid():
    response.view = 'generic.html' # use a generic view
    tablename = request.args(0)
    if not tablename in db.tables: raise HTTP(403)
    grid = SQLFORM.smartgrid(db[tablename], args=[tablename], deletable=False, editable=False)
    return dict(grid=grid)

# ---- Embedded wiki (example) ----
def wiki():
    auth.wikimenu() # add the wiki to the menu
    return auth.wiki() 

# ---- Action for login/register/etc (required for auth) -----
def user():
    """
    exposes:
    http://..../[app]/default/user/login
    http://..../[app]/default/user/logout
    http://..../[app]/default/user/register
    http://..../[app]/default/user/profile
    http://..../[app]/default/user/retrieve_password
    http://..../[app]/default/user/change_password
    http://..../[app]/default/user/bulk_register
    use @auth.requires_login()
        @auth.requires_membership('group name')
        @auth.requires_permission('read','table name',record_id)
    to decorate functions that need access control
    also notice there is http://..../[app]/appadmin/manage/auth to allow administrator to manage users
    """
    return dict(form=auth())

# ---- action to server uploaded static content (required) ---
@cache.action()
def download():
    """
    allows downloading of uploaded files
    http://..../[app]/default/download/[filename]
    """
    return response.download(request, db)
