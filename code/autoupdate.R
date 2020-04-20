setwd("~/covid19")

rm(list = ls())

while (TRUE) {

  if (format(Sys.time(), "%M") %in% c(0, 30)) {

    system("git fetch")

    # Get Data ----------------------------------------------------------------

    source("code/get_data.R")


    # Knit Report -------------------------------------------------------------

    rmarkdown::render("report.Rmd", output_file = "index.html")


    # Update World Map --------------------------------------------------------

    #source("code/world-map.R")


    # Update US Map -----------------------------------------------------------

    #source("code/us-map.R")


    # Update US Map GIF -------------------------------------------------------

    #source("code/spread.R")


    system("git add .; git commit -m 'Automatic update'")
    system("git push")

  }

  Sys.sleep(30)

}
