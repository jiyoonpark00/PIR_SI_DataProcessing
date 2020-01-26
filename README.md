# PIR_SI_DataProcessing

These instructions will get you an .xlsx file to be ingested into admin UI to run PIR data. This file is to be used to calculate correct *SubjectInventionCount* and *PatentsIssued*.  

> Step 1. Data
- Prepare all data sets to be read in R. 
- The files needed to collect SI's and Patents are the follolwing:
```
1. ePIC SIUR extract (xlsx)
2. iEdidsonInventionReport (xlsx)
3. iEdisonUtilizationReport (xlsx)
4. IP Manager Data (xlsx)
```
> Step 2. R coding 
- Make sure all packages written at the top of the R file are installed and updated in the local computer. 
- Run line by line the R code. 

> Step 3. Final Data
- The final data written as *.csv* file may need to be renamed and transformed to *.xlsx* file. 
```
example. "IP manager_iEdisonMerged.xlsx"
```

> Step 4. Sending the *.xlsx* file to a person who runs admin UI. 
