# Title     : TODO
# Objective : TODO
# Created by: julie
# Created on: 7/17/2020

library(dplyr)
library(tokenizers)
library(tidytext)
library(ggplot2)
# TODO: Create a separate module for stop words
stopWords <- tibble(
  word = c(
    "à",
    "alors",
    "au",
    "aucuns",
    "aussi",
    "autre",
    "avant",
    "avec",
    "avoir",
    "bon",
    "ça",
    "car",
    "ce",
    "cela",
    "ces",
    "ceux",
    "chaque",
    "ci",
    "comme",
    "comment",
    "dans",
    "des",
    "du",
    "dedans",
    "dehors",
    "depuis",
    "devrait",
    "doit",
    "donc",
    "dos",
    "début",
    "elle",
    "elles",
    "en",
    "encore",
    "essai",
    "est",
    "et",
    "étaient",
    "état",
    "étions",
    "été",
    "être",
    "eu",
    "fait",
    "faites",
    "fois",
    "font",
    "hors",
    "ici",
    "il",
    "ils",
    "je",
    "juste",
    "la",
    "le",
    "les",
    "leur",
    "là",
    "ma",
    "maintenant",
    "mais",
    "me",
    "m'",
    "mes",
    "mien",
    "moins",
    "mon",
    "mot",
    "même",
    "ni",
    "nommés",
    "notre",
    "nous",
    "ou",
    "où",
    "on",
    "par",
    "parce",
    "pas",
    "peut",
    "peu",
    "plupart",
    "plus",
    "pour",
    "pourquoi",
    "quand",
    "que",
    "quel",
    "quelle",
    "quelles",
    "quels",
    "qui",
    "sa",
    "sans",
    "ses",
    "se",
    "s'",
    "seulement",
    "si",
    "sien",
    "son",
    "sont",
    "sous",
    "soyez",
    "sujet",
    "sur",
    "ta",
    "tandis",
    "te",
    "t'",
    "tellement",
    "tels",
    "tes",
    "ton",
    "tous",
    "tout",
    "trop",
    "très",
    "tu",
    "voient",
    "vont",
    "votre",
    "vous",
    "vu",
    "y"
  ),
  lexicon = "ranks_french"
)

songText <- c("T'es sûr que tu veux prendre le bus, on peut y aller à pied",
              "Ah, c'est mort, depuis mes premiers pas, j'ai plus jamais marché",
              "Ouais, mais y a qu'deux arrêts, on irait plus vite à pied",
              "Et beaucoup plus vite si j'avais pas ma caisse à réparer")

# How do the line work ?
songDf <- tibble(line = 1:4, text = songText)

songWords <- songDf %>%
  unnest_tokens(word, text)

noStopWords <- songWords %>%
  anti_join(stopWords, by = "word")

# TODO: Stop words need to be removed
noStopWords %>%
  count(word, sort = TRUE) %>%
  filter(n > 1) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()

