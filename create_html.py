import analizer

f = open('d:/tmp/tickers.html', 'w')

for i in analizer.get_all_tickers():
    f.write("%s\n" % '<button class="tablinks" onclick="openticker(event, ' + i + ')">'+ i +'</button>')

	