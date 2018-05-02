library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(leaflet)
library(countrycode)
library(plotly)

function(input, output, session) {
  
  conn = dbConnector(session, dbname = dbname)
  
  drug_db = reactive({
    raw = dbGetByReportDate(
      conn = conn,
      tblname = tblname,
      day_start = input$d1DateStart,
      day_end = input$d1DateEnd)
    
    # Normalize 'ASPIRIN.' and 'ASPIRIN']
    raw %>%
      mutate(norm_drugname = stringr::str_extract(drugname, '[A-Z|a-z]+')) %>%
      select(rept_dt, norm_drugname, pt, outc_cod, outc_cod_definition)
  })
  
  drug_filtered = reactive(
  {
    if(nchar(input$drugname))
    {
      drug_db() %>% filter(norm_drugname==input$drugname)
    }
    else
    {
      drug_db()
    }
    
  })
  
  terms_outcome = reactive({
    getFreqMatrix(drug_filtered(), 'outc_cod', TRUE)
  })
  terms_event = reactive({
    getFreqMatrix(drug_filtered(), 'pt', FALSE)
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$outcomecloud <- renderPlot({
    v = terms_outcome()
    wordcloud_rep(names(v), v)
  })
  
  output$eventcloud <- renderPlot({
    v = terms_event()
    wordcloud_rep(names(v), v)
  })
  
  
  output$drugtable = DT::renderDataTable({
    setDT(drug_filtered(), keep.rownames=FALSE)
  })
  
  
  c_db = reactive({
    raw = dbGetByReportDate(
      conn = conn,
      tblname = tblname,
      day_start = input$chDateStart,
      day_end = input$chDateEnd)

    # Normalize 'ASPIRIN.' and 'ASPIRIN']
    raw %>%
      mutate(norm_drugname = stringr::str_extract(drugname, '[A-Z|a-z]+'))
  })
  
  chalIncidencePerDrug = reactive({
    dechalCategory = chCodeFromFull(input$challenge)
    c_db() %>%
      group_by(norm_drugname,dechal)    %>%
      summarise(n=n())                  %>%
      mutate(freq=n/sum(n))             %>%
      filter(dechal== dechalCategory)   %>% 
      select(norm_drugname, freq)       %>%
      mutate(response=paste0('challenge=',dechalCategory))
  })

  rechalIncidencePerDrug = reactive({
    rechalCategory = chCodeFromFull(input$rechallenge)
    c_db() %>%
      group_by(norm_drugname,rechal)    %>%
      summarise(n=n())                  %>%
      mutate(freq=n/sum(n))             %>%
      filter(rechal==rechalCategory)    %>%
      select(norm_drugname, freq)       %>%
      mutate(response=paste0('rechallenge=',rechalCategory))
  })
  
  # stack the two incidence sets, to prepare for side-by-side boxplots
  chalStacked = reactive({
    rbind(chalIncidencePerDrug(), rechalIncidencePerDrug())
  })

  output$challengeIncidence = renderPlotly({
    plot_ly(chalStacked(), type="box") %>%
      add_trace(y = ~freq, color = ~response)
  })
  
  output$explainChallenge <- renderText({ 
    paste(c(
      "* Positive dechallenge:stop drug, AE stops.", 
      "* Negative dechallenge:stop drug, AE doesn't stop.",
      "* Positive rechallenge:restart drug, AE starts.",
      "* Negative rechallenge:stop drug, AE doesn't stop."), 
      collapse='')
  })

  
  map_db = reactive({
    m_db = dbGetByReportDate(
      conn = conn, 
      tblname = tblname, 
      day_start = input$mapDateStart,
      day_end = input$mapDateEnd)
    
    m_db %>%
      mutate_at('occr_country', 
                funs(countrycode(., 'iso2c', 'iso3c'))) %>%
      group_by(occr_country) %>%
      summarise(n=n())
  })

  doa_db = reactive({
    
    do_db = dbGetByReportDate(
      conn = conn,
      tblname = tblname, 
      day_start = input$reportDateStart, 
      day_end = input$reportDateEnd)
    
    do_db %>% 
      mutate(age_yrs = recode(age_cod, 
                              MON=age/12,
                              DY =age/365,
                              DEC=age*10,
                              WK=age/52,
                              HR=age/(365*24),
                              .default=age)) %>%
      mutate(wt_kg = recode(wt_cod, 
                              LBS=as.numeric(wt)*0.453592, 
                              .default=as.numeric(wt))) %>% drop_na(wt_kg)
    })

  observeEvent(input$reportDateStart, {
    updateSelectizeInput(session, inputId = "outcome",
                         choices=allOutcomes())
  })
  
  observeEvent(input$reportDateEnd, {
     updateSelectizeInput(session, inputId = "outcome",
                          choices=allOutcomes())
  })
  
  observeEvent(input$outcome, {
    updateSelectizeInput(session, inputId = "groupBy",
                         choices=allGroupBy())
  })
  
  outcomeBy = reactive({
    inputCode = codeFromOutcome(input$outcome)
    
    if(input$groupBy == 'sex')
    {
      doa_db() %>%
        select(sex, outc_cod) %>%
        filter(sex=='M'|sex=='F') %>%
        filter(grepl(inputCode, outc_cod, fixed=TRUE)) %>%
        group_by(sex) %>%
        summarise(n = n())
    } 
    else if(input$groupBy == 'age_yrs' | input$groupBy == 'wt_kg')
    {
      doa_db() %>%
        select_(input$groupBy, "outc_cod") %>%
        filter_(input$groupBy>0) %>%
        filter(grepl(inputCode, outc_cod, fixed=TRUE))
    }
    else
    {
      doa_db() %>%
        select_(input$groupBy, as.name("outc_cod")) %>%
        filter(grepl(inputCode, outc_cod, fixed=TRUE)) %>%
        group_by_(input$groupBy) %>%
        summarise(n = n())
    }
  })
  
  output$bysex <- renderPlot(
    if( input$groupBy == 'age_yrs' | input$groupBy == 'wt_kg')
    {
      outcomeBy() %>%
        ggplot(aes_string(x=input$groupBy)) + geom_histogram() + 
        ggtitle("Histogram Age")
    }
    else
    {
      outcomeBy() %>%
        ggplot(aes_string(x = input$groupBy, y = "n")) + geom_bar(stat="identity") +
        ggtitle("Counts")
    }
  )
  
  output$map1 = renderPlotly({
    
    g = list(
      showframe = TRUE,
      showcoastlines = FALSE,showland = TRUE,showcountries = TRUE,
      countrycolor = toRGB("white"),
      landcolor = toRGB("grey85"),
      projection = list(type = 'Mercator', scale =1)
    )
    
    mapBy = map_db()
    value = mapBy$n
    myloc = mapBy$occr_country
    plot_geo(mapBy) %>% 
      add_trace( z = ~value, locations = ~myloc, color= ~value) %>%
      layout(geo=g)
    
  })
  
}
  