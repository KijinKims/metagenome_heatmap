library(dplyr)
library(readr)
library(ComplexHeatmap)
library(GetoptLong)
library(circlize)
library(randomcoloR)
library(argparse)
col_fun = colorRamp2(c(0, 0, 5), c("#f3f1ec", "white", "#dc0626"))

parser <- ArgumentParser()

parser$add_argument("-f", "--files",
    help="Input file as comma-delimited list.",
    metavar="file1.txt,file2.txt,file3.txt")
parser$add_argument("-n", "--names",
    help="Sample name as comma-delimited list. Each corresponds to the input file standing at the same position.",
    metavar="sample1,sample2,sample3")
parser$add_argument("-m", "--metadata", 
    help="Metadata as in csv consisting of three columns: Sample, Host species, Health condition. Health condition should be either Healthy or Unhealthy.",
    metavar="metadata.csv")
parser$add_argument("-o", "--output", 
    help="Output file path. It should be with .png.",
    metavar="output.png")
parser$add_argument("--min-read-count", type="integer", default=1, 
    help = "Minimum read count to be considered.")
parser$add_argument('-e', "--export_raw",
    default = "",
    metavar="export.csv",
    help = "File path to which the raw read count matrix is exported.")

args <- parser$parse_args()

myfilelist <- strsplit(args$files, ",")[[1]]
mynamelist <- strsplit(args$names, ",")[[1]]

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
df <- df[apply(df[,-c(1,2)], 1, function(x) !all(x<=args$min_read_count)),]

palette <- distinctColorPalette(length(unique(df$family)))
family_cols = setNames(palette, unique(df$family))
df$family <- factor(df$family, levels=unique(df$family))
df <- df[order(df$family), ]

if(args$export_raw != ""){
  write.csv(df, args$export_raw, row.names=FALSE, quote=FALSE)
}

join_df <- data.frame(Sample = colnames(df)[-(1:2)])
mmc1 <- read_csv(args$metadata)
left_joined <- left_join(join_df, mmc1, by=c('Sample'))

ordered_mmc2 <- df[left_joined$Sample]

mat <- as.matrix(ordered_mmc2)
mat <- replace(mat, mat == 0 , 1)
mat <- log10(mat)

rownames(mat) = df$species

row_ha = rowAnnotation(Family = df$family,
                       col = list(Family = family_cols),
                       gp = gpar(col = "#c6c6c4"),
                       annotation_name_gp= gpar(fontface = "bold"),
                       annotation_legend_param = list(Family = list(at = unique(df$family)))
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
  annotation_name_gp= gpar(fontface = c("bold", "bold")),
  annotation_legend_param = list(`Host species` = list(at = unique(left_joined$`Host species`)),
                                 `Health condition` = list(at = c("Healthy", "Unhealthy")))
)

setEPS()
postscript(args$output, width = 28, height = 15)
ht<- Heatmap(mat, name = "RPM (log 10)", col = col_fun, rect_gp = gpar(col = "#c6c6c4", lwd = 1), use_raster = TRUE, raster_device = "png",
        show_column_name = FALSE, show_row_dend = FALSE, show_column_dend = FALSE, row_labels = rownames(mat), cluster_row_slices = FALSE, row_title = NULL,
        row_names_max_width = unit(12, "cm"), row_names_side = "left", row_order = rownames(mat), column_order = colnames(mat), right_annotation = row_ha, row_names_gp = gpar(fontface = "italic"),
        top_annotation = ha, heatmap_legend_param = list(direction = "vertical"))

draw(ht)
dev.off()

setEPS()
postscript(paste0("true_order_", args$output), width = 4, height = 15)
draw(row_ha)
dev.off()