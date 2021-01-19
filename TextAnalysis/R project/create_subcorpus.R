library(tidyverse)
data_path <- file.path("..", "Experiments", "metadata", "songsMetadata.csv")

songs <- readr::read.csv(data_path, fileEncoding = "UTF-8-BOM")


