library(shiny)

shinyUI(pageWithSidebar(
  headerPanel('SRA Miner'),

  sidebarPanel(
    radioButtons(inputId = 'searchTerm',
                  label = 'Search Term',
                  choices = list('SRP ID' = 'srp', 'Key Words' = 'key')
    ),
    conditionalPanel(
      condition = "input.searchTerm == 'srp'",
      textInput(inputId = 'srp',
              label = 'SRP ID',
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
      tabPanel('Abstract',
               dataTableOutput('abstract'),
               downloadButton('downloadData', 'Download table')),
      tabPanel('Basic Information',
               dataTableOutput('base_info')),
      tabPanel('Library Information',
               dataTableOutput('lib_info'))
    ))
    
))

