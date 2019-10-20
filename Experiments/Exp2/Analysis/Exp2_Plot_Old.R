library(ggplot2); library(plyr); library(reshape); library(showtext); library(data.table); library(cowplot); library(polynom); library(minpack.lm); library(grid)

# Take care of the paths 
source("Code/R/egolineCal.R")
deflection <- 8.5
egoline <- egolineCal(prismDeg = deflection)

# Load the data
load('Experiments/Exp2/Data/meanErr.RData')
load('Experiments/Exp2/Data/segData.RData')

segData         <- data.table(segData_clean)
segData.aligned <- data.table(segData_aligned)

segData$DisplayMode           <- droplevels(segData$DisplayMode)
segData.aligned$DisplayMode   <- droplevels(segData.aligned$DisplayMode)

segData[ExpNo == "Lit"]$DisplayMode         <- "Continuous"
segData.aligned[ExpNo == "Lit"]$DisplayMode <- "Continuous"

segData$ExpNo           <- factor(segData$ExpNo, levels = levels(segData$ExpNo)[c(1, 3, 2)])
segData.aligned$ExpNo   <- factor(segData.aligned$ExpNo, levels = levels(segData.aligned$ExpNo)[c(1, 3, 2)])

offset.segData  			<- segData[TrialNo %in% c(1:5) & Collection == "Old", ]
offset.segData.aligned  <- segData.aligned[TrialNo %in% c(1:5) & Collection == "Old", ]

offset.segMean 			<- offset.segData[, .(x = mean(x, na.rm = T), headingErr = mean(headingErr, na.rm = T)), by = c("SubjectNo", "ExpNo", "Familiarity", "DisplayMode", "seg.z")]
offset.segMean.aligned 	<- offset.segData.aligned[, .(x = mean(x, na.rm = T), headingErr = mean(headingErr, na.rm = T)), by = c("SubjectNo", "ExpNo", "Familiarity", "DisplayMode", "seg.z")]

# Mean trajectories
trj_plot_l <- ggplot(offset.segMean.aligned[DisplayMode == "Continuous"], aes(seg.z, x)) + theme_light() +
      geom_line(data = egoline, aes(x = pred_y, y = pred_x), colour = "#595959", linetype = 2, size = 1) +
      stat_summary(fun.data = "mean_se", geom = "ribbon", aes(group = Familiarity , fill = Familiarity ), alpha = 0.25, show.legend = FALSE) +
      stat_summary(fun.y = "mean", geom = "line", aes(group = Familiarity , colour = Familiarity), size = 1 ) +
      geom_vline(xintercept = 0, size = 0.5) + geom_hline(yintercept = 0, size = 0.5) + 
      coord_flip(xlim = c(0, 7), ylim = c(0, 0.5)) +
      labs(x = "Z Position (m)", y = "X Position (m)") +
      scale_color_manual(name = "", values = c("grey5", "grey65")) +
      scale_fill_manual(name = "", values = c("grey5", "grey65")) +
      facet_grid(ExpNo ~ DisplayMode) +
      theme(panel.background = element_rect(fill = "transparent", colour = NA),
            panel.grid = element_blank(), 
            panel.border = element_blank(),
            axis.line = element_line(colour = "black"),
            strip.background = element_rect(fill = "grey25"),
            strip.text = element_text(size = 12, face = "bold"),
            # panel.spacing = unit(0.75, "lines"),
            plot.margin = unit(c(1, 0.5, 0, 1), "lines"),
            plot.background = element_rect(fill = "transparent", colour = NA),
            axis.text.x = element_text(size = 10),
            axis.text.y = element_text( size = 10),
            axis.title = element_text( size = 12, colour = "#595959"),
            legend.position = "none")

