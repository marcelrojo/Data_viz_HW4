library(ggplot2)
library(packcircles)
library(viridis)
library(plotly)
library(ggiraph)

results = read.csv("eurovision_results.csv")
country_lang = data.frame(country = results$Country, lang = results$Language)
country_lang$lang = gsub(" ", "", country_lang$lang)
freq_table = table(unlist(strsplit(country_lang$lang, ",")))
prop_table = prop.table(freq_table)
lang_freq = data.frame(freq_table)
lang_count = data.frame(prop_table)
lang_count$Count = lang_freq$Freq
colnames(lang_count) = c("Language", "Proportion", "Count")
# change the values in column proportion to  percentage
lang_count$Proportion = round(lang_count$Proportion * 100, 2)
lang_count
# drop rows where freq is 1 
lang_count = lang_count[lang_count$Proportion > 1.00,]

packing <- circleProgressiveLayout(lang_count$Proportion, sizetype='area')
data <- cbind(lang_count, packing)
data
data$text <- paste("Language: ",data$Language, "\n", "Proportion: ", data$Proportion, "\n", 
                   "Proportion of ", data$Language, 
                   " eurovision songs is ", data$Proportion, 
                   ", that is ", data$Count, " songs.")
dat.gg <- circleLayoutVertices(packing, npoints=50)


p <- ggplot() + 
  geom_polygon_interactive(data = dat.gg, aes(x, y, group = id, fill=id, tooltip = data$text[id]), alpha = 0.6) +
  geom_text(data = data, aes(x, y, size=Proportion, label = Language), color = "white") +
  scale_fill_distiller(palette = "RdPu", direction = -1 ) +
  scale_size_continuous(range = c(3,7)) +
  theme_void() + 
  theme(legend.position="none") +
  coord_equal()
p

widg <- girafe(ggobj = p, width_svg = 7, height_svg = 7)
widg


#ggsave("circles_lang.png", p, width = 10, height = 10)


