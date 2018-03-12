import analizer

f = open('d:/tmp/tickers.html', 'w')

for i in analizer.get_all_tickers():
    f.write("%s\n" % '<button class="tablinks" onclick="openCity(event, ' + i + ')">'+ i +'</button>')

	