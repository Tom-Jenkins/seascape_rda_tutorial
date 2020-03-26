# --------------------------- #
#
# Tutorial:
# Seascape Redundancy Analysis
# 
# Description:
# Prepare environmental data for redundancy analysis.
#
# Environmental variables:
# Mean sea surface temperature (SST): Present-day (celsius)
# Mean sea bottom temperature (SBT): Present-day (celsius)
# Mean sea surface salinity (SSS): Present-day (practical salinity scale)
# Mean sea bottom salinity (SBS): Present-day (practical salinity scale)
# Mean sea surface chlorophyll (SSC): Present-day (mg/m3)
# Mean sea surface calcite (SSCa): Present-day (mol/m3)
#  
# Data downloaded from http://www.bio-oracle.org
# A website containing marine data layers for ecological modelling.
# Files are in .asc format.
#
# Notes before execution:
# 1. Make sure all required R packages are installed.
# 2. Set working directory to the location of this R script.
#
# --------------------------- #

# Load packages
library(raster)
library(dplyr)
library(rworldmap)
library(rworldxtra)
library(ggplot2)
library(RColorBrewer)
library(ggpubr)


#--------------#
#
# Extract data
#
#--------------#

# Prepare data for extraction
sst.present = raster("Present.Surface.Temperature.Mean.asc")
sbt.present = raster("Present.Benthic.Max.Depth.Temperature.Mean.asc")
sss.present = raster("Present.Surface.Salinity.Mean.asc")
sbs.present = raster("Present.Benthic.Max.Depth.Salinity.Mean.asc")
ssc.present = raster("Present.Surface.Chlorophyll.Mean.asc")
ssca.present = raster("Present.Surface.Calcite.Mean.asc")

# Import coordinates of sites
coords = read.csv("coordinates.csv")
names(coords)

# Create SpatialPoints object using coordinates
points = SpatialPoints(subset(coords, select = c("Lon","Lat")))

# Extract environmental data for each site and combine into dataframe
df = data.frame(site = coords$Site,
                sst_mean = extract(sst.present, points),
                sbt_mean = extract(sbt.present, points),
                sss_mean = extract(sss.present, points),
                sbs_mean = extract(sbs.present, points),
                ssc_mean = extract(ssc.present, points),
                ssca_mean = extract(ssca.present, points)
)

# Export data as a csv file
write.csv(df, file="environmental_data.csv", row.names = FALSE)


#--------------#
#
# Plot heatmaps
#
#--------------#

# Set map boundary (xmin, xmax, ymin, ymax)
extent(points)
boundary = extent(-20, 30, 35, 65)
boundary

# Crop rasters to boundary and convert to a dataframe of points
sst.df = crop(sst.present, y = boundary) %>% rasterToPoints() %>% data.frame()
sbt.df = crop(sbt.present, y = boundary) %>% rasterToPoints() %>% data.frame()
sss.df = crop(sss.present, y = boundary) %>% rasterToPoints() %>% data.frame()
sbs.df = crop(sbs.present, y = boundary) %>% rasterToPoints() %>% data.frame()
ssc.df = crop(ssc.present, y = boundary) %>% rasterToPoints() %>% data.frame()
ssca.df = crop(ssca.present, y = boundary) %>% rasterToPoints() %>% data.frame()

# Download a basemap
basemap = getMap(resolution = "high")

# Crop to boundary and convert to dataframe
basemap = crop(basemap, y = boundary) %>% fortify()

# Create a ggplot theme for heatmaps
ggtheme = theme(axis.title = element_text(size = 12),
                axis.text = element_text(size = 10, colour = "black"),
                panel.border = element_rect(fill = NA, colour = "black", size = 0.5),
                legend.title = element_text(size = 13),
                legend.text = element_text(size = 12),
                plot.title = element_text(size = 15, hjust = 0.5),
                panel.grid = element_blank())

# Define colour palettes
temp.cols = colorRampPalette(c("blue","white","red"))
sal.cols = colorRampPalette(c("darkred","white"))
chlor.cols = colorRampPalette(c("white","green"))
calct.cols = colorRampPalette(c("white","#662506"))