trj_plot_r <- ggplot(offset.segMean.aligned[DisplayMode == "Intermittent"], aes(seg.z, x)) + theme_light() +
            geom_line(data = egoline, aes(x = pred_y, y = pred_x), colour = "#595959", linetype = 2, size = 1) +
            stat_summary(fun.data = "mean_se", geom = "ribbon", aes(group = Familiarity , fill = Familiarity ), alpha = 0.25, show.legend = FALSE) +
            stat_summary(fun.y = "mean", geom = "line", aes(group = Familiarity , colour = Familiarity), size = 1 ) +
            geom_vline(xintercept = 0, size = 0.5) + geom_hline(yintercept = 0, size = 0.5) + 
            coord_flip(xlim = c(0, 7), ylim = c(0, 0.5)) +
            labs(x = "Z Position (m)", y = "X Position (m)") +
            scale_color_manual(name = "", values = c("grey5", "grey65")) +
            scale_fill_manual(name = "", values = c("grey5", "grey65")) +
            facet_grid(ExpNo ~ DisplayMode) +
            theme(panel.background = element_rect(fill = "transparent", colour = NA),
                  panel.grid = element_blank(), 
                  panel.border = element_blank(),
                  axis.line = element_line(colour = "black"),
                  strip.background = element_rect(fill = "grey25"),
                  strip.text = element_text(size = 12, face = "bold"),
                  # panel.spacing = unit(0.75, "lines"),
                  plot.margin = unit(c(1, 0.5, 0, 1), "lines"),
                  plot.background = element_rect(fill = "transparent", colour = NA),
                  axis.text.x = element_text(size = 10),
                  axis.text.y = element_text( size = 10),
                  axis.title = element_text( size = 12, colour = "#595959"),
                  legend.title = element_blank(),
                  legend.background = element_rect(fill = "transparent", colour = NA),
                  legend.key = element_rect(fill = "transparent", colour = NA),
                  legend.position = c(0.5, 0.1),
                  legend.text = element_text( size = 10, colour = "#595959"))

grid.newpage()

pushViewport(viewport(layout = grid.layout(nrow = 3, ncol = 2)))

define_region <- function(row, col) viewport(layout.pos.row = row, layout.pos.col = col)

print(trj_plot_l, vp = define_region(row = 1:3, col = 1))
print(trj_plot_r, vp = define_region(row = 1:2, col = 2))

trj_plot <- ggplot(offset.segMean.aligned, aes(seg.z, x)) + theme_light() +
   geom_rect(data = offset.segData.aligned[ExpNo == "Dark"], aes(xmin = -1, xmax = Inf, ymin = 0, ymax = 1), fill = "grey95", alpha = 0.1) +
   geom_line(data = egoline, aes(x = pred_y, y = pred_x), colour = "#595959", linetype = 2, size = 1) +
   stat_summary(fun.data = "mean_se", geom = "ribbon", aes(group = Familiarity , fill = Familiarity ), alpha = 0.25, show.legend = FALSE) +
   stat_summary(fun.y = "mean", geom = "line", aes(group = Familiarity , colour = Familiarity), size = 1 ) +
   geom_vline(xintercept = 0, size = 0.5) + geom_hline(yintercept = 0, size = 0.5) + 
   coord_flip(xlim = c(0, 7), ylim = c(0, 0.5)) +
   labs(x = "Z Position (m)", y = "X Position (m)") +
   scale_color_manual(name = "", values = c("grey5", "grey65")) +
   scale_fill_manual(name = "", values = c("grey5", "grey65")) +
   facet_grid(ExpNo ~ DisplayMode) +
   theme(panel.background = element_rect(fill = "transparent", colour = NA),
         panel.grid = element_blank(), 
         panel.border = element_blank(),
         axis.line = element_line(colour = "black"),
         strip.background = element_rect(fill = "grey25"),
         strip.text = element_text(size = 12, face = "bold"),
         # panel.spacing = unit(0.75, "lines"),
         plot.margin = unit(c(1, 0.5, 0, 1), "lines"),
         plot.background = element_rect(fill = "transparent", colour = NA),
         axis.text.x = element_text(size = 10),
         axis.text.y = element_text( size = 10),
         axis.title = element_text( size = 12, colour = "#595959"),
         legend.title = element_blank(),
         legend.background = element_rect(fill = "transparent", colour = "grey25"),
         legend.key = element_rect(fill = "transparent", colour = NA),
         legend.position = c(0.75, 0.15),
         legend.text = element_text( size = 10, colour = "#595959"))

