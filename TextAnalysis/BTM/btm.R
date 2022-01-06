#BTM for corpus 
library(udpipe)
library(data.table)
library(stopwords)

biterms <- as.data.table(annotation)
biterms <- biterms[, cooccurrence(x = lemma,
                                  relevant = upos %in% c("NOUN", "ADJ", "VERB") & 
                                    nchar(lemma) > 2 & !lemma %in% stopwords("fr"),
                                  skipgram = 3),
                   by = list(doc_id)]
library(BTM)
set.seed(123456)
traindata <- subset(annotation, upos %in% c("NOUN", "ADJ", "VERB") & !lemma %in% stopwords("fr") & nchar(lemma) > 2)
traindata <- traindata[, c("doc_id", "lemma")]
model     <- BTM(traindata, biterms = biterms, k = 15, iter = 2000, background = TRUE, trace = 100)

library(textplot)
library(ggraph)
library(concaveman)
biterms1 = terms(model, type = "biterms")$biterms

plot(model, subtitle = "Corpus", biterms = biterms1, labels = paste(round(model$theta * 100, 2), "%", sep = ""), top_n = 10)


#BTM for subcorpus 
biterms_subcorpus <- as.data.table(mediaWordsSubsetFullSongs_ns)
biterms_subcorpus <- biterms_subcorpus[, cooccurrence(x = lemma,
                                  relevant = upos %in% c("NOUN", "ADJ", "VERB") & 
                                    nchar(lemma) > 2 & !lemma %in% stopwords("fr"),
                                  skipgram = 3),
                   by = list(doc_id)]

set.seed(123456)
traindata_subcorpus <- subset(mediaWordsSubsetFullSongs_ns, upos %in% c("NOUN", "ADJ", "VERB") & !lemma %in% stopwords("fr") & nchar(lemma) > 2)
traindata_subcorpus <- traindata_subcorpus[, c("doc_id", "lemma")]
model_subcorpus     <- BTM(traindata_subcorpus, biterms = biterms_subcorpus, k = 8, iter = 2000, background = TRUE, trace = 100)
biterms2 = terms(model_subcorpus, type = "biterms")$biterms

plot(model_subcorpus, subtitle = "Subcorpus", biterms = biterms2, labels = paste(round(model$theta * 100, 2), "%", sep = ""), top_n = 8)


