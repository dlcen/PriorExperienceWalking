library(plyr); library(reshape); library(data.table); library(ggplot2)

# Read the data
dat <- read.csv("Experiments/Exp1/Data/Data_raw_all.csv", check.names = F)
dat <- data.table(dat)

Dat_raw <- dat
distrange <- which(dat$z > 0.5 & dat$z < 6)
Dat_clean <- dat[distrange]
Dat_raw_clean <- dat

# If I need to align the beginning the trajectories, it should be here
source("Code/R/align.R")

alignedDat_raw <- ddply(Dat_raw_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo"), plyr::mutate, x = align(headingErr, x, z), z = z - z[1])
alignedDat_raw <- data.table(alignedDat_raw)

# Remove those <-10 and > 18.5
## First check the means
### Calculate the mean target-heading angle for each trial
trial.meanErr.long <- ddply(Dat_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo"), plyr::summarise, meanErr = mean(headingErr, na.rm = T))
trial.meanErr.melt <- melt(trial.meanErr.long, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo"))
trial.meanErr.wide <- cast(trial.meanErr.melt, ExpNo + SubjectNo + Familiarity + DisplayMode + PrismDirection + Collection ~ TrialNo)
with(trial.meanErr.wide, table(Collection, Familiarity, DisplayMode))

trial.meanErr.long <- data.table(trial.meanErr.long)
pre.subjects.old   <- as.character(unique(trial.meanErr.long[Collection == "Old"]$SubjectNo))
pre.subjects.new   <- as.character(unique(trial.meanErr.long[Collection == "New"]$SubjectNo))
total.n.trials.old <- nrow(trial.meanErr.long[TrialNo < 6 & Collection == "Old"])
total.n.trials.new <- nrow(trial.meanErr.long[TrialNo < 6 & Collection == "New"])

# Find out those with mean target-heading angle larger than 18.5 or smaller than -10
trial.meanErr.long <- data.table(trial.meanErr.long)
weirdo <- which(trial.meanErr.long$meanErr > 18.5 | trial.meanErr.long$meanErr < -10);

## Get the subject no and trial no. for these weirdos
weirdoNo <- as.character(trial.meanErr.long$SubjectNo[weirdo]); weirdoNo     # S202
weirdoTrial <- as.numeric( trial.meanErr.long$TrialNo[weirdo]); weirdoTrial  # 1, 4, 5
n.outside.range.trials <- length(weirdoTrial)

## Make these weirdo NA
if (length(weirdo) > 0 ) {
      for (i in 1:length(weirdoNo)) {
            Dat_clean[SubjectNo == weirdoNo[i] & TrialNo == weirdoTrial[i]]$headingErr <- NA
            Dat_raw_clean[SubjectNo == weirdoNo[i] & TrialNo == weirdoTrial[i]]$headingErr <- NA
            alignedDat_raw[SubjectNo == weirdoNo[i] & TrialNo == weirdoTrial[i]]$headingErr <- NA
      }
}

# find out those with mean target-heading angle larger than 3SDs from the mean in each condition
## Need to recalculate the mean of each trial
trial.meanErr.long <- ddply(Dat_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo"), plyr::summarise, meanX = mean(x, na.rm = T), meanErr = mean(headingErr, na.rm = T))

## Get the conditions ready
dis.conditions <- as.character(unique(trial.meanErr.long$DisplayMode))
fml.conditions <- as.character(unique(trial.meanErr.long$Familiarity))

## Iterate through each condition
nSubjects <- as.character(trial.meanErr.wide$SubjectNo)
trial.meanErr.long <- data.table(trial.meanErr.long)
outliers <- NULL; TrialNo <- NULL
source("Code/R/outlierSummary.R")

for (d in dis.conditions) {
      for (f in fml.conditions) {
            for (i in 1:10) {
                  thisTrial <- trial.meanErr.long[DisplayMode == d & Familiarity == f & TrialNo == i ]

                  this.nSubjects <- as.character(thisTrial$SubjectNo)
                  idx <- outlierSummary(thisTrial$meanErr, i, this.nSubjects)
                  if (length(idx) > 0 ) {
                        outliers <- c(outliers, idx)
                        TrialNo <- c(TrialNo, thisTrial$TrialNo[thisTrial$SubjectNo %in% idx])
                  }
            }
      }
}

# Absolute z-score greater than 3  1 :  D_S129 
# Absolute z-score greater than 3  3 :  S13

if (length(TrialNo) > 0) {
      for ( i in 1:length(TrialNo)){
            thisSubject <- outliers[i]
            thisTrial <- TrialNo[i]
            
            trial.meanErr.long[SubjectNo == thisSubject & TrialNo == thisTrial]$meanErr <- NA
      }
}
n.outside.3SD.trials <- length(TrialNo)

# Find out whether there is any missing trials
nTrials <- c(1:10)
missingTrials <- NULL
trial.meanErr.long <- data.table(trial.meanErr.long)
excl.sbj.missing <- NULL
for (sbj in nSubjects){
      thisSbj <- trial.meanErr.long[SubjectNo == sbj]
      thisTrials <- as.numeric(thisSbj$TrialNo)
      missing <- nTrials[!nTrials %in% thisTrials]
      hitTrials <- missing[missing %in% c(1)]
      if (length(hitTrials) > 0) {
            excl.sbj.missing <- c(sbj)
      }
}
excl.sbj.missing # NULL

# Check whether the missing and nan trials are belong to the critical trials
na.trials <- which(is.na(trial.meanErr.long$meanErr))
excl.trials <- trial.meanErr.long$TrialNo[na.trials]
excl.idx <- which(excl.trials %in% c(1, 5))
excl.sbj.idx <- na.trials[excl.idx]
excl.sbj <- as.character(unique(trial.meanErr.long$SubjectNo[excl.sbj.idx]))
excl.sbj <- c(excl.sbj, excl.sbj.missing)
cat("Participants to be excluded: ", excl.sbj, "\n") # S129, D_S202
n.excl.sbj <- length(excl.sbj)

if (length(excl.sbj) > 0 ) {
      excl.sbj.idx          <- which(trial.meanErr.long$SubjectNo %in% excl.sbj)
      trial.meanErr.long    <- trial.meanErr.long[-excl.sbj.idx, ]
      Dat_clean             <- Dat_clean[-which(Dat_clean$SubjectNo %in% excl.sbj), ]
      Dat_raw_clean         <- Dat_raw_clean[-which(Dat_raw_clean$SubjectNo %in% excl.sbj), ]
      alignedDat_raw        <- alignedDat_raw[-which(alignedDat_raw$SubjectNo %in% excl.sbj), ]
}

trial.meanErr.melt <- melt(trial.meanErr.long, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo"), measure.vars = "meanErr")
trial.meanErr.wide <- cast(trial.meanErr.melt, ExpNo + SubjectNo + Familiarity + DisplayMode + PrismDirection + Collection ~ TrialNo)
with(trial.meanErr.wide, table(Collection, Familiarity, DisplayMode))

trial.meanErr.long <- data.table(trial.meanErr.long)
post.subjects.old   <- as.character(unique(trial.meanErr.long[Collection == "Old"]$SubjectNo))
post.subjects.new   <- as.character(unique(trial.meanErr.long[Collection == "New"]$SubjectNo))

alignedDat <- alignedDat_raw[which(alignedDat_raw$z > 0.5 & alignedDat_raw$z < 6 ), ]

source("Code/R/segCal.R")

segData_clean <- segCal(Dat_clean)

segData_raw_clean <- segCal(Dat_raw_clean,  nBin = 125, distrange = c(0, 6.25))

segData_aligned <- segCal(alignedDat)


# Calculate the early and later part on the trial data
endDat <- NULL

## Early part
early_range_from_target <- c(6, 6.5)
subDat <- Dat_clean[z <= (7 - early_range_from_target[1]) & z >= (7 - early_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, ExpNo, Familiarity, DisplayMode, PrismDirection, Collection, TrialNo)]
subMean$end <- "early"
endDat <- rbind(endDat, subMean)

## Later part
later_range_from_target <- c(1, 1.5)
subDat <- Dat_clean[z <= (7 - later_range_from_target[1]) & z >= (7 - later_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, ExpNo, Familiarity, DisplayMode, PrismDirection, Collection, TrialNo)]
subMean$end <- "late"
endDat <- rbind(endDat, subMean)

# Save data
save(Dat_clean, Dat_raw_clean, alignedDat_raw, file = "Experiments/Exp1/Data/Data_clean.RData")
save(trial.meanErr.long, trial.meanErr.wide, file = "Experiments/Exp1/Data/meanErr.RData")
save(segData_clean, segData_raw_clean, segData_aligned, file = "Experiments/Exp1/Data/segData.RData")
save(endDat, file = "Experiments/Exp1/Data/endData.RData")
save(total.n.trials.new, total.n.trials.old, n.outside.range.trials, n.outside.3SD.trials, pre.subjects.new, pre.subjects.old, post.subjects.new, post.subjects.old, file = "Experiments/Exp1/Data/Subjects.RData")

rm(list = ls())