g <- ggplotGrob( trj_plot)
g$layout$name

pos <- grepl(pattern = "panel-2-3", g$layout$name)
g$grobs <- g$grobs[!pos]
g$layout <- g$layout[!pos, ]

g$layout[g$layout$name == "axis-b-2", c("t", "b")] = c(11, 11)
g$layout[g$layout$name == "strip-r-3", c("l", "r")] = c(6, 6)

grid.newpage()
grid.draw(g)

# ggplot2::ggsave("Experiments/Exp2/Figures/Figure_1a_Old.pdf", width = 5.7, height = 6.4, units = "in")
# ggplot2::ggsave("Experiments/Exp2/Figures/Figure_1a_Old.png", width = 5.7, height = 6.4, units = "in")
#
# Export the figure directly using "Export" option: 570 x 640

# Target-heading angles as a function of distance
THA_plot <- ggplot(offset.segMean.aligned, aes(seg.z, headingErr)) + theme_bw() +
      geom_hline(yintercept = deflection, colour = "#595959", linetype = 2, size = 1) +
      stat_summary(fun.data = "mean_se", geom = "ribbon", aes(group = Condition , fill = Condition ), alpha = 0.25, show.legend = FALSE) +
      stat_summary(fun.y = "mean", geom = "line", aes(group = Condition , colour = Condition), size = 1) +
      geom_vline(xintercept = 0, size = 0.5) + geom_hline(yintercept = 0, size = 0.5) + 
      coord_cartesian(xlim = c(0, 6.5), ylim = c(0, 10)) +
      labs(x = "Z Position (m)", y = "Target-heading angle (°)") +
      # scale_color_manual(name = "", values = c("grey5", "grey65")) +
      # scale_fill_manual(name = "", values = c("grey5", "grey65")) +
      scale_colour_brewer(name = "", palette = "Set1") +
      scale_fill_brewer(name = "", palette = "Set1") +
      theme(panel.background = element_rect(fill = "transparent", colour = NA),
            panel.grid = element_blank(), 
            panel.border = element_blank(),
            axis.line = element_line(colour = "black"),
            # panel.spacing = unit(0.75, "lines"),
            plot.margin = unit(c(1, 0.5, 0, 1), "lines"),
            plot.background = element_rect(fill = "transparent", colour = NA),
            axis.text.x = element_text( size = 10),
            axis.text.y = element_text( size = 10),
            axis.title = element_text( size = 12, colour = "#595959"),
            legend.title = element_blank(),
            legend.background = element_rect(fill = "transparent", colour = NA),
            legend.key = element_rect(fill = "transparent", colour = NA),
            legend.position = c(0.6, 0.15),
            legend.text = element_text( size = 10, colour = "#595959"))

# Overall mean target-heading angles between familiar and unfamilair groups
# offset.err  <- meanErr[TrialNo %in% c(1:5) & (TargetPosition == 'Known' | Familiarity == 'Unfamiliar')]
# offset.mean <- offset.err[, .(meanErr = mean(meanErr, na.rm = T)), by = c('SubjectNo', 'Familiarity', 'TargetPosition', 'PrismDirection')]
# 
# THA_bar <- ggplot(offset.mean, aes(Familiarity, meanErr, group = Familiarity)) + theme_minimal() +
#       geom_hline(yintercept = 0, colour = "black") +
#       stat_summary(fun.y = mean, geom = "bar", position = position_dodge(width = 0.9), aes(fill = Familiarity)) +
#       stat_summary(fun.data = mean_se, geom = "errorbar", position = position_dodge(width = .9), width = .2, aes(colour = Familiarity)) +
#       coord_cartesian(ylim = c(0, 10)) +
#       scale_fill_manual(name = "", values = c("grey5", "grey65")) +
#       scale_color_manual(name = "", values = c("grey65", "grey5")) +
#       labs(x = "Familiarity", y = "Mean target-heading angle over distance (°)") +
#       theme(legend.position = "none",
#             axis.title = element_text(family = "Helvetica", size = 12, colour = "#595959"),
#             axis.text = element_text(family = "Helvetica", size = 10))

