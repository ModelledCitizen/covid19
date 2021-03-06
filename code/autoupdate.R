tryCatch({
  setwd("~/covid19")
  rm(list = ls())
  write_log <- function(message) {
    cat(format(Sys.time()))
    cat(paste0(": ", message, "\n"))
  }
  sink("logfile.txt")
  write_log("System start-up.")
  while (TRUE) {
    write_log <- function(message) {
      cat(format(Sys.time()))
      cat(paste0(": ", message, "\n"))
    }
    if (as.numeric(format(Sys.time(), "%M")) == 0)  {

      if (as.numeric(format(Sys.time(), "%H")) == 23) {
        write_log("Delaying 2300 start.")
        Sys.sleep(90)
      }
      if (as.numeric(format(Sys.time(), "%H")) == 2) {
        write_log("Delaying 0200 start.")
        Sys.sleep(90)
      }

      write_log("Starting update...")

      write_log("Pull repo...")
      system("git fetch; git pull")

      # Get Data ----------------------------------------------------------------

      write_log("Get data...")
      source("code/get_data.R")

      # Knit Report -------------------------------------------------------------

      write_log("Render index...")
      rmarkdown::render(
        "code/report.Rmd",
        output_file = "index.html",
        output_dir = "~/covid19",
        quiet = T
      )

      if (as.numeric(format(Sys.time(), "%H")) %in% c(1, 13)) {
        # Update World Map --------------------------------------------------------

        write_log("Save world map...")
        source("code/world-map.R")

        # Update US Map -----------------------------------------------------------

        write_log("Save US map...")
        source("code/us-map.R")

        # Update US Map GIF -------------------------------------------------------

        #write_log("Save spread GIF...")
        #source("code/spread.R")

      }


      write_log("Commit changes...")
      #system("git add .; git commit -m 'Manual update'")
      system("git add .; git commit -m 'Automatic update'")

      write_log("Push repo...")
      system("git push")

      #write_log("Send alert...")
      #source("code/alert.R")

      write_log("Sleep for one minute...")
      Sys.sleep(60)

      write_log("Wake up...")

    }
  }
},
error = function(cond) {
  write_log <- function(message) {
    cat(format(Sys.time()))
    cat(paste0(": ", message, "\n"))
  }
  write_log("Sending error message...")
  source("code/error.R")
  write_log("Process failed.")
},
finally = {
  write_log <- function(message) {
    cat(format(Sys.time()))
    cat(paste0(": ", message, "\n"))
  }
  write_log("Process halted.")
  sink()
})
