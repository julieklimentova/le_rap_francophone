library(udpipe)
library(textrank)
library(tidyverse)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)



#Subsetting corpus only with media words 
mediaWordsForSubset <- mediaWords[['key']]
mediaWordsSubset <- subset(annotation, token %in% mediaWordsForSubset)
mediaWordsSongsIds <- unique(mediaWordsSubset$doc_id)
mediaWordsSongsIds_df <- data.frame(mediaWordsSongsIds)

mediaWordsSubsetFullSongs <- subset(annotation, doc_id %in% mediaWordsSongsIds)
mediaWordsSubsetFullSongs_SONGS <- subset(songs, doc_id %in% mediaWordsSongsIds)

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


## working with no ambiguous words subcorpus
# new Media words frequencies
mediaWordsPath_ns <- './nwmFrequencies/newMediaWordsFrequencies_noSoft.csv'
mediaWords_ns <- readr::read_csv(file = mediaWordsPath_ns, locale = readr::locale(encoding = "latin1"))
mediaWords_ns$key <- factor(mediaWords_ns$key, levels = rev(mediaWords_ns$key))
barchart(key ~ freq, data = head(mediaWords_ns, 10), col = "cadetblue",
         main = "Most occurring media words (no ambiguous words)", xlab = "Freq", aspect = 0.4)

#Subsetting corpus only with media words 
mediaWordsForSubset_ns <- mediaWords_ns[['key']]
mediaWordsSubset_ns <- subset(annotation, token %in% mediaWordsForSubset_ns)
mediaWordsSongsIds_ns <- unique(mediaWordsSubset_ns$doc_id)
mediaWordsSongsIds__ns_df <- data.frame(mediaWordsSongsIds_ns)

mediaWordsSubsetFullSongs_ns <- subset(annotation, doc_id %in% mediaWordsSongsIds_ns)
mediaWordsSubsetFullSongs_ns_SONGS <- subset(songs, doc_id %in% mediaWordsSongsIds_ns)

Sys.setlocale(category = "LC_ALL", locale = "English_United States.1252")
Sys.setlocale(category = "LC_ALL", locale = "UTF-8")
Sys.setenv(LANGUAGE="fr")
Sys.getlocale()
#Word frequencies
## Most occuring nouns 
nounsNs <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN")) 
nouns_frequenciesNs <- txt_freq(nounsNs$lemma)
nouns_frequenciesNs$key <- factor(nouns_frequenciesNs$key, levels = rev(nouns_frequenciesNs$key))
barchart(key ~ freq, data = head(nouns_frequenciesNs, 10), col = "orange", 
         main = "Most frequent nouns in subcorpus", xlab = "Freq")

## Most occuring adjectives
adjectivesNs <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("ADJ")) 
adjectives_frequenciesNs <- txt_freq(adjectivesNs$lemma)
adjectives_frequenciesNs$key <- factor(adjectives_frequenciesNs$key, levels = rev(adjectives_frequenciesNs$key))
barchart(key ~ freq, data = head(adjectives_frequenciesNs, 10), col = "orange", 
         main = "Most frequent adjectives in subcorpus", xlab = "Freq")

## Most occuring verbs
verbsNs <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("VERB")) 
verbs_frequenciesNs <- txt_freq(verbsNs$lemma)
verbs_frequenciesNs$key <- factor(verbs_frequenciesNs$key, levels = rev(verbs_frequenciesNs$key))
barchart(key ~ freq, data = head(verbs_frequenciesNs, 10), col = "orange", 
         main = "Most frequent verbs in subcorpus", xlab = "Freq")

# Collocations
lemmas_ns <- data.frame(mediaWordsSubsetFullSongs_ns$lemma)

nounsForCollocation_ns <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN")) 
collocations_ns <- keywords_collocation(x = nounsForCollocation_ns, 
                                        term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                        ngram_max = 4)
