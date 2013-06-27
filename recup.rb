# -*- coding: utf-8 -*-
require 'open-uri'
require 'rexml/document'

LOG = ["app_and_gnw", "FC?4554?"]
SITE =  "http://ws.jeuxvideo.com/"
PSEUDO = {}
RGX_NEXT_PAGE = /0-.*<\/page_suivante>/
RGX_TOPIC = /1-.*<\/lien_topic>/
RGX_SUIV = /.*<\/suiv_rapide>/
RGX_DERNIERE = /.*<\/derniere_page>/
RGX_CONTENT = "<contenu>.*"
RGX_PSEUDO = /jv:\/\/profil\/[\w_\[\]\(\)\{\}-]*\.xml/

def rgx_suppr(x, y)
  return x.to_s.sub y, ""
end

#lecture des réponses d'une page de sujet
def pseudo(show)
  if(PSEUDO[show] == nil) then
    PSEUDO[show] = [1,0]
  else
    PSEUDO[show][0] += 1
  end
end

#lecture page par page d'un sujet
def topic(show)
  reception = open(SITE + "forums/" + show, :http_basic_authentication => LOG).read()
  suiv = (reception.match RGX_SUIV).to_s
  reception.scan(RGX_PSEUDO).each {|p| pseudo(p[12..-1])}
  if(suiv == "<suiv_rapide><\/suiv_rapide>") then
    dernier = (reception.match RGX_DERNIERE).to_s
    if(dernier != "<derniere_page><\/derniere_page>") then # nb pages = 2
      topic(dernier[27..-17])
    end
  else # nb pages > 2
    topic(suiv[25..-15])
  end
end

#lecture page par page de la liste des sujets
def page (show)
  if(show == "") then
    return
  else
    reception = open(SITE + "forums/" +  show, :http_basic_authentication => LOG).read()
    suivant = (reception.match RGX_NEXT_PAGE).to_s[0..-17]
    topics = reception.scan(RGX_TOPIC).each {|link| topic(link[0..-14])}
    page(suivant)
  end
end

def profil(show)
  s =  (show.sub /\]/, "%5D").to_s.sub /\[/, "%5B"
  begin
    reception = open(SITE + "profil/" + s, :http_basic_authentication => LOG).read()
    age = (reception.match /.*<\/age>/).to_s
    PSEUDO[show][1] = (age.match /[0-9]+/).to_s
  rescue URI::InvalidURIError
    puts "\""+show + "\" n'a pas pu etre identifié" 
  end
end

def forum_jeu()
  nom = ""
  ARGV.each {|arg| nom+="-"+arg}
  reception = open(SITE + "search_forums_sug/" + nom[1..-1], :http_basic_authentication => LOG).read()
  page("0-"+(reception.match /[0-9]+<\/id>/).to_s[0..-6]+"-0-1-0-1-0-0.xml")
end

if __FILE__ == $0
  MyFile = File.open("result", "w")
  # algo premiere partie: 
  #   on va sur le forum
  #   pour toutes les 25 topics de forums:
  #      ouvrir topic
  #      pour chaque page du topic:
  #          recuperer infos
  forum_jeu()
  # algo deuxieme partie:
  #   pour chaque profil:
  #      recuperer age
  PSEUDO.each{ |key, value| profil(key)}
  PSEUDO.each {|key, value| MyFile.write(key + " " + value[1].to_s + " " + value[0].to_s + "\n") }
  MyFile.close
  end
                 
