library(shiny)
version <- 0.1

shinyUI(pageWithSidebar(
  headerPanel(paste0('NGS Miner (version ',version,')')),

  sidebarPanel(
    selectInput(inputId = 'genome',
                label = 'Choose the genome',
                choices = list('GRCh38(hg38)' = 'GRCh38',
                               'GRCm38(mm10)' = 'GRCm38',
                               'Arabidopsis' = 'tair10')
    ),
    radioButtons(inputId = 'ngstype',
                 label = 'Choose NGS Type',
                 choices = list('ChIP-Seq' = 'ChIP-Seq',
                                'RNA-Seq' = 'RNA-Seq')
    ),
    conditionalPanel(
      condition = "input.ngstype == 'ChIP-Seq'",
      checkboxGroupInput(inputId = 'ngstool',
                         label = 'Choose NGS Tool',
                         choices = list('FastQC' = 'fastqc',
                                        'bowtie2(PE)' = 'bowtie2pe',
                                        'BamQC' = 'bamqc',
                                        'Generate ChIP-Seq Tracks' = 'track_chip',
                                        'MACS1.4' = 'macs')
      )
    ),
    conditionalPanel(
      condition = "input.ngstype == 'RNA-Seq'",
      checkboxGroupInput(inputId = 'ngstool2',
                         label = 'Choose NGS Tool',
                         choices = list('FastQC' = 'fastqc',
                                        'TopHat(SE)' = 'tophat2se',
                                        'TopHat(PE)' = 'tophat2pe',
                                        'Reads count/RPKM(by GFOLD)' = 'gfold_count',
                                        'DEGs(by GFOLD)' = 'gfold_diff',
                                        'Alternative Splicing' = 'AS',
                                        'Generate RNA-Seq Tracks' = 'track_rna')
      )
    ),
    textInput(inputId = 'path',
              label = 'Installation path of GmaticDocker',
              value = '~/GmaticDocker/'
    ),
    textInput(inputId = 'project_dir',
              label = 'Project directory',
              value = ''
    ),
    numericInput(inputId = 'thread',
                label = 'Number of thread',
                value = 20
    ),
    conditionalPanel(
      condition = "input.ngstype == 'ChIP-Seq'",
      numericInput(inputId = 'insert',
                   label = 'The insertion size',
                   value = 0
      )
    ),
    conditionalPanel(
      condition = "input.ngstool == 'macs'",
      textInput(inputId = 'inputSample',
                label = 'The name of input sample',
                value = 'Input'
      )
    ),
    conditionalPanel(
      condition = "input.ngstool == 'macs'",
      textInput(inputId = 'chipSample',
                label = 'The name of ChIP sample',
                value = ''
      )
    ),
    numericInput(inputId = 'repnum',
                 label = 'Number of replicate',
                 value = 3
    ),
    actionButton("apply", 'Apply')
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel('Pipeline',
               dataTableOutput('pipeline'),
               downloadButton('downloadPipeline', 'Download pipeline')
               )
    )
  )
))

