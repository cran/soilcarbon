#' dataQC
#'
#' Check the imported soil carbon dataset for formatting and entry errors
#'
#' @param data directory to data file
#' @param tabs the tabs that will be checked, default is all
#' @param writeQCreport if TRUE, a text report of the QC output will be written to the outfile. Default is FALSE
#' @param outfile filename of the output file if writeQCreport=TRUE. Default is NULL, and the outfile will be written to the directory where the dataset is stored, and named by the dataset being checked.
#' @export
#'
#'

dataQC <- function(data, tabs= c("metadata", "site", "profile", "layer", "fraction"), writeQCreport=F, outfile=NULL){

  if (writeQCreport==T){
    if (is.null(outfile)){
      outfile<-gsub("\\.xlsx", "_QCreport.txt", attributes(data)$file_name)
    }
    reportfile<-file(outfile)
    sink(reportfile)
    sink(reportfile, type = c("message"))
  }

  template_file<-system.file("extdata", "Master_template.xlsx", package = "soilcarbon")
  template<-read.soilcarbon(file=template_file, template=T)

cat(rep("-", 30),"\n")
cat("         Thank you for submitting data to the \n")
cat("          Powell Center soil carbon database!\n")
cat(rep("-", 30),"\n")
cat("                Please review the\n")

cat("          Quality Control check below:\n")
cat(rep("-", 30),"\n\n\n")


  cat("timestamp:", as.character(Sys.time()),"\n")
  cat(rep("-", 20),"\n")
  # Compare column names in dataset to template file
  cat("COLUMN NAMES\n")
 errors<-sum(sapply(tabs, function(x) checkcolnames(data, x, template)))

# Check required columns
  cat(rep("-", 20),"\n")
  cat("REQUIRED COLUMNS\n")
  errors<-errors+sum(sapply(tabs, function(x) checkreqcols(data, x)))


# Compare names at different hierarchies
cat(rep("-", 20),"\n")
cat("LEVEL NAMES\n")
  errors<-errors+checknames(data, "dataset", tabs)
  errors<-errors+checknames(data, "site", tabs)
  errors<-errors+checknames(data, "profile", tabs)
  errors<-errors+checknames(data, "layer", tabs)

# Check values for different variables
  cat(rep("-", 20),"\n")
  cat("VARIABLE VALUES\n")
  errors<-errors+sum(sapply(tabs, function(x) checkvalues(data, x)))

  cat(rep("-", 20),"\n")
  if(errors==0){
    cat("PASSED! Congratulations!")
  } else {
    cat("\n", errors, "WARNINGS need to be fixed\n")
  }


  cat("\n",rep("-", 30),"\n")
  cat("         this check was produced with the dataQC()\n")
  cat("         function in the R soilcarbon package\n")
  cat(rep("-", 30),"\n")


  if (writeQCreport==T){
    sink()
    cat("QC report saved to", outfile,"\n")
    closeAllConnections()
  }

return(errors)

}

