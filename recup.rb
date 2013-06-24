require 'open-uri'
require 'rexml/document'

LOG = ["app_and_gnw", "FC?4554?"]
SITE =  "http://ws.jeuxvideo.com/forums/"
NEXT_PAGE = /0-.*<\/page_suivante>/
def page (show) 
  reception = open(SITE + show, :http_basic_authentication => LOG).read()
  suivant = (reception.match NEXT_PAGE).to_s.sub /<\/page_suivante>/, ""
  page suivant
end

page("0-19163-0-1-0-1-0-0.xml")
