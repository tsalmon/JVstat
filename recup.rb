require 'open-uri'
lien = "http://ws.jeuxvideo.com/forums/"
page = lien + "0-19163-0-1-0-1-0-0.xml"
topico = open(page, :http_basic_authentication => ["appandr", "e32!cdf"]).read().split(/<topic>/)[0]

page_suivante = topico.split("\n")[5].slice(/[0-9][^<]+/)
puts page_suivante
1.upto(1000) do |x|
	topico = open(lien + page_suivante, :http_basic_authentication => ["appandr", "e32!cdf"]).read().split(/<topic>/)[0]

	page_suivante = topico.split("\n")[5].slice(/[0-9][^<]+/)
	puts page_suivante
end
