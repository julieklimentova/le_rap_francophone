library(tidyverse)
library(stringr)
dataPath <- file.path("..", "Experiments", "metadata", "songsMetadata.csv")
termsPath <- file.path("..", "Experiments", "metadata", "mediaWords.csv")
songsWritePath <- file.path("..", "Experiments", "metadata", "songsMetadataWithFrequencies.csv")
songs <- readr::read_csv(dataPath)
rownames(songs) <- songs[ , 3]
newMediaTerms <- readr::read_csv(termsPath)
# subcorpusFolderPath <- "./newMediaSubcorpus"
# dir.create(subcorpusFolderPath)
# termsFrequencies <- data.frame(matrix(nrow = 0, ncol = 2))
names(songs)[1] <- "geniusArtistId"
names(songs)[2] <- "artistName"
names(songs)[3] <- "corpusSongId"
names(songs)[4] <- "songName"
names(songs)[5] <- "geniusSongId"
names(songs)[6] <- "songLink"
names(songs)[7] <- "songLyrics"
names(songs)[8] <- "date"

for(s in 1:nrow(songs)) { # for all songs rows
  songId <- songs[s, 3][1]
  songId <- gsub("[[:space:]]", "", songId)
  print(songId)
  for (nc in 1:ncol(newMediaTerms)) { # for all terms columns
    for(nr in 1:nrow(newMediaTerms)) { # for all terms rows
      term <- newMediaTerms[nr, nc][[1]] # assign term variable
      term <- gsub("[[:space:]]", "", term)
      term <- tolower(term)
      print(paste('term: ', term))
      if (!is.na(term)) { # if term is not NA
        songText <- songs[s, 7][[1]]  #  assign songText
        songTextCleared <- gsub("'", " ", songText) # exchange apostrof for empty space to separate shortened words
        songTextCleared <- gsub("`", " ", songTextCleared)
        songTextCleared <- gsub("\"", " ", songTextCleared)
        songTextVector <- tolower(songTextCleared)
        songTextVector <- strsplit(songTextVector, "\\s+")[[1]]
        searchPattern <- regex(paste0('\\<',term,'\\>'))
        print(paste('searchPattern:', searchPattern))
        termCount <- length(grep(searchPattern, songTextVector)) # count number of occurences
        print(paste('termCount: ', termCount))
        songs[songs$corpusSongId==songId, term] <- termCount
        print(paste('added term for songId: ', songId))
      }
    }
  }
}

# for(i in 1:ncol(newMediaTerms)) {       # for-loop over columns
#   for(j in 1:nrow(newMediaTerms)) {     # for loop over rows
#       term <- newMediaTerms[j, i][[1]]  # assigning the term variable
#       print(term)
#       if (!is.na(term)) {               # if  term is not NA
#         for(k in 1:nrow(songs)) {       # loop over songs rows
#           songId <- songs[k, 3][[1]]    # assign songId 
#           artistName <- songs [k, 2]    # assign songName
#           songText <- songs[k, 7][[1]]  #  assign songText
#           songTextCleared <- gsub("'", " ", songText) # exchange apostrof for empty space to separate shortened words
#           gsub("`", " ", songTextCleared)
#           searchPattern <- paste0('\\', term ,'\\b')
#           print(paste('searchPattern:', searchPattern))
#           termCount <- str_count(songText, searchPattern) # count number of occurences
#           print(paste('termCount: ', termCount))
#           if (songId %in% termsFrequencies[ , 1]) {  # if songId already in termFrequencies
#             # find songId row 
#             # find term column (or create term column if not present)
#             # add termCount
#             termsFrequencies[termsFrequencies$songId==songId, term] <- termCount
#             print(paste('added term into row already present for songId: ', songId))
#           } else {
#             # else create row add songId, artistId, term column and term count
#             if (nrow(termsFrequencies) == 0) {
#               print('Iam inside if')
#             termsFrequencies[1, termsFrequencies$songId] <- songId
#             termsFrequencies[1, termsFrequencies$artistName] <- artistName
#               termsFrequencies[1, term] <- termCount 
#               print(paste('added term into row for songId: ', songId))
#             } else {
#               rowIndex <- nrow(termsFrequencies) + 1
#               termsFrequencies[rowIndex, termsFrequencies$songId] <- songId
#               termsFrequencies[rowIndex, termsFrequencies$artistName] <- artistName
#               termsFrequencies[rowIndex, term] <- termCount 
#               print(paste('added term into row for songId: ', songId))
#             }
#           }
#           # if termCount > 0 && no file in subcorpus folder 
#           # add file to subf
#         }
#       }
#     }
# }


write.csv(songs, songsWritePath, row.names = FALSE)


