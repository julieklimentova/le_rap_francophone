library(udpipe)
library(textrank)
library(tidyverse)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)
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
songsPath <- '../Experiments/metadata/songsMetadata.csv'
songs <- readr::read_csv(file = songsPath, locale = readr::locale(encoding = "latin1"))
# ud_model <- udpipe_download_model(language = "french-partut")
# ud_model <- udpipe_load_model(ud_model$file_model)
names(songs)[3] <- 'doc_id'
names(songs)[7] <- 'text'
for (i in 1:nrow(songs)) {
  song <- songs[i, 7][[1]]
  song <- tolower(song)
  songs[i, 7][[1]] <- gsub('\\[.*\\]','', song)
}

songsLyrics <- data.frame(doc_id = songs$doc_id, text = songs$text, stringsAsFactors = FALSE)
annotation <- udpipe(songsLyrics, './french-gsd-ud-2.5-191206.udpipe', parallel.cores = 2)
saveRDS(annotation, file = "anno.rds")

## Most occuring nouns 
nouns <- subset(annotation, upos %in% c("NOUN")) 
nouns_frequencies <- txt_freq(nouns$token)
nouns_frequencies$key <- factor(nouns_frequencies$key, levels = rev(nouns_frequencies$key))
barchart(key ~ freq, data = head(nouns_frequencies, 20), col = "cadetblue", 
         main = "Most occurring nouns", xlab = "Freq")

## Most occuring adjectives
adjectives <- subset(annotation, upos %in% c("ADJ")) 
adjectives_frequencies <- txt_freq(adjectives$token)
adjectives_frequencies$key <- factor(adjectives_frequencies$key, levels = rev(adjectives_frequencies$key))
barchart(key ~ freq, data = head(adjectives_frequencies, 20), col = "purple", 
         main = "Most occurring adjectives", xlab = "Freq")

## Most occuring verbs
verbs <- subset(annotation, upos %in% c("VERB")) 
verbs_frequencies <- txt_freq(verbs$token)
verbs_frequencies$key <- factor(verbs_frequencies$key, levels = rev(verbs_frequencies$key))
barchart(key ~ freq, data = head(verbs_frequencies, 20), col = "gold", 
         main = "Most occurring Verbs", xlab = "Freq")

## Most occuring words
words_frequencies <- txt_freq(annotation$token, exclude = stopWords)
words_frequencies$key <- factor(words_frequencies$key, levels = rev(words_frequencies$key))
barchart(key ~ freq, data = head(words_frequencies, 20), col = "cadetblue",
         main = "Most occurring words", xlab = "Freq")


Sys.getlocale()
# 
# new Media words frequencies
mediaWordsPath <- './nwmFrequencies/newMediaWordsFrequencies.csv'
mediaWords <- readr::read_csv(file = mediaWordsPath, locale = readr::locale(encoding = "latin1"))
mediaWords$key <- factor(mediaWords$key, levels = rev(mediaWords$key))
barchart(key ~ freq, data = head(mediaWords, 20), col = "cadetblue",
         main = "Most occurring media words", xlab = "Freq")


# subset with media words 
lemmas <- data.frame(annotation$lemma)

nounsForCollocation <- subset(annotation, upos %in% c("NOUN")) 
collocations <- keywords_collocation(x = nounsForCollocation, 
                              term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                              ngram_max = 4)
coocurrences <- cooccurrence(x = subset(annotation, upos %in% c("NOUN", "ADJ")), 
                      term = "lemma", group = c("doc_id", "paragraph_id", "sentence_id"))
## Co-occurrences: How frequent do words follow one another
following <- cooccurrence(x = annotation$lemma, 
                      relevant = annotation$upos %in% c("NOUN", "ADJ"))
## Co-occurrences: How frequent do words follow one another even if we would skip 2 words in between
followingSkipped <- cooccurrence(x = annotation$lemma, 
                      relevant = annotation$upos %in% c("NOUN", "ADJ"), skipgram = 2)

wordnetwork <- head(followingSkipped, 30)
wordnetwork <- graph_from_data_frame(wordnetwork)
ggraph(wordnetwork, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "pink") +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "Arial") +
  theme(legend.position = "none") +
  labs(title = "Cooccurrences within 3 words distance", subtitle = "Nouns & Adjective")

# wordclouds

stats <- textrank_keywords(annotation$lemma, 
                           relevant = annotation$upos %in% c("NOUN", "ADJ"), 
                           ngram_max = 8, sep = " ")
statsKeywords <- subset(stats$keywords, ngram > 1 & freq >= 5)
library(wordcloud)
wordcloud(words = statsKeywords$keyword, freq = statsKeywords$freq)
wordcloud(words = mediaWords$key, freq = mediaWords$freq)
# | 
#   'facebook'| 
#   'twitter' |
#   'poster' |
#   'poste' |
#   'taguer' |
#   'tag' |
#   'game' |
#   'système'|
#   'clique' |
#   'cliquer' |
#   'micro' |
#   'ami' |
#   'disque' |
#   'dj' |
#   'film' |
#   'buzz' |
#   'numéro' |
#   'télé' |
#   'midi' |
#   'net' |
#   'livre' |
#   'single' |  
#   'like' |
#   'microphone' |
#   'message' |
#   'code' |
#   'follow'|
#   'percer' |
#   'téléphone' |
#   'cd' |
#   'cro-mi' |
#   'photo' |
#   'internet' |
#   'vidéo' |
#   'écran' |
#   'clip' |
#   'phone' |
#   'partager'