coocurrences_ns <- cooccurrence(x = subset(mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN", "ADJ")), 
                                term = "lemma", group = c("doc_id", "paragraph_id", "sentence_id"))
## Co-occurrences: How frequent do words follow one another
following_ns <- cooccurrence(x = mediaWordsSubsetFullSongs_ns$lemma, 
                             relevant = mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"))
## Co-occurrences: How frequent do words follow one another even if we would skip 2 words in between
followingSkipped_ns <- cooccurrence(x = mediaWordsSubsetFullSongs_ns$lemma, 
                                    relevant = mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"), skipgram = 2)

wordnetwork_ns <- head(followingSkipped_ns, 30)
wordnetwork_ns <- graph_from_data_frame(wordnetwork_ns)
ggraph(wordnetwork_ns, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "pink") +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "Arial") +
  theme(legend.position = "none") +
  labs(title = "Cooccurrences within 3 words distance (new media words - no ambiguity)", subtitle = "Nouns & Adjective")

# TEXTRANK keywords

stats_ns <- textrank_keywords(mediaWordsSubsetFullSongs_ns$lemma, 
                              relevant = mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"), 
                              ngram_max = 8, sep = " ")
statsKeywords_ns <- subset(stats_ns$keywords, ngram > 1 & freq >= 20)
library(wordcloud)
wordcloud(words = statsKeywords_ns$keyword, freq = statsKeywords_ns$freq)
wordcloud(words = mediaWords_ns$key, freq = mediaWords_ns$freq)


library(udpipe)
# RAKE 

keywordsRake_ns <- keywords_rake(x = mediaWordsSubsetFullSongs_ns, 
                                 term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                 relevant = mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"),
                                 ngram_max = 4)
results_ns <- head(subset(keywordsRake_ns, freq > 3))

keywordsRake_ns_2 <- keywords_rake(x = mediaWordsSubsetFullSongs_ns, 
                                   term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                   relevant = mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"),
                                   ngram_max = 2)
results_ns_2 <- head(subset(keywordsRake_ns_2, freq > 3 & ngram > 1))
results_ns$keyword <- factor(results_ns$keyword, levels = rev(results_ns$keyword))

barchart(keyword ~ rake, data = results_ns, col = "cadetblue",
         main = "Rake ngram keywords", xlab = "rake")

results_ns_2$keyword <- factor(results_ns_2$keyword, levels = rev(results_ns_2$keyword))
barchart(keyword ~ rake, data = results_ns_2, col = "cadetblue",
         main = "Rake bigram keywords", xlab = "rake")

# TOPIC MODELLING NOUNS
## Define the identifier at which we will build a topic model
mediaWordsSubsetFullSongs_ns$topic_level_id <- unique_identifier(mediaWordsSubsetFullSongs_ns, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_ns <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN"))
dtf_ns <- document_term_frequencies(dtf_ns, document = "topic_level_id", term = "lemma")
head(dtf_ns)

## Create a document/term/matrix for building a topic model
dtm_ns <- document_term_matrix(x = dtf_ns)
## Remove words which do not occur that much
dtm_clean_ns <- dtm_remove_lowfreq(dtm_ns, minfreq = 5)
head(dtm_colsums(dtm_clean_ns))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean_ns <- dtm_remove_tfidf(dtm_clean_ns, top = 50)

## Build topic models 
library(topicmodels)
models_ns <- LDA(dtm_clean_ns, k = 4, method = "Gibbs", 
                 control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_ns <- tidy(models_ns, matrix = "beta")

rap_top_terms_ns <- rap_topics_ns %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_ns %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()


# TOPIC MODELLING ADJECTIVES
## Define the identifier at which we will build a topic model
mediaWordsSubsetFullSongs_ns$topic_level_id <- unique_identifier(mediaWordsSubsetFullSongs_ns, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_adj_ns <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("ADJ"))
dtf_adj_ns <- document_term_frequencies(dtf_adj_ns, document = "topic_level_id", term = "lemma")
head(dtf_adj_ns)

## Create a document/term/matrix for building a topic model
dtm_adj_ns <- document_term_matrix(x = dtf_adj_ns)
## Remove words which do not occur that much
dtm_clean_adj_ns <- dtm_remove_lowfreq(dtm_adj_ns, minfreq = 5)
head(dtm_colsums(dtm_clean_adj_ns))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean_adj_ns <- dtm_remove_tfidf(dtm_clean_adj_ns, top = 50)

## Build topic models 
library(topicmodels)
models_adj_ns <- LDA(dtm_clean_adj_ns, k = 4, method = "Gibbs", 
                     control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_adj_ns <- tidy(models_adj_ns, matrix = "beta")

rap_top_terms_adj_ns <- rap_topics_adj_ns %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_adj_ns %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

# TOPIC MODELLING VERBS
## Define the identifier at which we will build a topic model
mediaWordsSubsetFullSongs_ns$topic_level_id <- unique_identifier(mediaWordsSubsetFullSongs_ns, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_verbs_ns <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("VERB"))
dtf_verbs_ns <- document_term_frequencies(dtf_verbs_ns, document = "topic_level_id", term = "lemma")
head(dtf_verbs_ns)

## Create a document/term/matrix for building a topic model
dtm_verbs_ns <- document_term_matrix(x = dtf_verbs_ns)
## Remove words which do not occur that much
dtm_clean_verbs_ns <- dtm_remove_lowfreq(dtm_verbs_ns, minfreq = 5)
head(dtm_colsums(dtm_clean_verbs_ns))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_clean_verbs_ns <- dtm_remove_tfidf(dtm_clean_verbs_ns, top = 50)

## Build topic models 
library(topicmodels)
models_verbs_ns <- LDA(dtm_clean_verbs_ns, k = 4, method = "Gibbs", 
                       control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_verbs_ns <- tidy(models_verbs_ns, matrix = "beta")

rap_top_terms_verbs_ns <- rap_topics_verbs_ns %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_verbs_ns %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

library(tidytext)
mediaWordsSubsetFullSongs_SONGS_ns <- subset(songs, songShortcut %in% mediaWordsSongsIds_ns)
mediaWordsSubset_bigrams <- mediaWordsSubsetFullSongs_SONGS_ns %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

mw_bigram_counts <- mediaWordsSubset_bigrams %>%
  count(bigram, sort = TRUE)

library(tidyr)

mw_bigrams_separated <- mediaWordsSubset_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

mw_bigrams_filtered <- mw_bigrams_separated %>%
  filter(!word1 %in% stopWords) %>%
  filter(!word2 %in% stopWords)

# new bigram counts:
mw_bigram_counts <- mw_bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

mw_bigrams_united <- mw_bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")

mw_bigram_tf_idf <- mw_bigrams_united %>%
  count(songShortcut, bigram) %>%
  bind_tf_idf(bigram, songShortcut, n) %>%
  arrange(desc(tf_idf))

write.csv(mw_bigram_counts,"C:\\Repos\\le_rap_francophone\\TextAnalysis\\Word Frequencies\\csvs\\media words subcorpus\\bigrams_counts.csv", row.names = FALSE)


# Subsetting years on

library(data.table)
songsDataTable = data.table(songs)
ninetiesSubset = songsDataTable[releaseDate %like% '1990'
                                | releaseDate %like% '1991'
                                | releaseDate %like% '1992'
                                | releaseDate %like% '1993'
                                | releaseDate %like% '1994'
                                | releaseDate %like% '1995'
                                | releaseDate %like% '1996'
                                | releaseDate %like% '1997'
                                | releaseDate %like% '1998'
                                | releaseDate %like% '1999'
]

zerosSubset = songsDataTable[releaseDate %like% '2000'
                             | releaseDate %like% '2001'
                             | releaseDate %like% '2002'
                             | releaseDate %like% '2003'
                             | releaseDate %like% '2004'
                             | releaseDate %like% '2005'
                             | releaseDate %like% '2006'
                             | releaseDate %like% '2007'
                             | releaseDate %like% '2008'
                             | releaseDate %like% '2009']

tensSubset = songsDataTable[releaseDate %like% '2010'
                            | releaseDate %like% '2011'
                            | releaseDate %like% '2012'
                            | releaseDate %like% '2013'
                            | releaseDate %like% '2014'
                            | releaseDate %like% '2015'
                            | releaseDate %like% '2016'
                            | releaseDate %like% '2017'
                            | releaseDate %like% '2018'
                            | releaseDate %like% '2019'
                            | releaseDate %like% '2020'
]

ninetiesAnnotation <- udpipe(ninetiesSubset, './french-gsd-ud-2.5-191206.udpipe', parallel.cores = 2)
saveRDS(annotation, file = "ninetiesAnno.rds")
#Subsetting corpus only with media words NINETIES
nineties_mediaWordsSubset_ns <- subset(ninetiesAnnotation, token %in% mediaWordsForSubset_ns)
nineties_mediaWordsSongsIds_ns <- unique(nineties_mediaWordsSubset_ns$doc_id)
nineties_mediaWordsSongsIds__ns_df <- data.frame(nineties_mediaWordsSongsIds_ns)

nineties_mediaWordsSubsetFullSongs_ns <- subset(ninetiesAnnotation, doc_id %in% nineties_mediaWordsSongsIds_ns)

# Word frequencies Nineties 

## Most occuring nouns Nineties
ninetiesNouns <- subset(nineties_mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN")) 
nineties_nouns_frequencies <- txt_freq(ninetiesNouns$token)
nineties_nouns_frequencies$key <- factor(nineties_nouns_frequencies$key, levels = rev(nineties_nouns_frequencies$key))
barchart(key ~ freq, data = head(nineties_nouns_frequencies, 20), col = "cadetblue", 
         main = "Most occurring nouns in the nineties subcorpus", xlab = "Freq")

## Most occuring adjectives Nineties
nineties_adjectives <- subset(nineties_mediaWordsSubsetFullSongs_ns, upos %in% c("ADJ")) 
nineties_adjectives_frequencies <- txt_freq(nineties_adjectives$token)
nineties_adjectives_frequencies$key <- factor(nineties_adjectives_frequencies$key, levels = rev(nineties_adjectives_frequencies$key))
barchart(key ~ freq, data = head(nineties_adjectives_frequencies, 20), col = "purple", 
         main = "Most occurring adjectives in the nineties subcorpus", xlab = "Freq")

## Most occuring verbs Nineties
nineties_verbs <- subset(nineties_mediaWordsSubsetFullSongs_ns, upos %in% c("VERB")) 
nineties_verbs_frequencies <- txt_freq(nineties_verbs$token)
nineties_verbs_frequencies$key <- factor(nineties_verbs_frequencies$key, levels = rev(nineties_verbs_frequencies$key))
barchart(key ~ freq, data = head(nineties_verbs_frequencies, 20), col = "gold", 
         main = "Most occurring Verbs in the nineties subcorpus", xlab = "Freq")

# Word frequencies media words Nineties
nineties_mediaWords_ns_frequencies <- txt_freq(nineties_mediaWordsSubset_ns$token)
nineties_mediaWords_ns_frequencies$key <- factor(nineties_mediaWords_ns_frequencies$key, levels = rev(nineties_mediaWords_ns_frequencies$key))
barchart(key ~ freq, data = head(nineties_mediaWords_ns_frequencies, 20), col = "gold", 
         main = "Most occurring media words in the nineties subcorpus", xlab = "Freq")


# Topic modeling Nineties - NOUNS 
# TOPIC MODELLING NOUNS
## Define the identifier at which we will build a topic model
ninetiesAnnotation$topic_level_id <- unique_identifier(ninetiesAnnotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_nineties <- subset(ninetiesAnnotation, upos %in% c("NOUN"))
dtf_nineties <- document_term_frequencies(dtf_nineties, document = "topic_level_id", term = "lemma")
head(dtf_nineties)

## Create a document/term/matrix for building a topic model
dtm_nineties <- document_term_matrix(x = dtf_nineties)
## Remove words which do not occur that much
dtm_nineties_clean <- dtm_remove_lowfreq(dtm_nineties, minfreq = 5)
head(dtm_colsums(dtm_nineties_clean))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_nineties_clean <- dtm_remove_tfidf(dtm_nineties_clean, top = 50)

## Build topic models 
library(topicmodels)
nineties_models <- LDA(dtm_nineties_clean, k = 4, method = "Gibbs", 
                       control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_nineties <- tidy(nineties_models, matrix = "beta")

rap_top_terms_nineties <- rap_topics_nineties %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_nineties %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

# RAKE Nineties

keywordsRakeNineties <- keywords_rake(x = nineties_mediaWordsSubsetFullSongs_ns, 
                                      term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                      relevant = nineties_mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"),
                                      ngram_max = 4)
resultsNineties <- head(subset(keywordsRakeNineties, freq > 3))
resultsNineties$keyword <- factor(resultsNineties$keyword, levels = rev(resultsNineties$keyword))

barchart(keyword ~ rake, data = resultsNineties, col = "cadetblue",
         main = "Nineties Rake ngram keywords", xlab = "rake")


zerosAnnotation <- udpipe(zerosSubset, './french-gsd-ud-2.5-191206.udpipe', parallel.cores = 2)
saveRDS(annotation, file = "zerosAnno.rds")

#Subsetting corpus only with media words ZEROS
zeros_mediaWordsSubset_ns <- subset(zerosAnnotation, token %in% mediaWordsForSubset_ns)
zeros_mediaWordsSongsIds_ns <- unique(zeros_mediaWordsSubset_ns$doc_id)
zeros_mediaWordsSongsIds__ns_df <- data.frame(zeros_mediaWordsSongsIds_ns)

zeros_mediaWordsSubsetFullSongs_ns <- subset(zerosAnnotation, doc_id %in% zeros_mediaWordsSongsIds_ns)


# Word frequencies Zeros 

## Most occuring nouns Zeros
zerosNouns <- subset(zeros_mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN")) 
zeros_nouns_frequencies <- txt_freq(zerosNouns$token)
zeros_nouns_frequencies$key <- factor(zeros_nouns_frequencies$key, levels = rev(zeros_nouns_frequencies$key))
barchart(key ~ freq, data = head(zeros_nouns_frequencies, 20), col = "cadetblue", 
         main = "Most occurring nouns in the 2000s subcorpus", xlab = "Freq")

## Most occuring adjectives zeros
zeros_adjectives <- subset(zeros_mediaWordsSubsetFullSongs_ns, upos %in% c("ADJ")) 
zeros_adjectives_frequencies <- txt_freq(zeros_adjectives$token)
zeros_adjectives_frequencies$key <- factor(zeros_adjectives_frequencies$key, levels = rev(zeros_adjectives_frequencies$key))
barchart(key ~ freq, data = head(zeros_adjectives_frequencies, 20), col = "purple", 
         main = "Most occurring adjectives in the 2000s subcorpus", xlab = "Freq")

## Most occuring verbs zeros
zeros_verbs <- subset(zeros_mediaWordsSubsetFullSongs_ns, upos %in% c("VERB")) 
zeros_verbs_frequencies <- txt_freq(zeros_verbs$token)
zeros_verbs_frequencies$key <- factor(zeros_verbs_frequencies$key, levels = rev(zeros_verbs_frequencies$key))
barchart(key ~ freq, data = head(zeros_verbs_frequencies, 20), col = "gold", 
         main = "Most occurring Verbs in the 2000s subcorpus", xlab = "Freq")

# Word frequencies media words zeros
zeros_mediaWords_ns_frequencies <- txt_freq(zeros_mediaWordsSubset_ns$token)
zeros_mediaWords_ns_frequencies$key <- factor(zeros_mediaWords_ns_frequencies$key, levels = rev(zeros_mediaWords_ns_frequencies$key))
barchart(key ~ freq, data = head(zeros_mediaWords_ns_frequencies, 20), col = "gold", 
         main = "Most occurring media words in the 2000s subcorpus", xlab = "Freq")


# Topic modeling zeros - NOUNS 
# TOPIC MODELLING NOUNS
## Define the identifier at which we will build a topic model
zerosAnnotation$topic_level_id <- unique_identifier(zerosAnnotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_zeros <- subset(zerosAnnotation, upos %in% c("NOUN"))
dtf_zeros <- document_term_frequencies(dtf_zeros, document = "topic_level_id", term = "lemma")
head(dtf_zeros)

## Create a document/term/matrix for building a topic model
dtm_zeros <- document_term_matrix(x = dtf_zeros)
## Remove words which do not occur that much
dtm_zeros_clean <- dtm_remove_lowfreq(dtm_zeros, minfreq = 5)
head(dtm_colsums(dtm_zeros_clean))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_zeros_clean <- dtm_remove_tfidf(dtm_zeros_clean, top = 50)

## Build topic models 
library(topicmodels)
zeros_models <- LDA(dtm_zeros_clean, k = 4, method = "Gibbs", 
                    control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_zeros <- tidy(zeros_models, matrix = "beta")

rap_top_terms_zeros <- rap_topics_zeros %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_zeros %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

keywordsRakeZeros <- keywords_rake(x = zeros_mediaWordsSubsetFullSongs_ns, 
                                   term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                   relevant = zeros_mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"),
                                   ngram_max = 4)
resultsZeros <- head(subset(keywordsRakeZeros, freq > 3))

resultsZeros$keyword <- factor(resultsZeros$keyword, levels = rev(resultsZeros$keyword))

barchart(keyword ~ rake, data = resultsZeros, col = "cadetblue",
         main = "2000s Rake ngram keywords", xlab = "rake")
tensAnnotation <- udpipe(tensSubset, './french-gsd-ud-2.5-191206.udpipe', parallel.cores = 2)
saveRDS(annotation, file = "tensAnno.rds")

#Subsetting corpus only with media words TENS
tens_mediaWordsSubset_ns <- subset(tensAnnotation, token %in% mediaWordsForSubset_ns)
tens_mediaWordsSongsIds_ns <- unique(tens_mediaWordsSubset_ns$doc_id)
tens_mediaWordsSongsIds__ns_df <- data.frame(tens_mediaWordsSongsIds_ns)

tens_mediaWordsSubsetFullSongs_ns <- subset(tensAnnotation, doc_id %in% tens_mediaWordsSongsIds_ns)

# Word frequencies tens 

## Most occuring nouns tens

## Most occuring nouns tens
tensNouns <- subset(tens_mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN")) 
tens_nouns_frequencies <- txt_freq(tensNouns$token)
tens_nouns_frequencies$key <- factor(tens_nouns_frequencies$key, levels = rev(tens_nouns_frequencies$key))
barchart(key ~ freq, data = head(tens_nouns_frequencies, 20), col = "cadetblue", 
         main = "Most occurring nouns in the 2010s subcorpus", xlab = "Freq")

## Most occuring adjectives tens
tens_adjectives <- subset(tens_mediaWordsSubsetFullSongs_ns, upos %in% c("ADJ")) 
tens_adjectives_frequencies <- txt_freq(tens_adjectives$token)
tens_adjectives_frequencies$key <- factor(tens_adjectives_frequencies$key, levels = rev(tens_adjectives_frequencies$key))
barchart(key ~ freq, data = head(tens_adjectives_frequencies, 20), col = "purple", 
         main = "Most occurring adjectives in the 2010s subcorpus", xlab = "Freq")

## Most occuring verbs tens
tens_verbs <- subset(tens_mediaWordsSubsetFullSongs_ns, upos %in% c("VERB")) 
tens_verbs_frequencies <- txt_freq(tens_verbs$token)
tens_verbs_frequencies$key <- factor(tens_verbs_frequencies$key, levels = rev(tens_verbs_frequencies$key))
barchart(key ~ freq, data = head(tens_verbs_frequencies, 20), col = "gold", 
         main = "Most occurring Verbs in the 2010s subcorpus", xlab = "Freq")

# Word frequencies media words tens
tens_mediaWords_ns_frequencies <- txt_freq(tens_mediaWordsSubset_ns$token)
tens_mediaWords_ns_frequencies$key <- factor(tens_mediaWords_ns_frequencies$key, levels = rev(tens_mediaWords_ns_frequencies$key))
barchart(key ~ freq, data = head(tens_mediaWords_ns_frequencies, 20), col = "gold", 
         main = "Most occurring media words in the 2010s subcorpus", xlab = "Freq")


# Topic modeling tens - NOUNS 
# TOPIC MODELLING NOUNS
## Define the identifier at which we will build a topic model
tensAnnotation$topic_level_id <- unique_identifier(tensAnnotation, fields = c("doc_id", "paragraph_id", "sentence_id"))
## Get a data.frame with 1 row per id/lemma
dtf_tens <- subset(tensAnnotation, upos %in% c("NOUN"))
dtf_tens <- document_term_frequencies(dtf_tens, document = "topic_level_id", term = "lemma")
head(dtf_tens)

## Create a document/term/matrix for building a topic model
dtm_tens <- document_term_matrix(x = dtf_tens)
## Remove words which do not occur that much
dtm_tens_clean <- dtm_remove_lowfreq(dtm_tens, minfreq = 5)
head(dtm_colsums(dtm_tens_clean))

## Or keep of these nouns the top 50 based on mean term-frequency-inverse document frequency
dtm_tens_clean <- dtm_remove_tfidf(dtm_tens_clean, top = 50)

## Build topic models 
library(topicmodels)
tens_models <- LDA(dtm_tens_clean, k = 4, method = "Gibbs", 
                   control = list(nstart = 5, burnin = 2000, best = TRUE, seed = 1:5))

library(tidytext)
rap_topics_tens <- tidy(tens_models, matrix = "beta")

rap_top_terms_tens <- rap_topics_tens %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

rap_top_terms_tens %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()

keywordsRakeTens <- keywords_rake(x = tens_mediaWordsSubsetFullSongs_ns, 
                                  term = "token", group = c("doc_id", "paragraph_id", "sentence_id"),
                                  relevant = tens_mediaWordsSubsetFullSongs_ns$upos %in% c("NOUN", "ADJ"),
                                  ngram_max = 4)
resultsTens <- head(subset(keywordsRakeTens, freq > 3))
resultsTens$keyword <- factor(resultsTens$keyword, levels = rev(resultsTens$keyword))

barchart(keyword ~ rake, data = resultsTens, col = "cadetblue",
         main = "2010s Rake ngram keywords", xlab = "rake")
