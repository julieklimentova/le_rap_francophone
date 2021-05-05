library(udpipe)
library(textrank)
library(tidyverse)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)

verbsPath <- '../Experiments/frenchWeb/verbs.csv'
verbsWeb <- readr::read_csv(file = verbsPath, locale = readr::locale(encoding = "utf8"))
verbsWeb <- verbsWeb[-1,]
verbsWeb <- verbsWeb[-1,]
names(verbsWeb)[1] <- 'key'
names(verbsWeb)[2] <- 'freq'
new_frequencies <- data.frame()
for (i in 1:nrow(verbsWeb)) {
  frequency <- verbsWeb[i, 2][[1]]
  numeric_freq <- as.numeric(frequency)
  print(numeric_freq)
  new_frequencies[i, 1][[1]] <- numeric_freq
}
new_frequencies <- head(new_frequencies, 10)
col_names <- head(verbsWeb$key, 10)
barplot(new_frequencies[,1], names.arg = col_names, col= "blue",
         main = "Most occurring verbs in web 2017 corpus", log="y", cex.names=0.7)

nounsPath <- '../Experiments/frenchWeb/nouns.csv'
nounsWeb <- readr::read_csv(file = nounsPath, locale = readr::locale(encoding = "utf8"))
nounsWeb <- nounsWeb[-1,]
nounsWeb <- nounsWeb[-1,]
names(nounsWeb)[1] <- 'key'
names(nounsWeb)[2] <- 'freq'
new_frequencies_nouns <- data.frame()
for (i in 1:nrow(nounsWeb)) {
  frequency <- nounsWeb[i, 2][[1]]
  numeric_freq <- as.numeric(frequency)
  print(numeric_freq)
  new_frequencies_nouns[i, 1][[1]] <- numeric_freq
}
new_frequencies_nouns <- head(new_frequencies_nouns, 10)
nouns_col_names <- head(nounsWeb$key, 10)
barplot(new_frequencies_nouns[,1], names.arg = nouns_col_names, col= "blue",
        main = "Most occurring nouns in web 2017 corpus", log="y", cex.names=0.7)


adjectivesPath <- '../Experiments/frenchWeb/adjectives.csv'
adjectivesWeb <- readr::read_csv(file = adjectivesPath, locale = readr::locale(encoding = "utf8"))
adjectivesWeb <- adjectivesWeb[-1,]
adjectivesWeb <- adjectivesWeb[-1,]
names(adjectivesWeb)[1] <- 'key'
names(adjectivesWeb)[2] <- 'freq'
new_frequencies_adjectives <- data.frame()
for (i in 1:nrow(adjectivesWeb)) {
  frequency <- adjectivesWeb[i, 2][[1]]
  numeric_freq <- as.numeric(frequency)
  new_frequencies_adjectives[i, 1][[1]] <- numeric_freq
}
new_frequencies_adjectives <- head(new_frequencies_adjectives, 10)
adjectives_col_names <- head(adjectivesWeb$key, 10)
barplot(new_frequencies_adjectives[,1], names.arg = adjectives_col_names, col= "blue",
        main = "Most occurring adjectives in web 2017 corpus", log="y", cex.names=0.5)

stopWords <- c(
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
)

bigramsPath <- '../Experiments/frenchWeb/bigrams.csv'
bigramsWeb <- readr::read_csv(file = bigramsPath, locale = readr::locale(encoding = "utf8"))

# bigrams

bigrams_separated_web <- bigramsWeb %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered_web <- bigrams_separated_web %>%
  filter(!word1 %in% stopWords) %>%
  filter(!word2 %in% stopWords)

# new bigram counts:
bigram_counts_web_filtered <- bigrams_filtered_web %>% 
  count(word1, word2, sort = TRUE)

bigrams_united_web <- bigrams_filtered_web %>%
  unite(bigram, word1, word2, sep = " ")

write.csv(bigram_counts_web_filtered,"C:\\Repos\\le_rap_francophone\\TextAnalysis\\Word Frequencies\\csvs\\french web\\bigrams_filtered.csv", row.names = FALSE)
