library(data.table)

load("Experiments/Exp2/Data/segData.RData")

segData <- data.table(segData_clean)

offset.err  <- segData[TrialNo %in% c(1:5) & ExpNo == "Lit" & Collection == "Old"]
offset.mean <- offset.err[, .(headingErr = mean(headingErr, na.rm = T)), by = c("SubjectNo", "ExpNo", "DisplayMode", "Familiarity", "seg.z")]

write.csv(offset.mean, "Experiments/Exp2/Analysis/Clustering/Lit/OldDataset/segData_trialMean.csv")