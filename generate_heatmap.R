library(dplyr)
library(readr)
library(ComplexHeatmap)
library(GetoptLong)
library(circlize)
library(randomcoloR)
col_fun = colorRamp2(c(0, 0, 5), c("#f3f1ec", "white", "#dc0626"))

args = commandArgs(trailingOnly=TRUE)

myfilelist <- strsplit(args[1], ",")[[1]]
mynamelist <- strsplit(args[2], ",")[[1]]

if (length(myfilelist) > 1){
  df <- read_csv(myfilelist[1], 
                  col_types = cols(count = col_integer()))

  colnames(df)[3] = mynamelist[1]

  for (i in 2:(length(myfilelist))) {
    # Access the current element and the next one
      curr_file <- myfilelist[i]
      
      df2 <- read_csv(curr_file, 
                      col_types = cols(count = col_integer()))
      colnames(df2)[3] = mynamelist[i]

      # Perform some operation. For example, print the sum of the current and next element
      df <- full_join(df, df2, by=c('species', 'family'))
  }
} else {
  df <- read_csv(myfilelist[1], 
                  col_types = cols(count = col_integer()))
  colnames(df)[3] = mynamelist[1]
}

df <- replace(df, is.na(df), 0)
palette <- distinctColorPalette(length(unique(df$family)))
family_cols = setNames(palette, unique(df$family))
df$family <- factor(df$family, levels=unique(df$family))

df <- df[order(as.numeric(df$family)),]
df <- df[apply(df[,-c(1,2)], 1, function(x) !all(x==0)),]


join_df <- data.frame(Sample = colnames(df)[-(1:2)])
mmc1 <- read_csv(args[3])
left_joined <- left_join(join_df, mmc1, by=c('Sample'))

ordered_mmc2 <- df[left_joined$Sample]

mat <- as.matrix(ordered_mmc2)
mat <- replace(mat, mat == 0 , 1)
mat <- log10(mat)

rownames(mat) = df$species

row_ha = rowAnnotation(family = df$family,
                       col = list(family = family_cols),
                       gp = gpar(col = "#c6c6c4"),
                       annotation_name_gp= gpar(fontface = "bold"),
                       annotation_legend_param = list(family = list(at = unique(df$family)))
                       )

host_species_palette <- distinctColorPalette(length(unique(left_joined$`Host species`)))
host_species_cols = setNames(host_species_palette, unique(left_joined$`Host species`))

ha = HeatmapAnnotation(
  `Host species` = left_joined$`Host species`,
  `Health condition` =  left_joined$`Health condition`,
  col = list(`Host species` = host_species_cols,
             `Health condition` = c("Healthy" = "#4dc8f0", "Unhealthy" = "#cdd3d9")
  ),
  gp = gpar(col = "#c6c6c4"),
  gap = unit(2, "mm"),
  annotation_name_gp= gpar(fontface = c("bold", "bold", "italic")),
  annotation_legend_param = list(`Host species` = list(at = unique(left_joined$`Host species`)),
                                 `Health condition` = list(at = c("Healthy", "Unhealthy")))
)

png(args[4], width = 70, height = 40, units = "cm", res = 100)
ht<- Heatmap(mat, name = "RPM (log 10)", col = col_fun, rect_gp = gpar(col = "#c6c6c4", lwd = 1), use_raster = TRUE, raster_device = "png",
        show_column_name = FALSE, show_row_dend = FALSE, show_column_dend = FALSE, row_names_side = "right", row_labels = rownames(mat), cluster_row_slices = FALSE, row_title = NULL,
        row_order = rownames(mat), column_order = colnames(mat), left_annotation = row_ha, row_names_gp = gpar(fontface = "italic"),
        top_annotation = ha, heatmap_legend_param = list(direction = "horizontal"))

draw(ht)
dev.off()
