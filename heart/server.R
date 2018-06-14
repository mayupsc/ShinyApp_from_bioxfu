library(shiny)

load('heart_model.RData')

draw_heart <- function(p){
  color_pal <- colorRampPalette(c('red','black'))(100000)
  color <- color_pal[p*100000]
  t <- seq(0, 60, len=100)
  plot(c(-8, 8), c(0, 20), type='n', axes=FALSE, xlab='', ylab='')
  x <- -.01 * (-t^2 + 40*t + 1200) * sin(pi*t/180)
  y <- .01 * (-t^2 + 40*t + 1200) * cos(pi*t/180)
  polygon(x, y, lwd=4, col=color, border = NA)
  polygon(-x, y, lwd=4, col=color, border = NA)
}

shinyServer(function(input, output) {
  passData <- reactive({
    test_data <- as.numeric(c(input$age, input$sex, input$chestpain, input$restbp, input$chol,
                              input$sugar, input$ecg, input$maxhr, input$angina, input$dep,
                              input$exercise, input$fluor, input$thal))
    test_data <- as.data.frame(matrix(test_data, nrow=1))
    names(test_data) <- names(heart)[1:length(test_data)]
    test_data$CHESTPAIN <- factor(test_data$CHESTPAIN)
    test_data$ECG <- factor(test_data$ECG)
    test_data$THAL <- factor(test_data$THAL)
    test_data$EXERCISE <- factor(test_data$EXERCISE)

    predictions <- predict(heart_model, newdata = test_data, type = "response")
    predictions
  })
  output$heartFigure <- renderPlot({
    draw_heart(passData())
  })
  output$riskLevel <- renderText({
    if (passData() > 0.5) {
      paste0('High (', round(passData()*100), '%)')
    }
    else {
      paste0('Low (', round(passData()*100), '%)')
    }
  })
  
})
