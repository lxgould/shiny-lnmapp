
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(lubridate)
headerPanel_2 <- function(title, h, windowTitle=title) {    
  tagList(
    tags$head(tags$title(windowTitle)),
    h(title)
  )
}


shinyUI(fluidPage(
  #theme = "bootstrap.css",
  headerPanel_2(
    HTML(
      '<div id="stats_header">
      Land Nutrient Management App
      <a href="http://www.SPGenetics.com">
      <img id="stats_logo" align="right" style="margin-left: 15px;" alt="SPG Logo" src="SPG.jpg",height = 70, width = 150 />
      </a>
      
      </div>'
    ), h2, "Land, Nutrient, Management App "
    ),
  #hr() creates line
  hr(),
  

  sidebarLayout(
    sidebarPanel(width=2,
      selectInput("region", label = h3("Select box"), 
                  choices = list("Studs" = "Studs", "NC Farms" = "NC Farms", 
                                 "TX Farms" = "TX Farms"), 
                  selected = 1),
      
      uiOutput("ui1"),
      
      checkboxGroupInput("lnm", label = h3("Variable:"),
                         choices = list("Primary" = 'primary',
                                        "Secondary" = 'secondary',
                                        "Rainfall" = 'rain',
                                        "Usage" = 'usage',
                                        "Pumped" = 'pumped',
                                        "Primary Diff" = 'diffPrimary',
                                        "Secondary Diff" = 'diffSecondary'),
                         selected = 'primary'),
      hr(),
      h4("Updated"),
      textOutput("update")
  
    
    ),

    # Show a plot of the generated distribution
    mainPanel(width = 10,tabsetPanel(tabPanel("Main",
              ###removes visible error
              tags$style(type="text/css",
                         ".shiny-output-error { visibility: hidden; }",
                         ".shiny-output-error:before { visibility: hidden; }"
              ),
              
            plotOutput('plot',height = 600),
            uiOutput("dateSelector"),
            
            radioButtons("pType", label = h3("Plot"),
                         choices = list("Line" = 1, "Bar" = 2), 
                         selected = 1)
            
    ),
    tabPanel("File Upload",
             fileInput('file1','Choose file to upload')))
  )
)))
