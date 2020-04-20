setwd("~/covid19")

rm(list = ls())

while (TRUE) {

  if (format(Sys.time(), "%M") %in% c(0, 30)) {

    print(Sys.time())
    print("Starting update...")

    print(Sys.time())
    print("Pull repo...")
    system("git fetch; git pull")

    # Get Data ----------------------------------------------------------------

    print(Sys.time())
    print("Get data...")
    source("code/get_data.R")


    # Knit Report -------------------------------------------------------------


    print(Sys.time())
    print("Render index...")
    rmarkdown::render("report.Rmd", output_file = "index.html")


    # Update World Map --------------------------------------------------------

    print(Sys.time())
    print("Save world map...")
    source("code/world-map.R")


    # Update US Map -----------------------------------------------------------

    print(Sys.time())
    print("Save US map...")
    source("code/us-map.R")


    # Update US Map GIF -------------------------------------------------------

    print(Sys.time())
    print("Save spread GIF...")
    source("code/spread.R")

    print(Sys.time())
    print("Commit changes...")
    system("git add .; git commit -m 'Automatic update'")
    print(Sys.time())
    print("Push repo...")
    system("git push")

  }

}
