library(shiny)

shinyUI(pageWithSidebar(
  headerPanel('GO Miner'),

  sidebarPanel(
    radioButtons(inputId = 'searchTerm',
                  label = 'Search Term',
                  choices = list('GO ID' = 'goid', 'Key Words' = 'key')
    ),
    conditionalPanel(
      condition = "input.searchTerm == 'goid'",
      textInput(inputId = 'goid',
              label = 'GO ID',
              value = ''
      )
    ),
    conditionalPanel(
      condition = "input.searchTerm == 'key'",
      textInput(inputId = 'key',
                label = 'Key words',
                value = ''
      )
    ),
    actionButton("apply", 'Apply')
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel('Search',
               dataTableOutput('search'),
               downloadButton('downloadSearch', 'Download table')),
      tabPanel('Offsprings',
               dataTableOutput('offsprings'),
               downloadButton('downloadOffsprings', 'Download table'))
    ))
))

