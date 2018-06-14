library(shiny)
version <- 0.1

shinyServer(function(input, output) {
  passData <- eventReactive(input$apply, {
    tools <- c(input$ngstool, input$ngstool2)
    print(tools)
    type <- input$ngstype
    dir <- input$project_dir
    cpu <- input$thread
    insert <- input$insert
    chipSam <- input$chipSample
    inputSam <- input$inputSample
    bin <- paste0(input$path, 'bin')
    if (input$genome == 'GRCh38') {
      index <- paste0(input$path, 'human/v23/fasta/GRCh38')
      trans_index <- paste0(input$path, 'human/v23/fasta/GRCh38_trans')
      gtf <- paste0(input$path, 'human/v23/GTF/gencode.v23.annotation.gtf')
      asta <- paste0(input$path, 'human/v23/ASTA/gencode.v23_astalavista.bed')
      asta_RI <- paste0(input$path, 'human/v23/ASTA/gencode.v23_astalavista.RI.bed')
      anno <- paste0(input$path, 'human/v23/metadata/gencode.v23.annotation.tsv')
      igv <- '~/igv/genomes/hg38.genome'
      genome_size <- paste0(input$path, 'human/v23/fasta/GRCh38.genomeSize')
    } 
    if (input$genome == 'GRCm38') {
      index <- paste0(input$path, 'mouse/vM6/fasta/GRCm38')
      trans_index <- paste0(input$path, 'mouse/vM6/fasta/GRCm38_trans')
      gtf <- paste0(input$path, 'mouse/vM6/GTF/gencode.vM6.annotation.gtf')
      asta <- paste0(input$path, 'mouse/vM6/ASTA/gencode.vM6_astalavista.bed')
      asta_RI <- paste0(input$path, 'mouse/vM6/ASTA/gencode.vM6_astalavista.RI.bed')
      anno <- paste0(input$path, 'mouse/vM6/metadata/gencode.vM6.annotation.tsv')
      igv <- '~/igv/genomes/mm10.genome'
      genome_size <- paste0(input$path, 'mouse/vM6/fasta/GRCm38.genomeSize')
    } 
    if (input$genome == 'tair10') {
      index <- paste0(input$path, 'plant/fasta/tair10')
      trans_index <- paste0(input$path, 'plant/fasta/tair10_trans')
    } 
    
    pipeline <- c('Add PATH', paste0('export PATH=$PATH:', bin))
    if (type == 'ChIP-Seq') {
      pipeline <- rbind(pipeline, c('Init', paste0('mkdir -p ', dir,'/{fastqc,bam}/', type, ' && mkdir -p ', dir, '/{stat,tracks/ChIP-Seq,peaks}')))
    }
    if (type == 'RNA-Seq') {
      pipeline <- rbind(pipeline, c('Init', paste0('mkdir -p ', dir,'/fastqc/', type, ' && mkdir -p ', dir, '/{stat,tracks/RNA-Seq,tophat,gfold,AS,DAS}')))
    }
    fastqc_cmd <- paste0('fastqc -t ', cpu, ' -o ', dir, '/fastqc/', type, ' ', dir, '/fastq/', type, '/*.fastq.gz')
    fastqc_stat <- paste0('find ',dir,'/fastqc/*/*.html|xargs -I {} fastqc_html_reads_stat.py {} > ' , dir, '/stat/reads_stat_total.tsv')
    bowtie2pe_cmd <- paste0('find ',dir,'/fastq/',type,'/*.gz -printf "%f\\n"|sed -n ',"'s/_R[12].fastq.gz//p'|sort|uniq|xargs --verbose -I {} bowtie2_PE.sh ",cpu,' ',insert,' ',index,' ',dir,'/fastq/',type,'/{} ',dir,'/bam/',type,'/{}')
    bamqc_cmd <- paste0('find ',dir,'/bam/',type,'/*.bam|sed ',"'s/.bam//'|xargs --verbose -I {} qualimap bamqc --java-mem-size=10G -nt ",cpu,' -bam {}.bam -outdir {}.bamqc')
    bamqc_stat <- paste0('find ',dir,'/bam/*/*.bamqc|genome_results.txt|xargs -I {} bamqc_reads_stat.py {} > ' , dir, '/stat/reads_stat_mappped.tsv')
    track_chip_cmd <- paste0('find ',dir,'/bam/ChIP-Seq/*.bam -printf "%f\\n"|sed \'s/.bam//\'|parallel --gnu "bam_to_bedgraph_bigwig.sh ',dir,'/bam/ChIP-Seq/{}.bam ',dir,'/tracks/ChIP-Seq/{} $IGV $GENOME_SIZE"')
    track_rna_cmd <- paste0('find ',dir,'/tophat -maxdepth 1 -printf "%f\\n"|grep -v tophat|parallel --gnu "bam_to_bedgraph_bigwig.sh ',dir,'/tophat/{}/accepted_hits.bam ',dir,'/tracks/RNA-Seq/{} ',igv,' ',genome_size,'"')
    macs_cmds <- c()
    tophat2pe_cmd <- paste0('find ',dir,'/fastq/',type,'/*.gz -printf "%f\\n"|sed -n ',"'s/_R[12].fastq.gz//p'|sort|uniq|xargs --verbose -I {} tophat -o ",dir,'/tophat/{} -p ',cpu,' -g 1 --no-discordant --transcriptome-index ',trans_index,' ',index,' ',dir,'/fastq/',type,'/{}_R1.fastq.gz ',dir,'/fastq/',type,'/{}_R2.fastq.gz')
    tophat2se_cmd <- paste0('find ',dir,'/fastq/',type,'/*.gz -printf "%f\\n"|sed -n ',"'s/.fastq.gz//p'|sort|uniq|xargs --verbose -I {} tophat -o ",dir,'/tophat/{} -p ',cpu,' -g 1 --transcriptome-index ',trans_index,' ',index,' ',dir,'/fastq/',type,'/{}.fastq.gz ')
    gfold_count_cmd <- paste0('find ',dir,'/tophat -maxdepth 1 -printf "%f\\n"|grep -v tophat|parallel --gnu "gfold_count.sh ', gtf,' ',dir,'/tophat/{}/accepted_hits.bam ',dir,'/gfold/{}.read_cnt"')
    gfold_combine_cmd <- paste0('gfold_combine.sh ',dir,'/gfold/ ',anno)
    tophat_juncs_cmd <- paste0('find ',dir,'/tophat -maxdepth 1 -printf "%f\\n"|grep -v tophat|parallel --gnu "bed_to_juncs < ',dir,'/tophat/{}/junctions.bed > ',dir,'/tophat/{}/junctions.juncs"')
    AS_cmd <- paste0('find ',dir,'/tophat -maxdepth 1 -printf "%f\\n"|grep -v tophat|parallel --gnu "ASFinder.py ',dir,'/tophat/{} ',asta,' ',asta_RI,' ',dir,'/AS/{}"')
    AS_fisher_cmd <- paste0('AS_fisher_test.R ',dir,'/AS/[sample1] ',dir,'/AS/[sample2] [sample1] [sample2] ',dir,'/DAS/[sample1]_vs_[sample2]')
    gfold_diff_cmd <- paste0('gfold_diff.sh ',dir,'/gfold/ [sample1] [sample2]')
    gfold_diff_filt_cmd <- paste0('gfold_diff_filt.R ',dir,'/gfold/diff/[sample1]_vs_[sample2].diff 1.5 ',anno)
    
    for (i in 1:input$repnum) {
      macs_cmds <- c(macs_cmds, paste0('macs14 -t ',dir,'/bam/ChIP-Seq/',chipSam,'_',i,'.bam -c ',dir,'/bam/ChIP-Seq/',inputSam,'_',i,'.bam -g $GENOME_SIZE -p $PVALUE -n ',dir,'/peaks/',chipSam))
    }
    print(macs_cmds)
    if (input$project_dir != '') {
      if (length(grep('fastqc', tools)) > 0) {
        pipeline <- rbind(pipeline, c('FastQC', fastqc_cmd))
        pipeline <- rbind(pipeline, c('FastQC(stat)', fastqc_stat))
      }
      if (length(grep('bowtie2pe', tools)) > 0) {
        pipeline <- rbind(pipeline, c('bowtie2(PE)', bowtie2pe_cmd))
      }
      if (length(grep('bamqc', tools)) > 0) {
        pipeline <- rbind(pipeline, c('BamQC', bamqc_cmd))
        pipeline <- rbind(pipeline, c('BamQC(stat)', bamqc_stat))
      }
      if (length(grep('tophat2se', tools)) > 0) {
        pipeline <- rbind(pipeline, c('tophat(SE)', tophat2se_cmd))
      }
      if (length(grep('tophat2pe', tools)) > 0) {
        pipeline <- rbind(pipeline, c('tophat(PE)', tophat2pe_cmd))
      }
      if (length(grep('gfold_count', tools)) > 0) {
        pipeline <- rbind(pipeline, c('GFOLD(count)', gfold_count_cmd))
        pipeline <- rbind(pipeline, c('GFOLD(combine)', gfold_combine_cmd))
      }
      if (length(grep('gfold_diff', tools)) > 0) {
        pipeline <- rbind(pipeline, c('GFOLD(diff)', gfold_diff_cmd))
        pipeline <- rbind(pipeline, c('GFOLD(diff filter)', gfold_diff_filt_cmd))
      }
      if (length(grep('AS', tools)) > 0) {
        pipeline <- rbind(pipeline, c('convert TopHat junction', tophat_juncs_cmd))
        pipeline <- rbind(pipeline, c('AS_Finder', AS_cmd))
        pipeline <- rbind(pipeline, c('AS_Fisher_test', AS_fisher_cmd))
      }
      if (length(grep('track_chip', tools)) > 0) {
        pipeline <- rbind(pipeline, c('Generate ChIP-Seq Tracks', track_chip_cmd))
      }
      if (length(grep('macs', tools)) > 0) {
        pipeline <- rbind(pipeline, cbind('MACS1.4', macs_cmds))
      }
      if (length(grep('track_rna', tools)) > 0) {
        pipeline <- rbind(pipeline, c('Generate RNA-Seq Tracks', track_rna_cmd))
      }
      if (length(pipeline)>0){
        pipeline <- as.data.frame(pipeline)
        colnames(pipeline) <- c('Step', 'Command')
        pipeline
      }
    }
  })
  output$pipeline <- renderDataTable(passData())
  
  output$downloadPipeline <- downloadHandler(
    filename = function(){
      paste0('ngs_miner_v',version,'_',gsub('[ :]+','_',date()),'.sh')
    },
    content = function(file){
      write.table(passData()$Command, file, quote=F, row.names=F, col.names=F)
    }
  )
})
