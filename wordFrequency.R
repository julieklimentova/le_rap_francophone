# Title     : TODO
# Objective : TODO
# Created by: julie
# Created on: 7/17/2020

library(dplyr)
library(tokenizers)
library(tidytext)
library(ggplot2)
# TODO: Import of stop words as a character vector ?
# STOP_WORDS <- scan("./stopWords.txt")

# TODO: Figure out of the import of data into the correct format
songText <- c("T'es sûr que tu veux prendre le bus, on peut y aller à pied",
"Ah, c'est mort, depuis mes premiers pas, j'ai plus jamais marché",
"Ouais, mais y a qu'deux arrêts, on irait plus vite à pied",
"Et beaucoup plus vite si j'avais pas ma caisse à réparer")

# How do the line work ?
songDf <- tibble(line = 1:4, text = songText)

songWords <- songDf %>%
  unnest_tokens(word, text)
# TODO: Stop words need to be removed and
songWords %>%
  count(word, sort = TRUE) %>%
  filter(n > 1) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word,n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()

