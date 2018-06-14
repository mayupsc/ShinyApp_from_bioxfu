library(shiny)

shinyUI(pageWithSidebar(
  headerPanel('overlaP_v2'),
  sidebarPanel(
    numericInput(inputId = 'n',
              label = 'Number of genes in the species:',
              value = 20000),
    fileInput(inputId = 'files',
              label = 'Select gene list files:',
              multiple = TRUE),
    actionButton("apply", 'Apply')
  ),
  mainPanel(
    h3('Venn Diagram'),
    plotOutput('venn', height = "600px"),
    h3("Fisher's exact test"),
    tableOutput('pvalue')
  )
))
