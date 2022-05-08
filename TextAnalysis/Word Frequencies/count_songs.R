library(stringr)

uniqueMwSongs <- data.frame(songs = unique(mediaWordsSubset_ns$doc_id))
uniqueMwSongs$counts <- ""

for (i in 1:nrow(mediaWordsSubset_ns)) {
    mediaWordsSubset_ns[i, 1] <- paste("a", mediaWordsSubset_ns[i, 1], "a", sep="" )
}
for (i in 1:nrow(uniqueMwSongs)) {
  songId <- paste("a", uniqueMwSongs[i, 1], "a", sep="")
  count <- length(grep(songId,mediaWordsSubset_ns$doc_id))
  uniqueMwSongs[i, 2]<- count
}

write.csv(uniqueMwSongs, "C:\\Repos\\le_rap_francophone\\TextAnalysis\\Word Frequencies\\csvs\\media words subcorpus\\mediasongscount2.csv")
