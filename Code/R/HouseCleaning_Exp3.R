library(plyr); library(reshape); library(data.table); library(ggplot2)

# Read the previously saved data
load( "Experiments/Exp1/Data/Data_clean.RData")
load( "Experiments/Exp1/Data/meanErr.RData")
load( "Experiments/Exp1/Data/segData.RData")
load( "Experiments/Exp1/Data/endData.RData")

trial.meanErr.wide      <- data.table(trial.meanErr.wide)
segData_clean           <- data.table(segData_clean)
segData_raw_clean       <- data.table(segData_raw_clean)
segData_aligned         <- data.table(segData_aligned)

exp1.Dat_clean          <- Dat_clean[DisplayMode == "Continuous"]
exp1.Dat_raw_clean      <- Dat_raw_clean[DisplayMode == "Continuous"]
exp1.alignedDat_raw     <- alignedDat_raw[DisplayMode == "Continuous"]

exp1.trial.meanErr.long <- trial.meanErr.long[DisplayMode == "Continuous"]
exp1.trial.meanErr.wide <- trial.meanErr.wide[DisplayMode == "Continuous"]

exp1.segData_clean      <- segData_clean[DisplayMode == "Continuous"]
exp1.segData_raw_clean  <- segData_raw_clean[DisplayMode == "Continuous"]
exp1.segData_aligned    <- segData_aligned[DisplayMode == "Continuous"]

exp1.endDat             <- endDat[DisplayMode == "Continuous"]

rm(list = c("Dat_clean", "Dat_raw_clean", "alignedDat_raw", "trial.meanErr.long", "trial.meanErr.wide", "segData_clean", "segData_raw_clean", "segData_aligned", "endDat"))

# Read the data
dat <- read.csv("Experiments/Exp3/Data/Data_raw_all.csv", check.names = F)
dat <- data.table(dat)

Dat_raw <- dat
distrange <- which(dat$z > 0.5 & dat$z < 6)
Dat_clean <- dat[distrange]
Dat_raw_clean <- dat

# If I need to align the beginning the trajectories, it should be here
source("Code/R/align.R")

