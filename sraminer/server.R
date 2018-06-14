library(shiny)
library(SRAdb)

sqlfile <- 'SRAmetadb.sqlite'

sra_con <- dbConnect(SQLite(), sqlfile)

shinyServer(function(input, output) {
  passData <- eventReactive(input$apply, {
    withProgress(message = 'Search in progress',
                 detail = 'This may take a while...', value = 0, {
      if(input$searchTerm == 'srp') {
        tab <- dbGetQuery(sra_con, paste0("select run_accession,study_accession,updated_date,spots,bases,experiment_title,library_strategy,library_source,library_selection,library_layout,library_construction_protocol,instrument_model,sample_attribute,study_abstract from sra where study_accession='",input$srp,"'"))
      }
      if(input$searchTerm == 'key') {
        tab <- getSRA(search_term=input$key, out_types=c('sra'), sra_con)
      }
      colnames(tab) <- sub('_accession','',colnames(tab))
      tab
    })
  })
  output$abstract <- renderDataTable(unique(passData()[,c('study','study_abstract')]))
  output$lib_info <- renderDataTable(passData()[,c('run','study','library_strategy','library_source','library_selection','library_layout','library_construction_protocol')])
  output$base_info <- renderDataTable(passData()[,c('run','study','updated_date','spots','bases','experiment_title','instrument_model','sample_attribute')])
  output$downloadData <- downloadHandler(
    filename = function(){
      'sraData.csv'
    },
    content = function(file){
      write.table(passData(), file, quote=F, sep='\t', row.names=F)
    }
  )
})
