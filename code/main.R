UnlikelyTools::set_wd("covid19")

library(plyr)
library(tidyverse)
library(rvest)

# Worldometers ------------------------------------------------------------

worldometers <-
  read_html("https://www.worldometers.info/coronavirus/") %>%
  html_nodes("#main_table_countries_today") %>%
  html_table() %>%
  (function(x) {
    x[[1]]
  })


# The COVID Tracking Project ----------------------------------------------

ctp_us_live <-
  read.csv("https://covidtracking.com/api/us.csv", stringsAsFactors = F)
ctp_us_time <-
  read.csv("https://covidtracking.com/api/us/daily.csv",
           stringsAsFactors = F)
ctp_st_live <-
  read.csv("https://covidtracking.com/api/states.csv",
           stringsAsFactors = F)
ctp_st_time <-
  read.csv("https://covidtracking.com/api/states/daily.csv",
           stringsAsFactors = F)

ctp_us_time$date <-
  as.Date(strptime(ctp_us_time$date, format = "%Y%m%d"))
ctp_st_time$date <-
  as.Date(strptime(ctp_st_time$date, format = "%Y%m%d"))

ctp_st_live$fips <- sprintf("%02d", ctp_st_live$fips)
ctp_st_time$fips <- sprintf("%02d", ctp_st_time$fips)


# The New York Times ------------------------------------------------------

nyt_counties <-
  read.csv(
    "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv",
    stringsAsFactors = F
  )
nyt_counties$fips <- sprintf("%05d", nyt_counties$fips)
nyt_counties$date <- as.Date(nyt_counties$date)
nyt_update_date <-
  sort(unique(nyt_counties$date), decreasing = T)[1]
nyt_counties_live <-
  nyt_counties[nyt_counties$date == nyt_update_date, ]

nyt_states <-
  read.csv(
    "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv",
    stringsAsFactors = F
  )
nyt_states$fips <- sprintf("%05d", nyt_states$fips)
nyt_states$date <- as.Date(nyt_states$date)
nyt_states_live <- nyt_states[nyt_states$date == nyt_update_date, ]

nyt_update_date <- format.Date(nyt_update_date, "%d %B %Y")


# Johns Hopkins University ------------------------------------------------

