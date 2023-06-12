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
    df <- full_join(df, df2, by=c('species', 'genus'))
}

df <- replace(df, is.na(df), 0)
palette <- distinctColorPalette(length(unique(df$genus)))
genus_cols = setNames(palette, unique(df$genus))
df$genus <- factor(df$genus, levels=unique(df$genus))

df <- df[order(as.numeric(df$genus)),]

mat <- as.matrix(df[3:length(df)])
mat <- replace(mat, mat == 0 , 1)
mat <- log10(mat)

rownames(mat) = df$species

row_ha = rowAnnotation(genus = df$genus,
                       col = list(genus = genus_cols),
                       gp = gpar(col = "#c6c6c4"),
                       annotation_name_gp= gpar(fontface = "bold"),
                       annotation_legend_param = list(genus = list(at = unique(df$genus)))
                       )

png(args[3], width = 63.5, height = 40, units = "cm", res = 100)
ht<- Heatmap(mat, name = "RPM (log 10)", col = col_fun, rect_gp = gpar(col = "#c6c6c4", lwd = 1), use_raster = TRUE, raster_device = "png",
        show_column_name = FALSE, show_row_dend = FALSE, show_column_dend = FALSE, row_names_side = "right", row_labels = rownames(mat), cluster_row_slices = FALSE, row_title = NULL,
        column_order = colnames(mat), left_annotation = row_ha, row_names_gp = gpar(fontface = "italic")
)

draw(ht)
dev.off()