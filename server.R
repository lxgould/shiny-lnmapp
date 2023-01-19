
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#setwd('/srv/shiny-server/apps/prod/lnmApp')
library(shiny)
source('/srv/shiny-server/functions/ipak.R')
library(pacman)
packages <- c('dplyr','scales','tidyr','ggplot2','readr','lubridate','sendmailR')
p_load(dplyr,scales,tidyr,ggplot2,readr,lubridate,sendmailR)


sendmail_options(smtpServer="smtp.murphybrownllc.com")

from <- "LNMapp@smithfield.com"
to <- c("kgray@smithfield.com","mparker@smithfield.com")
subject <- "LNM app has been updated or they broke it"
msg <- "LNM app has been updated please check to make sure it is not broken

http://10.207.9.24:3838/7rE4goiQgwjO4jkDmY5YBqFxR86ynYJu/"

#- This section establishes the number of years we want to display
#- and their colors in the chart.  
colorList <- c( "darkblue", "darkred","#86CC5D", "#C2524C", "#94B9B9", "#504145", "#AC9346", '#A442F4')
fourYears = rev(seq(from = year(today()), by = -1, length = 4))
yearCol = colorList[1:4]
names(yearCol) = fourYears

shinyServer(function(input, output) {
  stud1 <- read_csv('studAll.csv',col_types=c('ccddddddd'))
  tx1 <- read_csv('txAll1.csv',col_types=c('ccdddddddd'),na = '')
  nc1 <- read_csv('nc.csv',col_types=c('ccddddddd'),na = '')
  
  stud <- stud1 %>% 
    filter(!is.na(primary)) %>%
    mutate(diffPrimary = stopPrimary - primary, diffSecondary = stopSecondary - secondary) %>% 
    gather(lnm,value,c(primary,secondary,rain,usage,pumped,diffPrimary,diffSecondary)) %>% 
    mutate(date = mdy(date),year=(year(date)),datex =mdy_hms(paste(month(date),day(date),"2000 12:00:00",sep="/")))
  
  tx <- tx1 %>% 
    filter(!is.na(primary)) %>%
    mutate(diffPrimary = stopPrimary - primary, diffSecondary = stopSecondary - secondary) %>% 
    gather(lnm,value,c(primary,secondary,rain,usage,pumped,diffPrimary,diffSecondary)) %>% 
    mutate(date = mdy(date),year=(year(date)),datex =mdy_hms(paste(month(date),day(date),"2000 12:00:00",sep="/")))
  
  nc <- nc1 %>% 
    filter(!is.na(primary)) %>%
    mutate(diffPrimary = stopPrimary - primary, diffSecondary = stopSecondary - secondary) %>% 
    gather(lnm,value,c(primary,secondary,rain,usage,pumped,diffPrimary,diffSecondary)) %>% 
    mutate(date = mdy(date),year=(year(date)),datex =mdy_hms(paste(month(date),day(date),"2000 12:00:00",sep="/")))
  
  observe({
    if(is.null(input$file1)) return()
    file.copy(input$file1$datapath,input$file1$name,overwrite=TRUE)
    sendmail(from,to,subject,msg)
  })
  output$ui1 <- renderUI({
    
    if (is.null(input$region))
      return()
    # Depending on input$datasource, we'll generate a different
    # UI component and send it to the client.
    switch(input$region,
           "Studs" =  radioButtons("site", label = h3("Site:"),
                                   choices = list("7081" = '7081',
                                                  "7082" = '7082',
                                                  "7083" = '7083',
                                                  "7084" = '7084',
                                                  "7092" = '7092',
                                                  "7093" = '7093',
                                                  '7094' = '7094',
                                                  '7365' = '7365',
                                                  '7366' = '7366'
                                   ),
                                   selected = '7081'),
           "NC Farms" =  radioButtons("site", label = h3("Site:"),
                                      choices = list("60" = '60',
                                                     "61" = '61',
                                                     "62" = '62',
                                                     "63" = '63',
                                                     "68" = '68',
                                                     "69" = '69',
                                                     "Transfer" = 'Transfer'),
                                      
                                      selected = '60'),
           
           "TX Farms" =  radioButtons("site", label = h3("Site:"),
                                      choices = list("Nursery 1" = 'Nursery 1',
                                                     "Nursery 2" = "Nursery 2",
                                                     "Damline 1" = 'Damline 1',
                                                     "Damline 2" = 'Damline 2',
                                                     "Sireline" = 'Sireline',
                                                     "Iso" = 'Iso',
                                                     "BGF" = 'BGF',
                                                     "Truck Wash" = 'Truck Wash'
                                                     
                                      ),
                                      selected = 'Damline 1')
    )
    
  })
  
  dataReactive <- reactive({
    if(input$region=='Studs'){
      dat <- stud %>% 
        filter(site %in% input$site,
               lnm %in% input$lnm,
               year >= (input$dateSelect[1]),
               year <= (input$dateSelect[2])) 
    }
    if(input$region == 'TX Farms'){
      dat <- tx %>% 
        filter(site %in% input$site,
               lnm %in% input$lnm,
               year >= (input$dateSelect[1]),
               year <= (input$dateSelect[2])) 
    }
    if(input$region == 'NC Farms'){
      dat <- nc %>% 
        filter(site %in% input$site,
               lnm %in% input$lnm,
               year >=(input$dateSelect[1]),
               year <=(input$dateSelect[2])) 
    }
    
    
    
    
    dat1 <- dat %>%
      mutate(DateMax=as.character(max(date)))
    dat1
  })
  output$update <- renderText({
    maxDate <-  unique(dataReactive()$DateMax)
    maxDate
  })
  
  output$plot <- renderPlot({
    if(input$pType==1){
      p <- ggplot(dataReactive(),aes(x = datex,y = value,color=as.factor(year)))+
        geom_line(size = 1.5)+
        #geom_point(size=2.5)+
        facet_grid(lnm~.,scales = "free_y")+
        theme_bw(base_size =25)+
        theme(panel.grid.major = element_line(colour = "gray",size=1),
              panel.grid.minor = element_line(colour = "gray",linetype = 2))+
        xlab("Date")+
        ylab("")+
        scale_x_datetime(date_labels = "%b",date_breaks=("1 month"),date_minor_breaks = "1 week")+
        #scale_color_discrete(guide = guide_legend(title="Year"))+
        scale_colour_manual(name = "Year",values = yearCol)
      
      if('pumped' %in% input$lnm){
        p <- p +
          geom_point(size=2.5)
      }
      
      p
    }else{
      p <- ggplot(dataReactive(),aes(x = datex,y = value,fill=as.factor(year)))+
        geom_bar(stat='identity')+
        #geom_point(size=2.5)+
        facet_grid(lnm~.,scales = "free_y")+
        theme_bw(base_size =25)+
        theme(panel.grid.major = element_line(colour = "gray",size=1),
              panel.grid.minor = element_line(colour = "gray",linetype = 2))+
        xlab("Date")+
        ylab("")+
        scale_x_datetime(date_labels = "%b",date_breaks=("1 month"),date_minor_breaks = "1 week")+
        #scale_color_discrete(guide = guide_legend(title="Year"))+
        scale_fill_manual(name = "Year",values = yearCol)
      
      #     if('pumped' %in% input$lnm){
      #       p <- p +
      #         geom_point(size=2.5)
      #     }
      
      p
    }
    
  })
  
  
  
  
  
})
