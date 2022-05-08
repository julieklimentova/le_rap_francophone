library(tm)
# on the media words subset/can be exchanged for songs if wanting to model the main corpus 
songsVector <- mediaWordsSubsetFullSongs_SONGS_ns$text

songsVector <- gsub("[[:punct:]]", " ", songsVector)  # replace punctuation with space
songsVector <- gsub("[[:punct:]]", " ", songsVector)  # replace punctuation with space
songsVector <- gsub("[[:cntrl:]]", " ", songsVector)  # replace control characters with space
songsVector <- gsub("^[[:space:]]+", "", songsVector) # remove whitespace at beginning of documents
songsVector <- gsub("[[:space:]]+$", "", songsVector) # remove whitespace at end of documents
songsVector <- tolower(songsVector)  # force to lowercase

doc.list <- strsplit(songsVector, "[[:space:]]+")
doc.list[] <- lapply(doc.list, function(x) x[!x %in% ""])
doc.list[] <- lapply(doc.list, function(x) x[!x %in% stopWords])


# compute the table of terms:
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)


# remove terms that are stop words or occur fewer than 5 times:
# del <- names(term.table) %in% stopWords | term.table < 5
del <- names(term.table) %in% stopWords
term.table <- term.table[!del]
vocab <- names(term.table)
head(vocab, 69)

# now put the documents into the format required by the lda package:
get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms)

# Compute some statistics related to the data set:
D <- length(documents)  # number of documents 
W <- length(vocab)  # number of terms in the vocab 
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document 
N <- sum(doc.length)  # total number of tokens in the data
term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus

# MCMC and model tuning parameters:
K <- 15
G <- 5000
alpha <- 0.02
eta <- 0.02

# Fit the model:
library(lda)
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
t2 - t1  # about 24 minutes on laptop

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

# 
# Sys.setenv(LANGUAGE="fr")
# Sys.setlocale("LC_CTYPE","fr_FR.UTF-8")
# Sys.setlocale("LC_ALL", locale = "fr_FR.UTF-8")
# Sys.getlocale()

SongsForLDA <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

library(LDAvis)

# create the JSON object to feed the visualization:
json <- createJSON(phi = SongsForLDA$phi, 
                   theta = SongsForLDA$theta, 
                   doc.length = SongsForLDA$doc.length, 
                   vocab = SongsForLDA$vocab, 
                   term.frequency = SongsForLDA$term.frequency)

serVis(json, out.dir = 'vis', open.browser = TRUE)
