UnlikelyTools::set_wd("covid19")

library(readxl)

p1 <- read_xls("POP/POP01.xls")
p2 <- read_xls("POP/POP02.xls")
p3 <- read_xls("POP/POP03.xls")



library(rvest)


pa.counties <-
  read_html("https://www.health.pa.gov/topics/disease/coronavirus/Pages/Cases.aspx") %>%
  html_nodes("#ctl00_PlaceHolderMain_PageContent__ControlWrapper_RichHtmlField > div > div > table") %>%
  html_table() %>%
  (function(x) {x[[1]]}) %>%
  (function(x) {colnames(x) <- x[1,]; x[-1,]})


ph.overall <- pa.counties[pa.counties$County == "Philadelphia", c("Total Cases", "Negatives")]
ph.overall[["TotalTests"]] <-
  as.numeric(ph.overall$`Total Cases`) + as.numeric(ph.overall$Negatives)
ph.overall <- ph.overall[,c(1, 2, 3)]
ph.overall[1, ] <-
  vapply(ph.overall[1, ], prettyNum, "chr", big.mark = ",")
kable(
  ph.overall,
  col.names = c("Cases", "Negative Tests", "Total Tests"),
  row.names = F,
  align = "ccc",
  digits = 3
) %>%
  kable_styling() %>%
  row_spec(1, bold = T) %>%
  column_spec(1, color = "darkorange") %>%
  column_spec(2, color = "seagreen") %>%
  column_spec(3, color = "royalblue")

"https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv"


library(RCurl)
library(jsonlite)
jsn <-
  getURL(
    "https://covid19-static.cdn-apple.com/covid19-mobility-data/2005HotfixDev12/v1/en-us/applemobilitytrends.json"
  ) %>% fromJSON()
str(jsn$data$Philadelphia)


# kable(
#   worldometers[worldometers$`Country,Other` == "USA", c(2, 7, 6, 4, 8, 9, 10)],
#   col.names = c(
#     "Cases",
#     "Active",
#     "Recovered",
#     "Deaths",
#     "Critical",
#     "Cases / 1M Pop.",
#     "Deaths / 1M Pop."
#   ),
#   row.names = F,
#   align = "ccccc"
# ) %>%
#   kable_styling() %>%
#   row_spec(1, bold = T) %>%
#   column_spec(1, color = "darkorange") %>%
#   column_spec(2, color = "goldenrod") %>%
#   column_spec(3, color = "yellowgreen") %>%
#   column_spec(4, color = "firebrick") %>%
#   save_kable("us_worldometers.html")
