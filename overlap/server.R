library(shiny)
library(VennDiagram)

shinyServer(function(input, output){
  passData <- reactive({
    fisher.test(matrix(c(input$n-(input$a+input$b-input$ab), input$a-input$ab, input$b-input$ab, input$ab), nrow=2), alternative = 'greater')
  })
  output$pvalue <- renderText({
    paste('p-value of the test:', format(passData()$p.value, digits=4, scientific=T))
  })
  output$odds <- renderText({
    paste('estimate of the odds ratio:', format(passData()$estimate, digits=4))
  })
  output$venn <- renderPlot({
    draw.pairwise.venn(input$a, input$b, input$ab, fill=c('#1B9E77','#D95F02'),cex=3)
  })
})