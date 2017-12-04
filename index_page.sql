select * from 
(select distinct '<p><a href="'||ticker||'.html">'||ticker||'</a></p>' as ticker from stock_w_ma) as hrefs
 order by ticker;
