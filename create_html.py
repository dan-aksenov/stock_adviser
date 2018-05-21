import analizer

f = open('d:/tmp/tickers.html', 'w')

for i in analizer.get_all_tickers():
    f.write("%s\n" % '<button class="tablinks" onclick="openticker(event, ' + i + ')">'+ i +'</button>')

f.close()

f = open('d:/tmp/tickers.html', 'aw')

for i in analizer.get_all_tickers():
    f.write(
         '<div id="'+ i +'" class="tabcontent"> \n' +
         '<object data="graph.svg" type="image/svg+xml"> \n' +
         '<img src="yourfallback.jpg" /\n>'
         '</object>\n</div>\n'
    )

f.close()
	