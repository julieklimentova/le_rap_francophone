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
model     <- BTM(traindata, biterms = biterms, k = 15, iter = 2000, background = TRUE, trace = 100, detailed = TRUE)

library(textplot)
library(ggraph)
library(concaveman)
biterms1 = terms(model, type = "biterms")$biterms

plot(model, subtitle = "Corpus", biterms = biterms1, labels = paste(round(model$theta * 100, 2), "%", sep = ""), top_n = 10)

library(LDAvis)
corpus_docsize <- table(traindata$doc_id)
corpus_scores <- predict(model, traindata)
corpus_scores <- corpus_scores[names(corpus_docsize), ]
corpus_json <- createJSON(
  phi = t(model$phi),
  theta = corpus_scores,
  doc.length = as.integer(corpus_docsize),
  vocab = model$vocabulary$token,
  term.frequency = model$vocabulary$freq)
serVis(corpus_json)


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

subcorpus_docsize <- table(traindata_subcorpus$doc_id)
subcorpus_scores <- predict(model_subcorpus, traindata_subcorpus)
subcorpus_scores <- subcorpus_scores[names(subcorpus_docsize), ]
subcorpus_json <- createJSON(
  phi = t(model_subcorpus$phi),
  theta = subcorpus_scores,
  doc.length = as.integer(subcorpus_docsize),
  vocab = model_subcorpus$vocabulary$token,
  term.frequency = model_subcorpus$vocabulary$freq)
serVis(subcorpus_json)
