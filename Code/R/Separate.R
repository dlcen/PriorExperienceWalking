
library(data.table)

# Separate the data of conditions other than Dark-Continuous into:
#     - Dark-Intermittent
#     - Strobe
#     - Lit

## Read data from "OtherConditions"
load("OtherConditions/FilteredPad/Data/Data_clean.RData")
load("OtherConditions/FilteredPad/Data/meanErr.RData")
load("OtherConditions/FilteredPad/Data/segData.RData")
load("OtherConditions/FilteredPad/Data/endData.RData")

Data.clean           <- data.table(Dat_clean)
Data.all.clean       <- data.table(Dat_raw_clean)
Data.all.aligned     <- data.table(alignedDat_raw)
segData.clean        <- data.table(segData_clean)
segData.all.clean    <- data.table(segData_raw_clean)
segData.aligned      <- data.table(segData_aligned)
meanErr.long         <- data.table(trial.meanErr.long)
endData              <- data.table(endDat)

## Save the data for Dark-Intermittent condition
Data.clean             <- Data.clean[ExpNo == "Dark"]
Data.all.clean         <- Data.all.clean[ExpNo == "Dark"]
Data.all.aligned       <- Data.all.aligned[ExpNo == "Dark"]
segData.clean          <- segData.clean[ExpNo == "Dark"]
segData.all.clean      <- segData.all.clean[ExpNo == "Dark"]
segData.aligned        <- segData.aligned[ExpNo == "Dark"]
meanErr.long           <- meanErr.long[ExpNo == "Dark"]
endData                <- endDat[ExpNo == "Dark"]

save(Data.clean, Data.all.clean, Data.all.aligned, file = "DarkIntermittent/FilteredPad/Data/Data_clean.RData")
save(meanErr.long, file = "DarkIntermittent/FilteredPad/Data/meanErr.RData")
save(segData.clean, segData.all.clean, segData.aligned, file = "DarkIntermittent/FilteredPad/Data/segData.RData")
save(endData, file = "DarkIntermittent/FilteredPad/Data/endData.RData")

## Save the data for the Strobe condition
Data.clean           <- data.table(Dat_clean)
Data.all.clean       <- data.table(Dat_raw_clean)
Data.all.aligned     <- data.table(alignedDat_raw)
segData.clean        <- data.table(segData_clean)
segData.all.clean    <- data.table(segData_raw_clean)
segData.aligned      <- data.table(segData_aligned)
meanErr.long         <- data.table(trial.meanErr.long)
endData              <- data.table(endDat)

Data.clean             <- Data.clean[ExpNo == "Strobe"]
Data.all.clean         <- Data.all.clean[ExpNo == "Strobe"]
Data.all.aligned       <- Data.all.aligned[ExpNo == "Strobe"]
segData.clean          <- segData.clean[ExpNo == "Strobe"]
segData.all.clean      <- segData.all.clean[ExpNo == "Strobe"]
segData.aligned        <- segData.aligned[ExpNo == "Strobe"]
meanErr.long           <- meanErr.long[ExpNo == "Strobe"]
endData                <- endDat[ExpNo == "Strobe"]

save(Data.clean, Data.all.clean, Data.all.aligned, file = "Strobe/FilteredPad/Data/Data_clean.RData")
save(meanErr.long, file = "Strobe/FilteredPad/Data/meanErr.RData")
save(segData.clean, segData.all.clean, segData.aligned, file = "Strobe/FilteredPad/Data/segData.RData")
save(endData, file = "Strobe/FilteredPad/Data/endData.RData")

# Save the data for the Lit condition
Data.clean           <- data.table(Dat_clean)
Data.all.clean       <- data.table(Dat_raw_clean)
Data.all.aligned     <- data.table(alignedDat_raw)
segData.clean        <- data.table(segData_clean)
segData.all.clean    <- data.table(segData_raw_clean)
segData.aligned      <- data.table(segData_aligned)
meanErr.long         <- data.table(trial.meanErr.long)
endData              <- data.table(endDat)

Data.clean             <- Data.clean[ExpNo == "Lit"]
Data.all.clean         <- Data.all.clean[ExpNo == "Lit"]
Data.all.aligned       <- Data.all.aligned[ExpNo == "Lit"]
segData.clean          <- segData.clean[ExpNo == "Lit"]
segData.all.clean      <- segData.all.clean[ExpNo == "Lit"]
segData.aligned        <- segData.aligned[ExpNo == "Lit"]
meanErr.long           <- meanErr.long[ExpNo == "Lit"]
endData                <- endDat[ExpNo == "Lit"]

save(Data.clean, Data.all.clean, Data.all.aligned, file = "Lit/FilteredPad/Data/Data_clean.RData")
save(meanErr.long, file = "Lit/FilteredPad/Data/meanErr.RData")
save(segData.clean, segData.all.clean, segData.aligned, file = "Lit/FilteredPad/Data/segData.RData")
save(endData, file = "Lit/FilteredPad/Data/endData.RData")

