# -*- coding: utf-8 -*-
require 'open-uri'
require 'rexml/document'

LOG = ["app_and_gnw", "FC?4554?"]
SITE =  "http://ws.jeuxvideo.com/forums/"
MyFile = File.open("result", "w")

RGX_NEXT_PAGE = /0-.*<\/page_suivante>/
RGX_TOPIC = /1-.*<\/lien_topic>/
RGX_SUIV = /.*<\/suiv_rapide>/
RGX_DERNIERE = /.*<\/derniere_page>/
RGX_CONTENT = "<contenu>.*"

RGX_T = /<\/lien_topic>/
RGX_R = /<\/?suiv_rapide>|jv:\/\/forums\//
RGX_S = /<\/page_suivante>/
RGX_D = /<\/?derniere_page>|jv:\/\/forums\//


def rgx_suppr(x, y)
  return x.to_s.sub y, ""
end

#lecture des réponses d'une page de suejt
def contenu(show)
  puts show
end

#lecture page par page d'un sujet
def topic(show)
  reception = open(SITE + show, :http_basic_authentication => LOG).read()
  suiv = reception.match RGX_SUIV
  contenu(reception.match RGX_CONTENT)
  if(suiv.to_s == "<suiv_rapide><\/suiv_rapide>") then
    dernier = reception.match RGX_DERNIERE
    if(dernier.to_s != "<derniere_page><\/derniere_page>") then # nb pages = 2
      # topic(dernier.to_s.gsub RGX_D, "")
    end
  else # nb pages > 2
    # topic(suiv.to_s.gsub RGX_R, "")
  end
end

#lecture page par page de la liste des sujets
def page (show)
  reception = open(SITE + show, :http_basic_authentication => LOG).read()
  suivant = rgx_suppr((reception.match RGX_NEXT_PAGE), RGX_S)
  topics = reception.scan(RGX_TOPIC).each { |link| topic(rgx_suppr(link,RGX_T))}
  #page(suivant)
end

page("0-19163-0-1-0-1-0-0.xml")
MyFile.close
