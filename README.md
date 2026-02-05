# NYC Restaurant Health Inspection Analysis  
## Analyst’s Report for Public Health and Compliance Stakeholders

### Executive Overview  
This report provides an assessment of restaurant health‑code compliance across New York City, using the latest inspection records from the Department of Health. The analysis highlights violation patterns, geographic hotspots, cuisine‑level trends, and shifts in inspection outcomes over time. Objective is to support targeted compliance programs, resource allocation, and public‑health interventions.

The findings draw from a cleaned and standardized dataset, enriched with neighborhood mappings and structured into a consistent semantic layer for analysis.

---

## Key Findings  

### 1. Citywide performance is deteriorating  
Average inspection scores have risen steadily since 2021 (higher scores = worse performance), and Grade A rates have declined across all boroughs. This indicates a broad weakening in compliance, not isolated issues.

### 2. Critical violations remain persistently high  
Roughly half of all violations in recent years are classified as critical. The most common issues involve:  
- Facility maintenance and sanitation  
- Drainage and waste conditions  
- Pest‑conducive environments  
- Food‑contact surface hygiene  
- Temperature control failures  

These are fundamental operational lapses, not niche or cuisine‑specific problems.

### 3. Queens requires focused attention  
Queens consistently appears as the borough among the highest‑scoring (worst) neighborhoods. Deep‑dive analysis highlights clusters such as Queensborough Hill, Elmhurst‑Maspeth, Pomonok‑Flushing, Flushing, and Queens Village. These patterns are geographic rather than cuisine‑driven.

### 4. Cuisine patterns exist but have limited impact on citywide outcomes  
Some cuisines (South Asian, African, Southeast Asian, Middle Eastern/North African, Chinese) show higher average scores and higher critical‑violation rates. However, many of these categories represent a small share of total inspections. Addressing them alone will not materially shift overall compliance.

### 5. Inspection activity has increased sharply since 2022  
The rise in inspection volume suggests stronger enforcement or resumed activity post‑pandemic. Re‑inspections now outnumber initial inspections, indicating that many establishments are struggling to meet standards on the first visit.

---

## Implications  

- **Citywide compliance is weakening**, and the decline in Grade A rates signals the need for broader education and support programs.  
- **Queens should be prioritized for targeted outreach,** given its concentration of high‑score neighborhoods.  
- **Operational fundamentals** such as cleanliness, maintenance, temperature control, and pest prevention, should be the focus of training and compliance initiatives.  
- **Cuisine‑level interventions** should be selective and data‑driven, focusing on high‑volume categories where improvements will meaningfully affect citywide outcomes.  
- **Rising re‑inspection rates** suggest operators may need clearer guidance or more accessible resources to meet standards consistently.

---

## Dashboard Highlights (Power BI)  
The Power BI report provides:  
- Violation frequency and critical‑violation patterns  
- Borough and neighborhood score comparisons  
- Cuisine‑level performance  
- Grade A trends over time  
- Inspection‑type distributions  
- Geographic deep‑dives, including Queens hotspots  

---

## Appendix A: Technical Foundation  

### A. Data Preparation (SQL)  
- Removal of nulls and inconsistent values  
- Standardization of cuisine, violation, and inspection fields  
- Mapping of NTA codes to neighborhood names  
- Creation of dimension tables (cuisine, violation, neighborhood)  
- Preliminary SQL exploration and validation  

### B. Automated ELT Pipeline (Python)  
- API extraction of inspection data  
- Automated loading of raw CSVs into the processing directory  
- Transformation into Power BI‑ready tables  

### C. Power BI Data Model  
- Fact table: restaurant inspections  
- Dimension tables: cuisine, violation, violation groups, neighborhood  
- Defined relationships for consistent reporting  

### Resources  

- NYC DOHMH inspection dataset  <br>
#### [Original csv data set downloaded from this link on 2025-09-19](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data)

- NYC NTA neighborhood mapping <br>
#### [Neighborhood names in NYC](https://data.cityofnewyork.us/City-Government/2010-Census-Tract-to-Neighborhood-Tabulation-Area-/8ius-dhrr/data_preview)

- API endpoint for automated extraction <br>
#### [API Endpoint for Extraction with Python](https://data.cityofnewyork.us/resource/43nn-pn8j.json) 


#### Software: pgAdmin for postgres SQL, Power BI for report, python in VSCode for the next extract -> load -> transform after downloading updated csv file.


## Appendix B: Dashboard Screens

### Overview Dashboard
![Power BI - Overview](assets/dashboard_page1.PNG)

### Inspection Types Analysis
![Power BI - Inspection Types Analysis](assets/dashboard_page2.PNG)

### Scores and Trends
![Power BI - Scores Analysis](assets/dashboard_page3.PNG)

### Queens Deep Dive
![Queens Deep Dive](assets/queens_deep_dive.PNG)

## Appendix C: Technical Details
- [Automated Data Prep for Power BI Using Python](python/resto_auto_analysis.ipynb)
- [Postgres SQL Scripts for Transformation](sql)
- [SQL Transformation Workflow Diagram](sql/sql_workflow.txt)
- [Preliminary SQL Analysis of Restaurant Inspections](preliminary-sql-analysis-of-restaurant-inspections)
- [Power BI Dashboard Analysis](power-bi-dashboard-analysis)
