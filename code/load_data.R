require(dplyr)
require(tidyr)

parse_jhu <- function(cwo) {
  cwn <- cbind(
    FIPS = cwo$FIPS,
    cwo[, grep("X(0-9)*", names(cwo))[-1]] - cwo[, grep("X(0-9)*", names(cwo))[-1] - 1]
  )
  cwg <- cbind(
    FIPS = cwn$FIPS,
    cwn[, grep("X(0-9)*", names(cwn))[-1]] / cwn[, grep("X(0-9)*", names(cwn))[-1] - 1]
  )
  clo <- pivot_longer(cwo, starts_with("X"), names_to = "date", values_to = "total_cases")
  cln <- pivot_longer(cwn, starts_with("X"), names_to = "date", values_to = "new_cases")
  clg <- pivot_longer(cwg, starts_with("X"), names_to = "date", values_to = "growth_rate")
  cl <- merge(clo, cln)
  cl <- merge(cl, clg)
  cl$date <- as.Date(cl$date, format = "X%m.%d.%y")
  cl[["week"]] <- format(cl$date, "%Y-W%U")
  cl <- cl[!is.na(cl$FIPS), ]
  cl$new_cases[cl$new_cases < 0] <- 0
  cl$growth_rate[cl$growth_rate < 0] <- 0
  cl$growth_rate[abs(cl$growth_rate) == Inf] <- 0
  cl$growth_rate[is.na(cl$growth_rate)] <- 0
  cl
}

read.csv(
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
) %>%
  parse_jhu() -> cld

cld %>%
  group_by(FIPS, Country_Region, Province_State, Admin2, week) %>%
  summarize(
    date = max(date),
    total_cases = max(total_cases),
    new_cases = mean(new_cases),
    growth_rate = mean(growth_rate),
    .groups = "drop"
  ) -> clw

clw %>%
  group_by(Country_Region, Province_State, date) %>%
  summarize(
    date = max(date),
    total_cases = max(total_cases),
    new_cases = mean(new_cases),
    growth_rate = mean(growth_rate),
    .groups = "drop"
  ) -> clws


phila <- clw[clw$FIPS %in% "42101",]
plot(phila$date, phila$total_cases)
plot(phila$date, log(phila$total_cases))
plot(phila$date, phila$new_cases)
plot(phila$date, log(phila$new_cases))
abline(h = 1)
points(phila$date, phila$growth_rate, col = "red")


pa <- clws[clws$Province_State %in% "Pennsylvania",]
plot(pa$date, pa$total_cases)
plot(pa$date, log(pa$total_cases))
plot(pa$date, pa$new_cases)
plot(pa$date, log(pa$new_cases))
abline(h = 1)
points(pa$date, pa$growth_rate, col = "red")



