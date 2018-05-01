library(tm)
library(wordcloud)
library(SnowballC)


reflateOutcomes = function(listStrings)
{
  listStrings = gsub("DE", "Death", listStrings)
  listStrings = gsub("LT", "LifeThreatening", listStrings)
  listStrings = gsub("HO", "Hospitalization", listStrings)
  listStrings = gsub("DS", "Disability", listStrings)
  listStrings = gsub("CA", "CongenitalAnomaly", listStrings)
  listStrings = gsub("RI", "Intervention", listStrings)
  listStrings = gsub("OT", "OtherSerious", listStrings)
  return(listStrings)
}


getFreqMatrix = function(myDataFr, col_name, mustReflate){
  # The code below causes the interprer to fail intermittently, when it 
  # tries to look for myDataFrame$col_name, which it should never do. 
  # if(mustReflate)
  # {
  #   outcomes = reflateOutcomes(myDataFr[,col_name]) # intermittent error
  # }
  # else
  # {
  #   outcomes = myDataFr[,col_name]
  # }
  # I need to write the code in the awkward way below as a work-around.
  if(col_name=='pt')
  {
    outcomes = myDataFr$pt
  }
  else
  {
    outcomes = myDataFr$outc_cod
  }
  if(mustReflate)
  {
    outcomes = reflateOutcomes(outcomes)
  }

  myCorpus = Corpus(VectorSource(outcomes))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, stripWhitespace)
  myCorpus = tm_map(myCorpus, removeWords, 
                    c('increased', 'decreased', 'drug', 'related', 'feeling'))
  
  ctrl = list(#tokenize = strsplit_space_tokenizer,
    removePunctuation = list(preserve_intra_word_dashes = TRUE),
    stopwords = TRUE,
    wordLengths = c(1, Inf)
    )
  tdm = TermDocumentMatrix(myCorpus, control = ctrl)
  m = as.matrix(tdm)
  sort(rowSums(m),decreasing=TRUE)
}