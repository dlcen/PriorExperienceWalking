segCal <- function(rawData, nBin = 100, distrange = c(0.5, 6), datatype = 1) {
      itv <- (distrange[2] - distrange[1])/nBin
      z_seg <- seq(distrange[1], distrange[2], itv)
      
      rawData$segNo <- 0
      rawData$seg.z <- 0
      for (i in 2:length(z_seg)) {
            period <- which(rawData$z > z_seg[i - 1] & rawData$z <= z_seg[i])
            rawData$segNo[period] <- i - 1
            rawData$seg.z[period] <- z_seg[i-1]
      }
      
      if (datatype == 1) {
            segData <- ddply(rawData, c("SubjectNo", "ExpNo", "Familiarity", "DisplayMode", "PrismDirection", "Collection", "TrialNo", "seg.z", "segNo"), plyr::summarize, x = mean(x, na.rm = TRUE), headingErr = mean(headingErr, na.rm = TRUE), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T), pitch = mean(pitch, na.rm = T))
      } else {
            segData <- ddply(rawData, c("SubjectNo", "ExpNo", "Familiarity", "DisplayMode", "PrismDirection", "TargetPosition", "Collection", "TrialNo", "seg.z", "segNo"), plyr::summarize, x = mean(x, na.rm = TRUE), headingErr = mean(headingErr, na.rm = TRUE), headYawTg = mean(headYawTg, na.rm = T), bodyYawTg = mean(bodyYawTg, na.rm = T), pitch = mean(pitch, na.rm = T))
      }
      
      return(segData)
}