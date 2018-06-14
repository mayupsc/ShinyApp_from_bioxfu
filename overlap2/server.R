library(shiny)
library(magrittr)
library(GeneOverlap)
library(gplots)
library(plotrix)

shinyServer(function(input, output){
  passData <- eventReactive(input$apply, {
    geneListFiles <- input$files$datapath
    geneListNames <- input$files$name
    gene_lst <- list()
    for (i in 1:length(geneListFiles)) {
      gene_lst[[i]] <- read.table(geneListFiles[i])$V1 %>% unique()
    }
    names(gene_lst) <- geneListNames
    
    mat <- NULL
    for (i in 1:(length(gene_lst)-1)) {
      for (j in (i+1):length(gene_lst)) {
        go.obj <- newGeneOverlap(gene_lst[[i]], gene_lst[[j]], genome.size=input$n) %>% testGeneOverlap()
        num <- getIntersection(go.obj) %>% length()
        p <- getPval(go.obj) %>% format(digits=2)
        mat <- rbind(mat, c(names(gene_lst)[i], names(gene_lst)[j], num, p))
      }
    }
    colnames(mat) <- c('List1', 'List2', 'Number', 'P-value')
    list(mat=mat, gene_lst=gene_lst)
  })
  
  output$pvalue <- renderTable({
    passData()$mat
  })
  output$venn <- renderPlot({
    venn(passData()$gene_lst)
  })
})