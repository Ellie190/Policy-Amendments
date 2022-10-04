# Policy-Amendments
A projected aimed at understanding how resources vary in Northern Cape cities or towns to make decisions that influence policy amendments

## Dashboard Access Link
https://ds-analytics.shinyapps.io/Policy-Amendments/

## Context
During the past decade, advances in information technology have ignited a revolution in decision-making, from business to sports to policing. Previously, decisions in these areas had been heavily influenced by factors other than empirical evidence, including personal experience or observation, instinct, hype, and dogma or belief. The ability to collect and analyse large amounts of data, however, has allowed decision-makers to cut through these potential distortions to discover what really works.

**Policy -** A course or principle of action adopted or proposed by an organization or individual. Policy is a deliberate system of guidelines to guide decisions and achieve rational outcomes.

The purpose of this dashboard is to understand how the percentage of Natural Resources (NR) and Human Development Index (HDI) varies in Northern Cape (NC) . This is for the purpose of providing data-driven policy recommendations. Policy recommendations that considers geographic mapping of cities or towns and what citizens complain about (policy intelligence)

## Resources
**R Libraries:** `shiny`, `bs4Dash`, `readxl`, `dplyr`, `tidygeocoder`, `janitor`, `leaflet`, `plotly`, `DT`, `leafpop`, `factoextra`, `rtweet`, `tidytext`, `ggwordcloud`, `tidyquant`, `tidyverse`, `waiter`, `shinycssloaders` <br>
**rtweet version 0.7.0 installation:**
```
library(devtools)
install_version("rtweet", version = "0.7.0", repos = "http://cran.us.r-project.org")
```
**Create `.Renviron` file for rtweet API in R project folder**
```
library(usethis)
usethis::edit_r_environ("project")
```

**Edit `.Renviron` file**
```
app=xxxxxxxxxxxxxxx
key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
access_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
access_secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## R Shiny Dashboard 
![Figure 1](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture1.png) <br>

## Natural Resources (NR)
**Natural Resources -** Natural resources are materials from the Earth that are used to support life and meet people’s needs

**Natural Resource Policy -** A program that prepares individuals to plan, develop, manage, and evaluate programs to protect and regulate natural habitats and renewable natural resources <br>
**Natural Resource Indicators:** `Availability of water, Argricultural Potential, Mining Potential, Tourism Potential, Environment Sensitivity`

**Clustering NR -** Kmeans clustering is used to cluster (group) cities/towns with similar Natural Resources. <br>
**Natural Resource City Groups** shows how distinct the clusters are for the selected number of groups (clusters)

![Figure 2](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture2.png) <br>

**City Group Mapping** shows geographical location of each cluster (group)<br>
**Group Table** shows natural resource indicator percent in each cluster (group) <br>
**NR group Count** shows how many towns or cities are in a particular cluster (group) <br>
**Map Circle (green, red):** Each of these circles contains NR information about a particular city/town. This information is shown when any circle on the map is clicked. 

![Figure 3](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture3.png) <br>

## Human Development Index (HDI)
**Human Development -** Human development is defined as the process of enlarging people’s freedoms and opportunities and improving their well-being

**Human Development Index -** The HDI is a summary measure of human development. The HDI is a summary composite measure of a country’s average achievements in three basic aspects of human development: health, knowledge and standard of living. It is a measure of a country’s average achievements in three dimensions of human development. 

**Human Development Indicators:** `Education, Income, Occupation, Health Status, Housing`

**Clustering HDI -** Kmeans clustering is used to cluster (group) cities/towns with similar Human Development Index. <br>
**Human Development Index City Groups** This shows how distinct the clusters are for the selected number of groups (clusters)

![Figure 4](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture4.png) <br>

**City Group Mapping** shows geographical location of each cluster <br>
**Group Table** shows human development index indicator percent in each cluster (group) <br>
**NR group Count** shows how many towns or cities are in a particular cluster (group) <br>
**Map Circle (green, red):** Each of these circles contains HDI information about a particular city/town. This information is shown when any circle on the map is clicked. 

![Figure 5](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture5.png) <br>

## Policy Intelligence (PI)
**Inspiration for PI dashboard tab by `Business Science (Youtube):`** https://www.youtube.com/watch?v=S5H0eUeL_gQ&t=3398s <br>
**Twitter For Analysis -** Twitter can provide key insights into what citizens are saying about Natural Resources and the Human Development Index. This is a great way to find out about what is happening or trending.

**Positive Sentiment -** This can highlight where citizens are positively responding to NR and HDI delivery.

**Negative Sentiment -** This can highlight key issues citizens care about.

**Tweet Proximity: Search Radius -** This shows where the tweets are coming from/extracted from

![Figure 6](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture6.png) <br>

**Sentiment -** A sentiment is a view or opinon that is held or expressed. Similar to: View, point of view, feeling, attitude, thought. Positive and negative sentiments can be extratced from the tweets posted on twitter.

**Sentiment polarity** for an element defines the orientation of the expressed sentiment, i.e., it determines if the tweet expresses the positive, negative or neutral sentiment of the user about the entity in consideration.

![Figure 7](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture7.png) <br>

**Sentiment Polarity:** This shows how positive or negative a tweet is. Since there may be numerous tweets at times, focusing on extreme negative and positive tweets may become necessary. The `upper red line` shows the positive outlier tweets (extreme positive tweets above the red line). The `lower red line` shows the negative outlier tweets (extreme negative tweets below the red line). 

![Figure 8](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture8.png) <br>

## Dashboard Info Page
![Figure 9](https://github.com/Ellie190/Policy-Amendments/blob/main/Dasboard%20Images/Picture9.png) <br>
