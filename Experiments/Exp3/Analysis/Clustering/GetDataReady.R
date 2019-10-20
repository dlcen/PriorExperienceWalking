library(data.table)

load("Experiments/Exp3/Data/segData.RData")

segData <- data.table(segData_clean)

offset.err  <- segData[TrialNo %in% c(1:5)]
offset.mean <- offset.err[, .(headingErr = mean(headingErr, na.rm = T)), by = c("SubjectNo", "Familiarity", "TargetPosition", "seg.z")]
offset.mean[Familiarity == "Unfamiliar"]$TargetPosition <- "Unknown"

write.csv(offset.mean, "Experiments/Exp3/Analysis/Clustering/segData_trialMean.csv")