alignedDat_raw <- ddply(Dat_raw_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo"), plyr::mutate, x = align(headingErr, x, z), z = z - z[1])
alignedDat_raw <- data.table(alignedDat_raw)

# Remove those <-10 and >18.5
## First check the means
### Calculate the mean target-heading angle for each trial
trial.meanErr.long <- ddply(Dat_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo"), plyr::summarise, meanErr = mean(headingErr, na.rm = T))
trial.meanErr.melt <- melt(trial.meanErr.long, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo"))
trial.meanErr.wide <- cast(trial.meanErr.melt, ExpNo + SubjectNo + Familiarity + DisplayMode + PrismDirection + TargetPosition + Collection ~ TrialNo)
with(trial.meanErr.wide, table(Familiarity))

trial.meanErr.long <- data.table(trial.meanErr.long)
pre.subjects.old   <- as.character(unique(trial.meanErr.long[Collection == "Old"]$SubjectNo))
pre.subjects.new   <- as.character(unique(trial.meanErr.long[Collection == "New"]$SubjectNo))
total.n.trials.old <- nrow(trial.meanErr.long[TrialNo < 6 & Collection == "Old"])
total.n.trials.new <- nrow(trial.meanErr.long[TrialNo < 6 & Collection == "New"])

# Find out those with mean target-heading angle larger than 18.5 or smaller than -10
trial.meanErr.long <- data.table(trial.meanErr.long)
weirdo <- which(trial.meanErr.long$meanErr > 18.5 | trial.meanErr.long$meanErr < -10);

## Get the subject no and trial no. for these weirdos
weirdoNo <- as.character(trial.meanErr.long$SubjectNo[weirdo]); weirdoNo     # S127
weirdoTrial <- as.numeric( trial.meanErr.long$TrialNo[weirdo]); weirdoTrial  # 6, 9
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
trial.meanErr.long <- ddply(Dat_clean, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo"), plyr::summarise, meanX = mean(x, na.rm = T), meanErr = mean(headingErr, na.rm = T))

## Iterate through each condition
nSubjects <- as.character(trial.meanErr.wide$SubjectNo)
trial.meanErr.long <- data.table(trial.meanErr.long)
outliers <- NULL; TrialNo <- NULL
source("Code/R/outlierSummary.R")

for (i in 1:10) {
      thisTrial <- trial.meanErr.long[TrialNo == i ]

      this.nSubjects <- as.character(thisTrial$SubjectNo)
      idx <- outlierSummary(thisTrial$meanErr, i, this.nSubjects)
      if (length(idx) > 0 ) {
            outliers <- c(outliers, idx)
            TrialNo <- c(TrialNo, thisTrial$TrialNo[thisTrial$SubjectNo %in% idx])
      }
}

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
cat("Participants to be excluded: ", excl.sbj, "\n")
n.excl.sbj <- length(excl.sbj)

if (length(excl.sbj) > 0 ) {
      excl.sbj.idx          <- which(trial.meanErr.long$SubjectNo %in% excl.sbj)
      trial.meanErr.long    <- trial.meanErr.long[-excl.sbj.idx, ]
      Dat_clean             <- Dat_clean[-which(Dat_clean$SubjectNo %in% excl.sbj), ]
      Dat_raw_clean         <- Dat_raw_clean[-which(Dat_raw_clean$SubjectNo %in% excl.sbj), ]
      alignedDat_raw        <- alignedDat_raw[-which(alignedDat_raw$SubjectNo %in% excl.sbj), ]
}

trial.meanErr.melt <- melt(trial.meanErr.long, c("ExpNo", "SubjectNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo"), measure.vars = "meanErr")
trial.meanErr.wide <- cast(trial.meanErr.melt, ExpNo + SubjectNo + Familiarity + DisplayMode + PrismDirection + TargetPosition + Collection ~ TrialNo)
with(trial.meanErr.wide, table(Familiarity))

trial.meanErr.long <- data.table(trial.meanErr.long)
post.subjects.old   <- as.character(unique(trial.meanErr.long[Collection == "Old"]$SubjectNo))
post.subjects.new   <- as.character(unique(trial.meanErr.long[Collection == "New"]$SubjectNo))

alignedDat <- alignedDat_raw[which(alignedDat_raw$z > 0.5 & alignedDat_raw$z < 6 ), ]

source("Code/R/segCal.R")

segData_clean <- segCal(Dat_clean, datatype = 2)

segData_raw_clean <- segCal(Dat_raw_clean,  nBin = 125, distrange = c(0, 6.25), datatype = 2)

segData_aligned <- segCal(alignedDat, datatype = 2)


# Calculate the early and later part on the trial data
endDat <- NULL

## Early part
early_range_from_target <- c(6, 6.5)
subDat <- Dat_clean[z <= (7 - early_range_from_target[1]) & z >= (7 - early_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, ExpNo, Familiarity, DisplayMode, PrismDirection, TargetPosition, Collection, TrialNo)]
subMean$end <- "early"
endDat <- rbind(endDat, subMean)

## Later part
later_range_from_target <- c(1, 1.5)
subDat <- Dat_clean[z <= (7 - later_range_from_target[1]) & z >= (7 - later_range_from_target[2])]
subMean <- subDat[, .(headingErr = mean(headingErr, na.rm = T), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T)), by = .(SubjectNo, ExpNo, Familiarity, DisplayMode, PrismDirection, TargetPosition, Collection, TrialNo)]
subMean$end <- "late"
endDat <- rbind(endDat, subMean)

# Save data
exp1.Dat_clean$TargetPosition             <- "Known"
exp1.Dat_raw_clean$TargetPosition         <- "Known"
exp1.alignedDat_raw$TargetPosition        <- "Known"
exp1.trial.meanErr.long$TargetPosition    <- "Known"
exp1.trial.meanErr.wide$TargetPosition    <- "Known"
exp1.segData_clean$TargetPosition         <- "Known"
exp1.segData_raw_clean$TargetPosition     <- "Known"
exp1.segData_aligned$TargetPosition       <- "Known"
exp1.endDat$TargetPosition                <- "Known"

exp1.Dat_clean[Familiarity == "Unfamiliar"]$TargetPosition             <- "Unknown"
exp1.Dat_raw_clean[Familiarity == "Unfamiliar"]$TargetPosition         <- "Unknown"
exp1.alignedDat_raw[Familiarity == "Unfamiliar"]$TargetPosition        <- "Unknown"
exp1.trial.meanErr.long[Familiarity == "Unfamiliar"]$TargetPosition    <- "Unknown"
exp1.trial.meanErr.wide[Familiarity == "Unfamiliar"]$TargetPosition    <- "Unknown"
exp1.segData_clean[Familiarity == "Unfamiliar"]$TargetPosition         <- "Unknown"
exp1.segData_raw_clean[Familiarity == "Unfamiliar"]$TargetPosition     <- "Unknown"
exp1.segData_aligned[Familiarity == "Unfamiliar"]$TargetPosition       <- "Unknown"
exp1.endDat[Familiarity == "Unfamiliar"]$TargetPosition                <- "Unknown"


Dat_clean               <- rbind(exp1.Dat_clean, Dat_clean)
Dat_raw_clean           <- rbind(exp1.Dat_raw_clean, Dat_raw_clean)
alignedDat_raw          <- rbind(exp1.alignedDat_raw, alignedDat_raw)
trial.meanErr.long      <- rbind(exp1.trial.meanErr.long, trial.meanErr.long)
trial.meanErr.wide      <- rbind(exp1.trial.meanErr.wide, trial.meanErr.wide)
segData_clean           <- rbind(exp1.segData_clean, segData_clean)
segData_raw_clean       <- rbind(exp1.segData_raw_clean, segData_raw_clean)
segData_aligned         <- rbind(exp1.segData_aligned, segData_aligned)
endDat                  <- rbind(exp1.endDat, endDat)

save(Dat_clean, Dat_raw_clean, alignedDat_raw, file = "Experiments/Exp3/Data/Data_clean.RData")
save(trial.meanErr.long, trial.meanErr.wide, file = "Experiments/Exp3/Data/meanErr.RData")
save(segData_clean, segData_raw_clean, segData_aligned, file = "Experiments/Exp3/Data/segData.RData")
save(endDat, file = "Experiments/Exp3/Data/endData.RData")
save(total.n.trials.new, total.n.trials.old, n.outside.range.trials, n.outside.3SD.trials, pre.subjects.new, pre.subjects.old, post.subjects.new, post.subjects.old, file = "Experiments/Exp3/Data/Subjects.RData")

rm(list = ls())






