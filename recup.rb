require 'open-uri'
require 'rexml/document'

SITE =  "http://ws.jeuxvideo.com/forums/"

def page (show) 
  reception = open(SITE + show, :http_basic_authentication => ["app_and_gnw", "FC?4554?"]).read()
  puts reception 
end

page("0-19163-0-1-0-1-0-0.xml")
