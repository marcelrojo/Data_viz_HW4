library(shiny)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(plotly)
library(ggiraph)
library(ggplot2)
library(packcircles)
library(tidyverse)
library(highcharter)
#devtools::install_github("ellisp/ggflags")
library(ggflags)
library(countrycode)



function(input, output, session) {
# ------------------------------------------------------------------------------------------------------------
  output$contests <- renderValueBox({
    events <- read.csv("datasets/events_info.csv")
    valueBox(
      color = "fuchsia",
      value = paste(nrow(events), 'CONTESTS'),
      subtitle = "ESC has been held annualy for almost 70 years!"
      )
  })  

# ------------------------------------------------------------------------------------------------------------
  output$map <- renderGirafe({
    results = read.csv("datasets/eurovision_results.csv")
    events = read.csv("datasets/events_info.csv")
    world <- ne_countries(scale = "medium", returnclass = "sf")
    hosting <- events %>%
      group_by(Country) %>%
      summarise(n = n()) %>%
      arrange(desc(n))
    
    world['events'] <- hosting$n[match(world$name, hosting$Country)]
    data.frame(world$name, world$events)
    
    world$events[is.na(world$events)] <- 0
    world$events <- as.factor(world$events)
    
    Europe <- world[which(world$continent == "Europe"),]
    custom_colors = rev(
      c(
        "#6B10C5",
        "#d9009b",
        "#ff1e6e",
        "#FF7814",
        "#ffa65b",
        "#ffd254",
        "#f9f871",
        "lightgrey"
      )
    )
    p <- ggplot(world) +
      geom_sf_interactive(aes(
        fill = events,
        tooltip = paste('Country: ', name, '\n',
                        'Number of events hosted: ', events)
      ),
      color = 'white',
      size = 0.6) +
      theme_void() +
      scale_fill_manual(values = custom_colors) +
      coord_sf(xlim = c(-25, 50),
               ylim = c(35, 70),
               expand = FALSE) +
      labs(fill = "Number of events") +
      theme(
        legend.position = "none",
        panel.background = element_rect(fill = "#010039"),
        plot.background = element_rect(fill = "#010039"),
        plot.title = element_text(
          color = "white",
          size = 20,
          hjust = 0.5
        ),
        plot.margin = unit(c(0, 0, 0, 0), 'cm')
      )
    girafe(ggobj = p,
           width_svg = 2*8.9,
           height_svg = 2*6.8436,
           options = list(opts_sizing(rescale = T)))
  })

# ------------------------------------------------------------------------------------------------------------
  # the language visualization
  output$circles <- renderGirafe({
    results = read.csv("datasets/eurovision_results.csv")
    # prepare datafreame
    country_lang = data.frame(country = results$Country, lang = results$Language)
    country_lang$lang = gsub(" ", "", country_lang$lang)
    freq_table = table(unlist(strsplit(country_lang$lang, ",")))
    prop_table = prop.table(freq_table)
    lang_freq = data.frame(freq_table)
    lang_count = data.frame(prop_table)
    lang_count$Count = lang_freq$Freq
    colnames(lang_count) = c("Language", "Proportion", "Count")
    lang_count$Proportion = round(lang_count$Proportion * 100, 2)
    lang_count = lang_count[lang_count$Proportion > 3.0, ]
    
    # prepare the circles
    packing <-
      circleProgressiveLayout(lang_count$Proportion, sizetype = 'area')
    data <- cbind(lang_count, packing)
    data$text <-
      paste(
        "Language: ",
        data$Language,
        "\n",
        "Proportion: ",
        data$Proportion,
        "\n",
        "Proportion of ",
        data$Language,
        " eurovision songs is ",
        data$Proportion,
        ", that is ",
        data$Count,
        " songs."
      )
    dat.gg <- circleLayoutVertices(packing, npoints = 50)
    
    custom_colors <- c(
      "#6B10C5",
      "#aa20ab",
      "#d9009b",
      "#ff1e6e",
      "#ff5f49",
      "#FF7814",
      "#ff9e35",
      "#ffa65b",
      "#ffd254",
      "#f9f871"
    )
    dat.gg$id <- as.factor(dat.gg$id)
    p <- ggplot() +
      geom_polygon_interactive(data = dat.gg, aes(
        x,
        y,
        group = id,
        fill = id,
        tooltip = data$text[id]
      )) +
      geom_text(
        data = data,
        aes(x, y, size = Proportion, label = Language),
        color = "white"
        ) +
      scale_fill_manual(values = custom_colors) +
      scale_size_continuous(range = c(3, 7)) +
      theme_void() +
      coord_equal() +
      theme(
        legend.position = "none",
        panel.background = element_rect(fill = "#010039"),
        plot.background = element_rect(fill = "#010039"),
        plot.margin = unit(c(0, 0, 0, 0), 'cm')
      )
    
    widg <- girafe(ggobj = p,
                   width_svg = 0.7*5.81, height_svg = 0.7*4,
                   options = list(opts_sizing(rescale = F)))
  })
  
# ------------------------------------------------------------------------------------------------------------
  
  output$winners <- renderHighchart({
    data <- read.csv("datasets/eurovision_results.csv")
    data_finals <- data %>%
      filter(Grand.Final.Place == 1) %>%
      group_by(Country) %>%
      summarise(Count = n(),
                Wins = list(paste(
                  Year, paste0('"', Song, '" by ', Artist), sep = " - "
                ))) %>%
      arrange(desc(Count))
    
    # Combine the wins into a single string
    data_finals <- data_finals %>%
      mutate(Wins = sapply(Wins, paste, collapse = "<br>"))
    
    custom_colors <- c("#6B10C5",
                       "#aa20ab",
                       "#d9009b",
                       "#ff1e6e",
                       "#ff5f49",
                       "#FF7814",
                       "#ff9e35")
    
    # Create the treemap chart with customized tooltip
    hc <- data_finals %>%
      hchart(
        "treemap",
        hcaes(
          x = Country,
          value = Count,
          color = Count
        ),
        tooltip = list(
          pointFormat = '<b>{point.name}</b><br>
                     Count: {point.value}<br>
                     Wins:<br>{point.Wins}',
          style = list(width = '200px')
        )
      ) %>%
      hc_colorAxis(stops = color_stops(colors = rev(custom_colors))) %>%
      hc_legend(enabled = FALSE)
    
    # Customize the tooltip
    hc <- hc %>%
      hc_tooltip(
        useHTML = TRUE,
        headerFormat = '',
        pointFormat = '<b>{point.name}</b><br>
                   Count: {point.value}<br>
                   Wins:<br>{point.Wins}'
      )
    
    custom_theme <- hc_theme(
      chart = list(backgroundColor = "#010039"),
      title = list(
        style = list(
          color = "white",
          fontFamily = "Cantarell",
          fontSize = "20px"
        )
      ),
      tooltip = list(
        backgroundColor = "#000000",
        style = list(
          color = "#ffffff",
          fontFamily = "Cantarell",
          fontSize = "12px"
        )
      )
    )
    # Apply the custom theme
    hc <- hc %>%
      hc_add_theme(custom_theme)
  })
  
# ------------------------------------------------------------------------------------------------------------
  output$points <- renderGirafe({
    data=read.csv("datasets/eurovision_results.csv")
    years = strsplit(input$select, "-")
    year1 = as.numeric(years[[1]][1])
    year2 = as.numeric(years[[1]][2])
    most_points <- data %>%
      filter(
        Year >= year1 & Year <= year2,
        !is.na(as.numeric(Grand.Final.Points))
      )%>%
      mutate(Grand.Final.Points = as.integer(Grand.Final.Points)) %>%
      arrange(desc(Grand.Final.Points)) %>%
      head(10)
    most_points$Code<- tolower(countrycode(most_points$Country, "country.name", "iso2c"))
    
    custom_colors <- c(
      "#6B10C5",
      "#aa20ab",  
      "#d9009b",
      "#ff1e6e",
      "#ff5f49",  
      "#FF7814",
      "#ff9e35",  
      "#ffa65b",
      "#ffd254",
      "#f9f871"
    )
    
    g <- ggplot(most_points, aes(x = reorder(Song, Grand.Final.Points), y = Grand.Final.Points, fill = reorder(Song, - Grand.Final.Points))) +
      geom_col_interactive(aes(tooltip = paste0(Country, "<br> \"", Song,"\" by ", Artist, "<br>Year: ", Year, "<br>Points: ", Grand.Final.Points))) +
      geom_text(aes(x = reorder(Song, Grand.Final.Points), y = max(Grand.Final.Points)/38, label = paste0("\"",Song,"\"")), 
                color = "white", size = 5, fontface = "bold", vjust = 0.5, hjust = 0) +
      scale_fill_manual(values = custom_colors) +
      geom_point(size=12, color="black", y=0)+
      geom_flag(aes(y=0, country=Code), size=10)+
      coord_flip() +
      theme(
        legend.position = "none",
        panel.background = element_rect(fill = "#010039"),
        plot.background = element_rect(fill = "#010039"),
        axis.text.y = element_blank(),  
        axis.title.y = element_blank(), 
        plot.title = element_text(color = "white", size = 20, hjust = 0.5),
        axis.text = element_text(color = "white", size = 14, face = "bold"),
        panel.grid.major.y = element_blank(), 
        panel.grid.minor.y = element_blank(),
        panel.grid.minor = element_blank() 
      )
    
    widg <- girafe(ggobj = g, width_svg = 10, height_svg = 10)
  })
  


#------------------------------------------------------------------------------------------------
  output$placements_plot <- renderGirafe({
    data <- read.csv("datasets/eurovision_results.csv")
    
    # Convert necessary columns
    data_placements <- data[!is.na(data$Grand.Final.Place), ]
    data_placements$Year <- as.numeric(data_placements$Year)
    data_placements$Grand.Final.Place <- as.numeric(data_placements$Grand.Final.Place)
    data_placements$Country <- factor(data_placements$Country)
    data_placements$Code <- tolower(countrycode(data_placements$Country, "country.name", "iso2c"))
    
    custom_colors <- c(
      "#fff800",
      "#ff0188",
      "#0043fe",
      "#aed258",
      "#ff7815"
    )
    
    selected_data <- subset(data_placements, Country %in% input$countries & Year >= input$years[1] & Year <= input$years[2])
    
    # Plot selected data
    p <- ggplot(selected_data, aes(x = Year, y = Grand.Final.Place, group = Country, color = Country, fill=Country)) +
      geom_line(size = 1.5) +
      geom_point_interactive(aes(tooltip=paste0("Country: ", Country, "<br>",
                                                "Year: ", Year, "<br>",
                                                "Place: ", Grand.Final.Place, "<br>",
                                                "\"", Song, "\" by ", Artist)), size = 9.5, alpha=1) + # Plot all places as small circles
      geom_flag(aes(country = Code, color = Country), size = 8) +      
      scale_shape_manual(name = "", values = 16) + # Change shape to a circle
      scale_fill_manual(values = custom_colors) +
      scale_color_manual(values = custom_colors) +
      scale_y_reverse(name = "Place", breaks = seq(1, max(selected_data$Grand.Final.Place, na.rm = TRUE), 1)) +
      labs(x = "Year",
           y = "Place") +
      theme_minimal() +
      theme(legend.position = "none",
            panel.background = element_rect(fill = "#010039"),
            plot.background = element_rect(fill = "#010039"),
            plot.title = element_text(color = "white", size = 20, hjust = 0.5),
            axis.text = element_text(color = "white", size = 14, face = "bold"),
            panel.grid.minor.y = element_blank(),
            panel.grid.minor.x = element_blank())
    
    widg <- girafe(ggobj = p, width_svg = 10, height_svg = 10)
    widg
    
  })
}
