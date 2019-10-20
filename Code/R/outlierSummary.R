outlierSummary<-function(variable, TrialNo, SubjNo, digits = 2){
      
      zvariable<-(variable-mean(variable, na.rm = TRUE))/sd(variable, na.rm = TRUE)
      tobeExcluded <- which(abs(zvariable) >= 3)
      ncases<-length(na.omit(zvariable))
      
      outlierNo <- SubjNo[tobeExcluded]
      if (length(outlierNo) > 0) {cat("Absolute z-score greater than 3 ", TrialNo, ": ", outlierNo , "\n")}
      return(outlierNo)
}