# Put them together
# prow     <- plot_grid(NULL, trajectory_plot, NULL, THA_plot,  labels = c("a", "", "b", ""), label_size = 18, align = "vh", nrow = 1, rel_widths = c(.05, 1, .05, 1.2))
# prow
# 
# ggplot2::ggsave("Experiments/Exp1/Figures/Figure_1.png", width = 24, height = 12, units = "cm")


tha_plot <- ggplot(offset.segMean.aligned, aes(seg.z, headingErr)) + theme_light() +
   geom_rect(data = offset.segData.aligned[ExpNo == "Dark"], aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf), fill = "grey95", alpha = 0.1) +
   geom_hline(yintercept = deflection, colour = "#595959", linetype = 2, size = 1) +
   stat_summary(fun.data = "mean_se", geom = "ribbon", aes(group = Familiarity , fill = Familiarity ), alpha = 0.25, show.legend = FALSE) +
   stat_summary(fun.y = "mean", geom = "line", aes(group = Familiarity , colour = Familiarity), size = 1 ) +
   geom_vline(xintercept = 0, size = 0.5) + geom_hline(yintercept = 0, size = 0.5) + 
   coord_cartesian(xlim = c(0, 6.5), ylim = c(0, 11)) +
   labs(x = "Z Position (m)", y = "Target-heading angle (°)") +
   scale_color_manual(name = "", values = c("grey5", "grey65")) +
   scale_fill_manual(name = "", values = c("grey5", "grey65")) +
   facet_grid(ExpNo ~ DisplayMode) +
   theme(panel.background = element_rect(fill = "transparent", colour = NA),
         panel.grid = element_blank(), 
         panel.border = element_blank(),
         axis.line = element_line(colour = "black"),
         strip.background = element_rect(fill = "grey25"),
         strip.text = element_text(size = 12, face = "bold"),
         # panel.spacing = unit(0.75, "lines"),
         plot.margin = unit(c(1, 0.5, 0, 1), "lines"),
         plot.background = element_rect(fill = "transparent", colour = NA),
         axis.text.x = element_text(size = 10),
         axis.text.y = element_text( size = 10),
         axis.title = element_text( size = 12, colour = "#595959"),
         legend.title = element_blank(),
         legend.background = element_rect(fill = "transparent", colour = "grey25"),
         legend.key = element_rect(fill = "transparent", colour = NA),
         legend.position = c(0.75, 0.15),
         legend.text = element_text( size = 10, colour = "#595959"))

g <- ggplotGrob( tha_plot)
g$layout$name

pos <- grepl(pattern = "panel-2-3", g$layout$name)
g$grobs <- g$grobs[!pos]
g$layout <- g$layout[!pos, ]

g$layout[g$layout$name == "axis-b-2", c("t", "b")] = c(11, 11)
g$layout[g$layout$name == "strip-r-3", c("l", "r")] = c(6, 6)

grid.newpage()
grid.draw(g)

# ggplot2::ggsave("Experiments/Exp2/Figures/Figure_1b_Old.png", width = 5.7, height = 6.4, units = "in")
# ggplot2::ggsave("Experiments/Exp2/Figures/Figure_1b_Old.pdf", width = 5.7, height = 6.4, units = "in")

# Export the figure directly using "Export" option: 570 x 640
