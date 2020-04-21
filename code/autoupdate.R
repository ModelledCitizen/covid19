setwd("~/covid19")

rm(list = ls())

sink("logfile.txt")

while (TRUE) {

  if (as.numeric(format(Sys.time(), "%M")) == 0)  {

    cat(format(Sys.time()))
    cat(": Starting update...\n")

    cat(format(Sys.time()))
    cat(": Pull repo...\n")
    system("git fetch; git pull")

    # Get Data ----------------------------------------------------------------

    cat(format(Sys.time()))
    cat(": Get data...\n")
    source("code/get_data.R")


    # Knit Report -------------------------------------------------------------


    cat(format(Sys.time()))
    cat(": Render index...\n")
    rmarkdown::render("report.Rmd", output_file = "index.html", quiet = T)


    if (as.numeric(format(Sys.time(), "%H")) %%  2 == 0)  {
      # Update World Map --------------------------------------------------------

      cat(format(Sys.time()))
      cat(": Save world map...\n")
      source("code/world-map.R")


      # Update US Map -----------------------------------------------------------

      cat(format(Sys.time()))
      cat(": Save US map...\n")
      source("code/us-map.R")


      # Update US Map GIF -------------------------------------------------------

      cat(format(Sys.time()))
      cat(": Save spread GIF...\n")
      source("code/spread.R")

    }

    cat(format(Sys.time()))
    cat(": Commit changes...\n")
    system("git add .; git commit -m 'Automatic update'")

    cat(format(Sys.time()))
    cat(": Push repo...\n")
    system("git push")

  }

}
