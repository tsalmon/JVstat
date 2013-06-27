# -*- coding: utf-8 -*-
require 'open-uri'
require 'rexml/document'

LOG = ["app_and_gnw", "FC?4554?"]
CO = :http_basic_authentication
SITE =  "http://ws.jeuxvideo.com/"
PSEUDO = {}
RGX_NEXT_PAGE = /0-.*<\/page_suivante>/
RGX_TOPIC = /1-.*<\/lien_topic>/
RGX_CONTENT = "<contenu>.*"
RGX_PSEUDO = /jv:\/\/profil\/[\w_\[\]\(\)\{\}-]*\.xml/

def pseudo(show)
  if(PSEUDO[show] == nil) then
    PSEUDO[show] = [1,0]
  else
    PSEUDO[show][0] += 1
  end
end

def topic_suivant(suiv, last)
  if(suiv != "<suiv_rapide><\/suiv_rapide>") then
    return topic(suiv[25..-15])
  end
  return (last != "<derniere_page></derniere_page>") ? topic(last[27..-17]) : nil
end

#lecture page par page d'un sujet
def topic(show)
  reception = open(SITE + "forums/" + show, CO => LOG).read()
  suivant = (reception.match /.*<\/suiv_rapide>/).to_s
  dernier = (reception.match /.*<\/derniere_page>/).to_s
  reception.scan(RGX_PSEUDO).each {|p| pseudo(p[12..-1])}
  topic_suivant(suivant, dernier)
end

#lecture page par page de la liste des sujets
def page (show)
  if(show != "") then
    reception = open(SITE + "forums/" + show, CO => LOG).read()
    reception.scan(RGX_TOPIC).each {|link| topic(link[0..-14])}
    page((reception.match RGX_NEXT_PAGE).to_s[0..-17])
  end
end

def profil(show)
  s = (show.sub /\]/, "%5D").to_s.sub /\[/, "%5B"
  reception = open(SITE + "profil/" + s, CO => LOG).read()
  age = (reception.match /.*<\/age>/).to_s
  PSEUDO[show][1] = (age.match /[0-9]+/).to_s
end

def forum_jeu()
  nom = SITE + "search_forums_sug/"
  ARGV.each {|arg| nom+="-"+arg}
  reception = open(nom, CO => LOG).read()
  page("0-"+(reception.match /[0-9]+<\/id>/).to_s[0..-6]+"-0-1-0-1-0-0.xml")
  return enregistre(nom[43..-1])
end

def ecriture(mb)
  PSEUDO.each{ |key, value| profil(key)} # part. 2
  PSEUDO.each do |key, value| 
    mb.write(key + " " + value[1].to_s + " " + value[0].to_s + "\n")
  end
  mb.close
end

def enregistre(nom_jeu)
  if(false == (File.directory? "JV_" + nom_jeu)) then
    Dir.mkdir("JV_" + nom_jeu)
  end
  mb = File.open("JV_" + nom_jeu + "/" + "membres.info", "w")
  ecriture(mb)
end

# algo premiere partie: 
#   on va sur le forum
#   pour toutes les 25 topics de forums:
#      ouvrir topic
#      pour chaque page du topic:
#          recuperer infos

# algo deuxieme partie:
#   pour chaque profil:
#      recuperer age
if __FILE__ == $0
  forum_jeu() # part. 1
end
