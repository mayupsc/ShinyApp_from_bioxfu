library(shiny)

shinyUI(pageWithSidebar(
  headerPanel('overlaP'),
  sidebarPanel(
    numericInput(inputId = 'n',
              label = 'Number of genes in the species:',
              value = 200),
    numericInput(inputId = 'a',
              label = 'Number of genes in list A:',
              value = 70),
    numericInput(inputId = 'b',
              label = 'Number of genes in list B:',
              value = 30),
    numericInput(inputId = 'ab',
              label = 'Number of overlaped genes:',
              value = 10)
  ),
  mainPanel(
    h3('Venn Diagram'),
    plotOutput('venn'),
    h3("Fisher's exact test"),
    textOutput('pvalue'),
    textOutput('odds')
  )
))
