import analizer

f = open('d:/tmp/tickers.html', 'w')

for i in analizer.get_all_tickers():
    db_data = analizer.get_data_static( i )
    analizer.main_chart(db_data)	