# Sea surface temperature
sst.plt = ggplot()+
  geom_tile(data = sst.df, aes(x = x, y = y, fill = sst.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea surface temperature (present-day)")+
  scale_fill_gradientn(expression(~degree~C), colours = temp.cols(10), limits = c(-1.5,24))+
  ggtheme
sst.plt
ggsave("1.sst_heatmap.png", width = 10, height = 9, dpi = 600)

# Sea bottom temperature
sbt.plt = ggplot()+
  geom_tile(data = sbt.df, aes(x = x, y = y, fill = sbt.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea bottom temperature (present-day)")+
  scale_fill_gradientn(expression(~degree~C), colours = temp.cols(10), limits = c(-1.5,24))+
  ggtheme
sbt.plt
ggsave("2.sbt_heatmap.png", width = 10, height = 9, dpi = 600)

# Sea surface salinity
sss.plt = ggplot()+
  geom_tile(data = sss.df, aes(x = x, y = y, fill = sss.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea surface salinity (present-day)")+
  scale_fill_gradientn("PPS", colours = sal.cols(10), limits = c(1,40))+
  ggtheme
sss.plt
ggsave("3.sss_heatmap.png", width = 10, height = 9, dpi = 600)

# Sea bottom salinity
sbs.plt = ggplot()+
  geom_tile(data = sbt.df, aes(x = x, y = y, fill = sbs.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea bottom salinity (present-day)")+
  scale_fill_gradientn("PPS", colours = sal.cols(10), limits = c(1,40))+
  ggtheme
sbs.plt
ggsave("4.sbs_heatmap.png", width = 10, height = 9, dpi = 600)

# Sea surface chlorophyll
ssc.plt = ggplot()+
  geom_tile(data = ssc.df, aes(x = x, y = y, fill = ssc.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea surface chlorophyll (present-day)")+
  scale_fill_gradientn(expression(paste("mg/m"^"3")), colours = chlor.cols(10))+
  ggtheme
ssc.plt
ggsave("5.ssc_heatmap.png", width = 10, height = 9, dpi = 600)

# Sea surface calcite
ssca.plt = ggplot()+
  geom_tile(data = ssca.df, aes(x = x, y = y, fill = ssca.df[, 3]))+
  geom_polygon(data = basemap, aes(x = long, y = lat, group = group))+
  coord_quickmap(expand = F)+
  xlab("Longitude")+
  ylab("Latitude")+
  ggtitle("Sea surface calcite (present-day)")+
  scale_fill_gradientn(expression(paste("mol/m"^"3")), colours = calct.cols(10))+
  ggtheme
ssca.plt
ggsave("6.ssca_heatmap.png", width = 10, height = 9, dpi = 600)

# Combine two temperature ggplots
figAB = ggarrange(sst.plt + labs(tag = "A") + ggtheme + theme(axis.title.y = element_blank()),
                  sbt.plt + labs(tag = "B") + ggtheme + theme(axis.title.y = element_blank()),
                  ncol = 2, common.legend = TRUE, legend = "right")
figAB = annotate_figure(figAB,
                        left = text_grob("Latitude", size = 12, rot = 90))

# Combine two salinity ggplots
figCD = ggarrange(sss.plt + labs(tag = "C") + ggtheme + theme(axis.title.y = element_blank()),
                  sbs.plt + labs(tag = "D") + ggtheme + theme(axis.title.y = element_blank()),
                  ncol = 2, common.legend = TRUE, legend = "right")
figCD = annotate_figure(figCD,
                        left = text_grob("Latitude", size = 12, rot = 90))

# Combine temperature and salinity ggplots
fig = ggarrange(figAB, figCD, nrow = 2)
ggsave("7.temp_sal_heatmap.png", width = 10, height = 10, dpi = 600)
# ggsave("6.temp_sal_heatmap.pdf", width = 10, height = 10)
