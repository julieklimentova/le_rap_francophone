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
# clean descriptions from genius 
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

# TEXTRANK keywords

stats <- textrank_keywords(annotation$lemma, 
                           relevant = annotation$upos %in% c("NOUN", "ADJ"), 
                           ngram_max = 8, sep = " ")
statsKeywords <- subset(stats$keywords, ngram > 1 & freq >= 20)
library(wordcloud)
wordcloud(words = statsKeywords$keyword, freq = statsKeywords$freq)
wordcloud(words = mediaWords$key, freq = mediaWords$freq)


# RAKE 

keywordsRake <- keywords_rake(x = annotation, 
                       term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                       relevant = annotation$upos %in% c("NOUN", "ADJ"),
                       ngram_max = 4)
results <- head(subset(keywordsRake, freq > 3))


# TOPIC MODELLING NOUNS
## Define the identifier at which we will build a topic model
annotation$topic_level_id <- unique_identifier(annotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf <- subset(annotation, upos %in% c("NOUN"))
dtf <- document_term_frequencies(dtf, document = "topic_level_id", term = "lemma")
head(dtf)

## Create a document/term/matrix for building a topic model
dtm <- document_term_matrix(x = dtf)
## Remove words which do not occur that much
dtm_clean <- dtm_remove_lowfreq(dtm, minfreq = 5)
head(dtm_colsums(dtm_clean))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean <- dtm_remove_tfidf(dtm_clean, top = 50)

## Build topic models 
library(topicmodels)
models <- LDA(dtm_clean, k = 4, method = "Gibbs", 
         control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics <- tidy(models, matrix = "beta")

rap_top_terms <- rap_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()


# TOPIC MODELLING ADJECTIVES
## Define the identifier at which we will build a topic model
annotation$topic_level_id <- unique_identifier(annotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_adj <- subset(annotation, upos %in% c("ADJ"))
dtf_adj <- document_term_frequencies(dtf_adj, document = "topic_level_id", term = "lemma")
head(dtf_adj)

## Create a document/term/matrix for building a topic model
dtm_adj <- document_term_matrix(x = dtf_adj)
## Remove words which do not occur that much
dtm_clean_adj <- dtm_remove_lowfreq(dtm_adj, minfreq = 5)
head(dtm_colsums(dtm_clean_adj))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean_adj <- dtm_remove_tfidf(dtm_clean_adj, top = 50)

## Build topic models 
library(topicmodels)
models_adj <- LDA(dtm_clean_adj, k = 4, method = "Gibbs", 
              control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_adj <- tidy(models_adj, matrix = "beta")

rap_top_terms_adj <- rap_topics_adj %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_adj %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

# TOPIC MODELLING VERBS
## Define the identifier at which we will build a topic model
annotation$topic_level_id <- unique_identifier(annotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_verbs <- subset(annotation, upos %in% c("VERB"))
dtf_verbs <- document_term_frequencies(dtf_verbs, document = "topic_level_id", term = "lemma")
head(dtf_verbs)

## Create a document/term/matrix for building a topic model
dtm_verbs <- document_term_matrix(x = dtf_verbs)
## Remove words which do not occur that much
dtm_clean_verbs <- dtm_remove_lowfreq(dtm_verbs, minfreq = 5)
head(dtm_colsums(dtm_clean_verbs))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean_verbs <- dtm_remove_tfidf(dtm_clean_verbs, top = 50)

## Build topic models 
library(topicmodels)
models_verbs <- LDA(dtm_clean_verbs, k = 4, method = "Gibbs", 
                  control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_verbs <- tidy(models_verbs, matrix = "beta")

rap_top_terms_verbs <- rap_topics_verbs %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_verbs %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()


#Subsetting corpus only with media words 
mediaWordsForSubset <- mediaWords[['key']]
mediaWordsSubset <- subset(annotation, token %in% mediaWordsForSubset)
mediaWordsSongsIds <- unique(mediaWordsSubset$doc_id)
mediaWordsSongsIds_df <- data.frame(mediaWordsSongsIds)

mediaWordsSubsetFullSongs <- subset(annotation, doc_id %in% mediaWordsSongsIds)

# subset with media words 
mediaWordsSubsetLemmas <- data.frame(mediaWordsSubset$lemma)

nounsForCollocationMWS <- subset(mediaWordsSubset, upos %in% c("NOUN")) 
collocationsMWS <- keywords_collocation(x = nounsForCollocationMWS, 
                                     term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                     ngram_max = 4)
coocurrencesMWS <- cooccurrence(x = subset(mediaWordsSubset, upos %in% c("NOUN", "ADJ")), 
                             term = "lemma", group = c("doc_id", "paragraph_id", "sentence_id"))
## Co-occurrences: How frequent do words follow one another
followingMWS <- cooccurrence(x = mediaWordsSubset$lemma, 
                          relevant = mediaWordsSubset$upos %in% c("NOUN", "ADJ"))
## Co-occurrences: How frequent do words follow one another even if we would skip 2 words in between
followingSkippedMWS <- cooccurrence(x = mediaWordsSubset$lemma, 
                                 relevant = mediaWordsSubset$upos %in% c("NOUN", "ADJ"), skipgram = 2)

wordnetworkMWS <- head(followingSkippedMWS, 30)
wordnetworkMWS <- graph_from_data_frame(wordnetworkMWS)
ggraph(wordnetworkMWS, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "pink") +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "Arial") +
  theme(legend.position = "none") +
  labs(title = "Cooccurrences within 3 words distance", subtitle = "Nouns & Adjective MW subset")

#subset with full songs from media words subset
mediaWordsSubsetFullSongsLemmas <- data.frame(mediaWordsSubsetFullSongs$lemma)
nounsForCollocationMWFullSongs <- subset(mediaWordsSubsetFullSongs, upos %in% c("NOUN")) 
collocationsMWFullSongs <- keywords_collocation(x = nounsForCollocationMWFullSongs, 
                                        term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                        ngram_max = 4)
coocurrencesMWFullSongs <- cooccurrence(x = subset(mediaWordsSubsetFullSongs, upos %in% c("NOUN", "ADJ")), 
                                term = "lemma", group = c("doc_id", "paragraph_id", "sentence_id"))
## Co-occurrences: How frequent do words follow one another
followingMWFullSongs <- cooccurrence(x = mediaWordsSubsetFullSongs$lemma, 
                             relevant = mediaWordsSubsetFullSongs$upos %in% c("NOUN", "ADJ"))
## Co-occurrences: How frequent do words follow one another even if we would skip 2 words in between
followingSkippedMWFullSongs <- cooccurrence(x = mediaWordsSubsetFullSongs$lemma, 
                                    relevant = mediaWordsSubsetFullSongs$upos %in% c("NOUN", "ADJ"), skipgram = 2)

wordnetworkMWFullSongs <- head(followingSkippedMWFullSongs, 30)
wordnetworkMWFullSongs <- graph_from_data_frame(wordnetworkMWFullSongs)
ggraph(wordnetworkMWFullSongs, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "pink") +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "Arial") +
  theme(legend.position = "none") +
  labs(title = "Cooccurrences within 3 words distance", subtitle = "Nouns & Adjective MW Full Songs")
