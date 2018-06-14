library(shiny)
library(GO.db)

goterms <- unlist(Term(GOTERM))
offsprings.bp <- as.list(GOBPOFFSPRING)
offsprings.cc <- as.list(GOCCOFFSPRING)
offsprings.mf <- as.list(GOMFOFFSPRING)

get_term <- function(goid){
  x <- c(goid, goterms[goid])
  names(x) <- NULL
  return(x)
}

get_offsprings <- function(goid, offsprings, go_class) {
  os_id <- offsprings[goid][[1]]
  os_term <- NULL
  if(length(os_id) > 0){
    os_id <- os_id[!is.na(os_id)]
    if(length(os_id) > 0){
      os_term <- t(apply(as.matrix(os_id),1,get_term))
      colnames(os_term) <- c('GO_ID','GO_TERM')
      os_term <- as.data.frame(os_term)
      os_term$GO_CLASS <- go_class
    } 
  }
  return(os_term)
}

shinyServer(function(input, output) {
  passData <- eventReactive(input$apply, {
    offsprings_tab <- NULL
    search_tab <- NULL
    n <- 0
    if(input$searchTerm == 'key' && input$key != '' && input$apply != 0) {
      mat <- as.matrix(goterms[grep(input$key, goterms)])
      n <- nrow(mat)
    }
    if(input$searchTerm == 'goid' && input$goid != '' && input$apply != 0) {
      mat <- as.matrix(goterms[input$goid])
      n <- nrow(mat)
    }
    if(n > 0) {
      withProgress(message = 'Searching ...', value=0, {
        for (i in 1:n) {
          #cat(paste(input$key, nrow(mat),i,'\n'))
          id <- names(mat[i,1])
          search_tab <- rbind(search_tab, c(id, Term(GOTERM[id]),Ontology(GOTERM[id])) )
          offsprings_tab <- rbind(offsprings_tab, get_offsprings(id, offsprings.bp, 'BP'))
          offsprings_tab <- rbind(offsprings_tab, get_offsprings(id, offsprings.cc, 'CC'))
          offsprings_tab <- rbind(offsprings_tab, get_offsprings(id, offsprings.mf, 'MF'))
          incProgress(1/n, detail = paste(round(i/n*100), '%'))
        }
      })
      offsprings_tab <- unique(offsprings_tab)
      colnames(search_tab) <- c('GO_ID','GO_TERM', 'GO_CLASS')
    }
    list(search=search_tab, offsprings=offsprings_tab)
  })
  output$search <- renderDataTable(passData()$search)
  output$offsprings <- renderDataTable(passData()$offsprings)
  
  output$downloadSearch <- downloadHandler(
    filename = function(){
      'GO_search.csv'
    },
    content = function(file){
      write.csv(passData()$search, file)
    }
  )
  output$downloadOffsprings <- downloadHandler(
    filename = function(){
      'GO_offsprings.csv'
    },
    content = function(file){
      write.csv(passData()$offsprings, file)
    }
  )
})
