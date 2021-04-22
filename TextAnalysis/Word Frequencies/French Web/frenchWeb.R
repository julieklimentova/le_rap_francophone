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
