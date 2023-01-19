#- ===================================
#- APP: lnmapp
#- NAME: app.R
#- DESCRIPTION: top level server and ui functions
#- DATE: 2023-01-19
#- AUTHOR: lg
#- ==================================

#setwd('/srv/shiny-server/apps/tech/apiErrors')
# setwd('/usr/local/workspace/gould/repositories/github/shiny-api-errors')

source('R/Global.R')
source('R/server.R')
source('R/ui.R')


# Run the application 
shinyApp(ui = ui, server = server)
