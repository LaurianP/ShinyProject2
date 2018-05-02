rowlimit = 200000 # limiting queries for debugging purposes

library(countrycode)

dbConnector = function(session, dbname) {
  require(RSQLite)
  ## setup connection to database
  conn <- dbConnect(drv = SQLite(), 
                    dbname = dbname)
  
  # disconnect database when session ends
  session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  
  ## return connection
  conn
}

dbGetByReportDate = function(conn, tblname, day_start, day_end) {
  query = paste("SELECT * FROM",
                 tblname,
                 "WHERE rept_dt BETWEEN",
                 paste0("'", day_start, "'"),
                 "AND",
                 paste0("'", day_end, "'"), 
                "LIMIT", as.character(rowlimit))
  as.data.table(dbGetQuery(conn = conn, statement = query))
}

dbGetByReportDateAndOutcome = function(conn, tblname, day_start, day_end, token) {
 query = paste("SELECT * FROM",
               tblname,
               "WHERE outc_cod LIKE '%", token, "%'",
               "WHERE rept_dt BETWEEN ",
               paste0("'", day_start, "'"),
               "AND",
               paste0("'", day_end, "'"),
               "LIMIT", as.character(rowlimit))
as.data.table(dbGetQuery(conn = conn, statement = query))
}

outcomeFromCode = function(outcomeCode) {
  fullO = switch(outcomeCode, 
    "DE"="Death", 
    "LT"="Life-Threatening", 
    "HO"="Hospitalization", 
    "DS"="Disability",
    "CA"="Congenital Anomaly",
    "RI"="Intervention Prevent Permanent Damage",
    "OT"="Other Serious"
  )
  return(fullO)
}

codeFromOutcome = function(outcomeFull) {
  codeO = switch(outcomeFull, 
    "Death"="DE", 
    "Life-Threatening"="LT", 
    "Hospitalization"="HO", 
    "Disability"="DS", 
    "Congenital Anomaly"="CA",
    "Intervention Prevent Permanent Damage"="RI",
    "Other Serious"="OT"
  )
  return(codeO)
}
  
allOutcomes = function()
{
  return(
    c("Death", "Life-Threatening", "Hospitalization", "Disability", 
      "Congenital Anomaly", "Intervention Prevent Permanent Damage", 
      "Other Serious"))
}

allGroupBy = function()
{
  return(
    c("sex", "age_yrs", "wt_kg")
  )
}

countryFromCode = function(iso2code)
{
  fullName = countrycode(iso2code, 'iso2c', 'country.name')
  return(tolower(fullName))
}

chOptions = function()
{
  return(c("Positive", "Negative", "Uknown", "Does not apply"))    
}


chCodeFromFull = function(fullName)
{
  switch(fullName, 
         'Positive'='Y',
         'Negative'='N',
         'Unknown'='U',
         'Does Not Apply'='D'
  )
}


drugOptions = function()
{
  return(c("ACETAMINOPHEN", "ASPIRIN", "BENADRYL", "CELEXA", "LYRICA", "HYDROCODONE", "NEXIUM", "OXYCODONE", "PLAVIX", "PROLIA", "VICODIN"))
}
