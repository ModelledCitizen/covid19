
while (TRUE) {

  if (format(Sys.Time(), "%M") == 0) {



  }

}


# Github ------------------------------------------------------------------
system("git fetch")


# Run updates -------------------------------------------------------------

source("code/main.R")


# Github ------------------------------------------------------------------

system("git add .; git commit -m 'Automatic update'")
system("git push")
