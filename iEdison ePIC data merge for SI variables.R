library(dplyr)
library(tidyverse)
library(lubridate)
library(readxl)
library(stringr)
#library(regex)
library(readr)
library(xlsx)

################################## Call Relevant Files and Clean Data ############################################
siur.xl <- "ePIC SIUR extract 2019-11-18.xlsx"
siur <- read_excel(siur.xl)
iedison <- "01-08-2020 iEdisonInventionsReport.xlsx"
ied.1 <- read_excel(iedison, skip = 1)
iedison2 <- "01-08-2020 iEdisonUtilizationReport.xlsx"
ied.2 <- read_excel(iedison2, skip = 1)

### Clean up iEdison data sets and ePIC data 
ied.2 <- ied.2 %>% mutate(ReportYear = year(as.Date(as.character(`Reporting Year`), "%Y"))) %>%
  select(`Invention Report Number`, `Invention Organization`, ReportYear, 
         `Latest Development Stage`, `Total Income`)
ied.1 <- ied.1 %>% select(`DOE S Number`, `Invention Report Number`, `Grantee/Contractor Organization`, `Invention Title`, `Inventor Last Name 1`,
                          `Inventor First Name 1`, `Invention Report Date`, `Primary Agency`, `Funding Agency 1`, 
                          `Supporting Grant/Contract Number 1`,`Supporting Grant/Contract Number 2`,`Supporting Grant/Contract Number 3`,
                          `Invention Creation Date`)

siur <- siur %>% mutate(ReportYear = year(as.Date (`Reporting Year`, "%Y")) ) %>%
  select(RollupProjectId, ProjectId, `Lead Award Number`, `Award Number`, `Organization Name`,
         `SIUR Report Status`, `SIUR Required`, ReportYear, `Inventions Reported`)

### Clean three Award numbers and select ARPA-E Award Number only, and create "arpaeAwards" variable
ied.1$arpaeAwards <- NA 

for( i in 1:nrow(ied.1)) {
  if(length(which(grepl('DE-AR',ied.1[i,10:12]) == TRUE) ) != 0){
    loc <- which(grepl('DE-AR',ied.1[i,10:12]) == TRUE) 
    ied.1$arpaeAwards[i] <- paste(ied.1[i,10:12][,loc], collapse = "; ")
  }
  else{
    ied.1$arpaeAwards[i] <- NA
  }
}


################################ Update Subject Invention Count from iEdison and IP Data#########################
## Read merged file (patent data)
ip.xl <- "IP Manager Data - DE-AR added from iEdison - 12-02-2019.xlsx"
ip.comp <- read_excel(ip.xl, sheet = "Query Export w PatSnap Data")
ip.comp <- ip.comp %>% group_by( )%>%arrange(`S-Number`) %>%
  #mutate(Snumber = gsub("[[:space:]]", "",`S-Number`)) %>%
  mutate(Snumber = parse_number(`S-Number`))%>%
  mutate(Snumber = gsub(".*-","",Snumber)) %>%
  arrange(Snumber)



         
## below select the first 4 columns in ied.1 file and then,
# identify records that are missing in IP data from iEdison 
`%notin%` <- Negate(`%in%`)
ied.temp <- ied.1 %>% select(`DOE S Number`,`arpaeAwards` , `Invention Report Number`, `Grantee/Contractor Organization`, `Invention Title`) %>%
  mutate(S_number = gsub(".*-","",`DOE S Number` )) %>% mutate(S_number.1 = gsub("\\,", "", S_number)) %>%
  mutate(S_number.2 = parse_number(S_number.1))%>%
  filter(S_number.2 %notin% ip.comp$Snumber) %>%
  mutate(S_number.3 = as.character(S_number.2))%>%
  select(S_number.3, arpaeAwards,  `Grantee/Contractor Organization`, `Invention Title`)

## from here, remove "S" from the string in ied.1

colnames(ied.temp) <- c("Snumber", "Contract No.","Contractor Name", "Title" )

##add the missing records into IP data 
replaceNA <- sample(c(900001:999999), length(which(!is.na(ip.comp$`S-Number`))), replace = FALSE)

ip.comp2 <- ip.comp %>% 
  bind_rows(ied.temp) %>%
  mutate(Snumber = ifelse(is.na(Snumber), replaceNA, Snumber))%>%
  mutate(`S-Number` = Snumber) %>%
  arrange(`S-Number`) %>%
  mutate(PatentNumber = ifelse( (is.na(`Patent Number`) & startsWith(`PatSnap Patent Publication #`, "US")),
                                `PatSnap Patent Publication #`, `Patent Number`)) %>%
  mutate(PatentNumber = parse_number(PatentNumber)) %>%
  mutate(PatentApp = ifelse((is.na(`Application Number`) & startsWith(`PatSnap Patent Application Number`,
                                                                      "US")),`PatSnap Patent Application Number`,
                            `Application Number`)) 
#%>% mutate(PatentApp = ifelse(grepl("^[[:digit:]]+", PatentApp), PatentApp, NA))


write.csv(ip.comp2,"ip.comp2.csv", row.names = FALSE)
  
  
