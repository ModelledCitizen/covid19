library(leaflet)

lab <- paste0(
  "<strong>",
  jhu_daily_update$Country_Region,
  ifelse(jhu_daily_update$Province_State == "", "", ": "),
  jhu_daily_update$Admin2,
  ifelse(jhu_daily_update$Admin2 == "", "", ", "),
  jhu_daily_update$Province_State,
  "</strong><br>",
  prettyNum(jhu_daily_update$Confirmed , big.mark = ","),
  " cases<br>",
  prettyNum(jhu_daily_update$Deaths, big.mark = ","),
  " deaths"
) %>%
  lapply(htmltools::HTML)

leaflet(jhu_daily_update) %>%
  addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(
    lng = jhu_daily_update$Long_,
    lat = jhu_daily_update$Lat,
    label = lab,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"
    ),
    radius = log(jhu_daily_update$Confirmed),
    weight = 10,
    fillColor = "red",
    stroke = F
  ) %>% setView(lat = 0,
                lng = 0,
                zoom = 2) %>%
  addEasyButton(easyButton(
    icon = "fa-external-link",
    title = "Open map in new tab",
    onClick = JS("function(btn, map){ window.open('https://covid19.unlikelyvolcano.com/world-map.html') }")
  )) %>%
  htmlwidgets::saveWidget("world-map.html", title = "Global COVID-19 Map")