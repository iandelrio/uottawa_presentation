

library(shiny)
library(CANSIM2R)
library(dplyr)
library(ggplot2)
library(plotly)
# install.packages("CANSIM2R")

# 36-10-0434-03
# Gross domestic product (GDP) at basic prices, by industry, annual average (x 1,000,000)
gdp_raw <- getCANSIM(36100434, raw=TRUE)
head(gdp_raw)

unique(gdp_raw$Seasonal.adjustment)

unique(gdp_raw$Prices)
unique(gdp_raw$GEO)

gdp <- gdp_raw %>% filter(Seasonal.adjustment %in% "Seasonally adjusted at annual rates")%>%
  select("time"="REF_DATE", "naics"="North.American.Industry.Classification.System..NAICS.", "value"="VALUE", "prices"="Prices") 

gdp$time1<-as.Date(paste((gdp$time), "-01", sep=""))

gdp$time1<-as.Date(gdp$time1)

head(gdp)
edit(gdp)

typeof(gdp$value)


# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("GDP Analysis"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      selectInput(inputId = "industry",
                  label = "Select an industry:",
                  choices = unique(gdp$naics), multiple= TRUE), #
      radioButtons(inputId = "prices",
                   label = "Select price measure:",
                   choices = unique(gdp$prices))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "plot2", height = "800px", width = "700px")
      
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot

  
  output$plot2 <- renderPlot({
    
    dat <- gdp %>%
      filter(naics %in% input$industry ) %>%
      filter(prices %in% input$prices)
    
    ggplot(dat)+
      # geom_point(aes(x= time1 , y= value, color=dat$naics))+
      geom_line(aes(x= time1 , y= value, color=dat$naics))+
      theme(axis.text.x = element_text(color="#993333",
                                       size=11, angle=90))+
      scale_x_date(date_labels = "%b %y", date_breaks = "1 year")
    
    
    
    # if multiple=FALSE
    # ggplot(dat, aes(x= time1 , y= value, group=1))+
    #   geom_point()+
    #   geom_line()+
    #   theme(axis.text.x = element_text(color="#993333",
    #                                    size=11, angle=90))      
    # 
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)