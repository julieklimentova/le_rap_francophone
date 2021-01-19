library(tidyverse)
library(tidytext)
stopWords <- tibble(
  word = c(
    "a",
    "à",
    "alors",
    "and",
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
    "c'",
    "c'est",
    "c´est",
    "c`est",
    "ce",
    "cela",
    "ces",
    "ceux",
    "chaque",
    "ci",
    "comme",
    "comment",
    "couplet",
    "dans",
    "des",
    "du",
    "de",
    "d'",
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
    "faut",
    "fois",
    "font",
    "hors",
    "i",
    "intro",
    "ici",
    "il",
    "ils",
    "je",
    "j'",
    "j'ai",
    "j'suis",
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
    "moi",
    "mot",
    "même",
    "ni",
    "nommés",
    "notre",
    "nous",
    "ou",
    "où",
    "on",
    "outro",
    "oh",
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
    "refrain",
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
    "t'as",
    "toi",
    "tellement",
    "tels",
    "tes",
    "ton",
    "tous",
    "tout",
    "trop",
    "très",
    "tu",
    "un",
    "une",
    "verse",
    "voient",
    "vont",
    "votre",
    "vous",
    "vu",
    "y",
    "y'a",
    "yeah",
    "you",
    "NA"
  ),
  lexicon = "ranks_french"
)
# List of songs files
list_of_files <- list.files(path = "./Experiments/files/",
                            pattern = "\\.txt$",
                            full.names = TRUE)
texts <- list_of_files %>%
  set_names(.) %>%
  map_df(read_table2, .id= "FileName")

texts_tokens <- texts %>%
  unnest_tokens(word, X1)

noStopWords <- texts_tokens %>%
  anti_join(stopWords, by = "word")

wordPerFile <- texts_tokens %>%
  count(FileName, word, sort = TRUE)

totalWords <- wordPerFile %>%
  group_by(FileName) %>%
  summarize(total = sum(n))

wordsFrequencies <- left_join(wordPerFile, totalWords)

freq_by_rank <- wordsFrequencies %>%
  group_by(FileName) %>%
  mutate(rank = row_number(),
         `term frequency` = n/total)

wordsWithTfIdf <- wordPerFile %>%
  bind_tf_idf(word, FileName, n)

wordsWithTfIdf <- wordsWithTfIdf %>%
  arrange(desc(tf_idf))

allWords <- texts_tokens %>%
  select(-FileName) %>%
  mutate(id = "all")

allWordsCounts <- allWords %>%
  count(word, sort = TRUE)


# texts_tokens %>%
# count(word, sort = TRUE) %>%
# filter(n > 600) %>%
# mutate(word = reorder(word, n)) %>%
# ggplot(aes(word, n)) +
# geom_col() +
# xlab(NULL) +
# coord_flip()
