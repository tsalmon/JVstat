require 'open-uri'
require 'rexml/document'

LOG = ["app_and_gnw", "FC?4554?"]
SITE =  "http://ws.jeuxvideo.com/forums/"

RGX_NEXT_PAGE = /0-.*<\/page_suivante>/
RGX_TOPIC = /1-.*<\/lien_topic>/
RGX_SUIV = /1-.*<\/suiv_rapide>/

RGX_T = /<\/lien_topic>/
RGX_S = /<\/page_suivante>/
RGX_R = /<\/suiv_rapide>/

def rgx_suppr(x, y)
  return x.to_s.sub y, ""
end

def topic(show)
  reception = open(SITE + show, :http_basic_authentication => LOG).read()
  titre = reception.match /.*<\/sujet_topic>/
  suiv = reception.match /.*<\/suiv_rapide>/
  puts titre.to_s + " : " +  suiv.to_s
end

def page (show)
  reception = open(SITE + show, :http_basic_authentication => LOG).read()
  suivant = rgx_suppr((reception.match RGX_NEXT_PAGE), RGX_S)
  topics = reception.scan(RGX_TOPIC).each { |link| topic(rgx_suppr(link,RGX_T))}
  #page(suivant)
end

page("0-19163-0-1-0-1-0-0.xml")