jhu_url <-
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/"
jhu_ts_confi <-
  read.csv(
    paste0(
      jhu_url,
      "csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    ),
    stringsAsFactors = F
  )
jhu_ts_death <-
  read.csv(
    paste0(
      jhu_url,
      "csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    ),
    stringsAsFactors = F
  )
jhu_daily_base <-
  paste0(jhu_url, "csse_covid_19_daily_reports/%s.csv")
tryCatch({
  jhu_update_date <- format.Date(Sys.Date(), "%d %B %Y")
  jhu_daily_url <-
    sprintf(jhu_daily_base, format.Date(Sys.Date(), "%m-%d-%Y"))
  jhu_daily_update <- read.csv(jhu_daily_url, stringsAsFactors = F)
},
error = function(cond) {
  jhu_update_date <<- format.Date(Sys.Date() - 1, "%d %B %Y")
  jhu_daily_url <<-
    sprintf(jhu_daily_base, format.Date(Sys.Date() - 1, "%m-%d-%Y"))
  jhu_daily_update <<- read.csv(jhu_daily_url, stringsAsFactors = F)
}, finally = {
})


# PA Department of Public Health ------------------------------------------

pa.counties <-
  read_html("https://www.health.pa.gov/topics/disease/coronavirus/Pages/Cases.aspx") %>%
  html_nodes(
    "#ctl00_PlaceHolderMain_PageContent__ControlWrapper_RichHtmlField > div > div > table"
  ) %>%
  html_table() %>%
  (function(x) {
    x[[1]]
  }) %>%
  (function(x) {
    colnames(x) <- x[1, ]
    x[-1, ]
  })

pa.overall <-
  read_html("https://www.health.pa.gov/topics/disease/coronavirus/Pages/Cases.aspx") %>%
  html_nodes(
    "#ctl00_PlaceHolderMain_PageContent__ControlWrapper_RichHtmlField > table:nth-child(2)"
  ) %>%
  html_table() %>%
  (function(x) {
    x[[1]]
  }) %>%
  (function(x) {
    colnames(x) <- x[1, ]
    x[-1, ]
  })

pa.update <-
  read_html("https://www.health.pa.gov/topics/disease/coronavirus/Pages/Cases.aspx") %>%
  html_nodes(
    "#ctl00_PlaceHolderMain_PageContent__ControlWrapper_RichHtmlField > p:nth-child(3) > em:nth-child(1)"
  ) %>%
  html_text() %>%
  (function(x)
    gsub("\\.", "", x)) %>%
  strptime("* Map, tables and case counts last updated at %I:%M %p on %m/%e/%Y") %>%
  format.Date("%d %B %Y at %H:%M")


# Philadelphia Department of Public Health --------------------------------

ph_url <- readLines("phila_url.txt")
tryCatch({
  cop <- read.csv(ph_url, stringsAsFactors = F)
},
error = function(cond) {
  cop <<- read.csv("data/phila_data.csv", stringsAsFactors = F)
},
finally = {
  write.csv(cop[, c("UpdatedDate", "Result.Group", "Result", "Result.Date")], "data/phila_data.csv", row.names = F)
})
cop$Result.Date <-
  as.Date(strptime(cop$Result.Date, format = "%m/%e/%Y"))

cop2 <-
  data.frame(
    Date = as.Date(rownames(table(
      cop$Result.Date, cop$Result
    ))),
    NEG = table(cop$Result.Date, cop$Result)[, 1],
    POS = table(cop$Result.Date, cop$Result)[, 2],
    row.names = NULL
  )
cop3 <- cop2
for (i in 1:nrow(cop2)) {
  cop3$NEG[i] <- sum(cop2$NEG[1:i])
  cop3$POS[i] <- sum(cop2$POS[1:i])
}
cop3[["TOT"]] <- cop3$NEG + cop3$POS
cop3 <- cop3[cop3$Date > "2020-02-29",]

phl.update <-
  format(strptime(unique(cop$UpdatedDate), format = "%m/%e/%Y %I:%M:%S %p"),
         "%d %B %Y at %H:%M")


# Reformat US Data --------------------------------------------------------

jhu_us_ts <-
  data.frame(
    date = as.Date(names(jhu_ts_confi)[-(1:4)], format = "X%m.%e.%y"),
    cases = colSums(jhu_ts_confi[jhu_ts_confi$Country.Region %in% "US" , -(1:4)], na.rm = T),
    deaths = colSums(jhu_ts_death[jhu_ts_death$Country.Region %in% "US" , -(1:4)], na.rm = T)
  )
jhu_us_live <-
  jhu_daily_update[jhu_daily_update$Country_Region %in% "US", ]

ctp_st_time <-
  merge(
    ctp_st_time,
    readRDS("data/us_states.RDS")@data,
    by.x = "state",
    by.y = "STUSPS",
    all.x = T
  )

us_new_cases <-
  jhu_us_ts$cases[-1] - jhu_us_ts$cases[-nrow(jhu_us_ts)]
us_new_deaths <-
  jhu_us_ts$deaths[-1] - jhu_us_ts$deaths[-nrow(jhu_us_ts)]
us_by_day <- jhu_us_ts$cases[-1] / jhu_us_ts$cases[-nrow(jhu_us_ts)]
us_by_day_d <-
  jhu_us_ts$deaths[-1] / jhu_us_ts$deaths[-nrow(jhu_us_ts)]
us_growth_rate <-
  us_new_cases[-1] / us_new_cases[-length(us_new_cases)]
us_growth_data <- data.frame(
  date = jhu_us_ts$date[-(1:2)],
  cases = jhu_us_ts$cases[-(1:2)],
  deaths = jhu_us_ts$deaths[-(1:2)],
  change_cases = us_by_day[-1],
  change_deaths = us_by_day_d[-1],
  new_cases = us_new_cases[-1],
  new_deaths = us_new_deaths[-1],
  change_new = us_growth_rate
)
rm(us_new_cases,
   us_new_deaths,
   us_by_day,
   us_by_day_d,
   us_growth_rate)
us_growth_data$change_new[is.infinite(us_growth_data$change_new)] <-
  0
us_growth_data$change_new[is.nan(us_growth_data$change_new)] <- 0


# Reformat Global Data ----------------------------------------------------

world_ts <-
  data.frame(
    date = as.Date(names(jhu_ts_confi), format = "X%m.%e.%y")[-(1:4)],
    cases = colSums(jhu_ts_confi[, -(1:4)], na.rm = T),
    deaths = colSums(jhu_ts_death[, -(1:4)], na.rm = T)
  )

wrld_new_cases <-
  world_ts$cases[-1] - world_ts$cases[-nrow(world_ts)]
wrld_new_deaths <-
  world_ts$deaths[-1] - world_ts$deaths[-nrow(world_ts)]
wrld_by_day <-
  world_ts$cases[-1] / world_ts$cases[-nrow(world_ts)]
wrld_by_day_d <-
  world_ts$deaths[-1] / world_ts$deaths[-nrow(world_ts)]
wrld_growth_rate <-
  wrld_new_cases[-1] / wrld_new_cases[-length(wrld_new_cases)]
wrld_growth_data <- data.frame(
  date = world_ts$date[-(1:2)],
  cases = world_ts$cases[-(1:2)],
  deaths = world_ts$deaths[-(1:2)],
  change_cases = wrld_by_day[-1],
  change_deaths = wrld_by_day_d[-1],
  new_cases = wrld_new_cases[-1],
  new_deaths = wrld_new_deaths[-1],
  change_new = wrld_growth_rate
)
rm(wrld_new_cases,
   wrld_new_deaths,
   wrld_by_day,
   wrld_by_day_d,
   wrld_growth_rate)
wrld_growth_data$change_new[is.infinite(us_growth_data$change_new)] <-
  0
wrld_growth_data$change_new[is.nan(us_growth_data$change_new)] <- 0


wrld_confirmed <- sum(jhu_daily_update$Confirmed)
wrld_recovered <- sum(jhu_daily_update$Recovered)
wrld_deaths <- sum(jhu_daily_update$Deaths)
wrld_active <- wrld_confirmed - wrld_recovered - wrld_deaths


# Save Data ---------------------------------------------------------------

rm(i, cop, cop2, jhu_daily_base, jhu_daily_url, jhu_url, ph_url)

save(list = ls(), file = "data/collected-data.Rdata")


# Knit Report -------------------------------------------------------------

rmarkdown::render("report.Rmd", output_file = "index.html")


# Update US Map -----------------------------------------------------------

source("code/us-map.R")


# Update World Map --------------------------------------------------------

source("code/world-map.R")


# Update US Map GIF -------------------------------------------------------

source("code/spread.R")


# Github ------------------------------------------------------------------

system("git add .; git commit -m 'Automatic update'")
system("git push")
