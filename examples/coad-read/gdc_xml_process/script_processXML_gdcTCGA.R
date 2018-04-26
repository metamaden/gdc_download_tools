# script: parse and reformat GDC XML data download

# NOTES: 
# to download xml files off gdc, download the manifest, 
# navigate to dir with manifest and gdc dl client .exe file, and use the following:
# gdc-client download -m gdc_manifest.2018-04-19.txt
# see examples folder for output files and the manifest table

library(XML)

#=============================
# make list of xml data files
#=============================
fn <- list.files()
fn.oi <- fn[nchar(fn)==36]; length(fn.oi) # 633 xml files


# x <- fn.oi[1]
xmlcr.list <- list()

#lapply(fn.oi,function(x){

for(i in 1:length(fn.oi)){
  x <- fn.oi[i]
  pathi <- paste0(getwd(),"/",x)
  lfi <- list.files(pathi); lfi.xml <- lfi[grepl(".xml",lfi)]
  pathi.xml <- paste0(pathi,"/",lfi[grepl(".xml",lfi)])
  xmli <- xmlToList(xmlParse(pathi.xml))
  
  slide.sidei <- xmli$patient$samples$sample$portions$portion$slides$slide$section_location$text
  
  xmlcr.list[length(xmlcr.list)+1] <- list(xmli$patient)
  names(xmlcr.list)[length(xmlcr.list)] <- paste0("patid-",xmli$patient$patient_id$text,"_slide-",slide.sidei)
  message(i)
}

save(xmlcr.list,file="gdcDL_xml-biospec_coadread_patient-data-list.rda")

#===========================================
# assemble df from desired data of interest
#===========================================
slide.df <- as.data.frame(matrix(nrow=0,ncol=8))
colnames(slide.df) <- c("pat.id","nsamples","nslides","slide.file","slide.bc","perc.norm","perc.tumor","perc.strom","perc.necr")

for(i in 1:length(xml)){
  samplesi <- xml[[i]]$samples
  pat.idi <- names(xml)[i]
  
  slide.filename.jx <- slide.bc.jx <- perc.norm.jx <- perc.tumor.jx <- perc.strom.jx <- perc.necr.jx <- c()
  
  nslide.j <- c()
  
  for(j in 1:length(samplesi)){
    
    xij <- samplesi[[j]]$portion$portion$slides
    
    nslide.j <- c(nslide.j,length(xij))
     
    if(length(xij)>0){
      for(x in 1:length(xij)){
        slidex <- xij[[x]]
        
        if("text" %in% names(slidex$percent_tumor_cells)){
          perc.tumor.jx <- c(perc.tumor.jx,slidex$percent_tumor_cells$text)
        } else{perc.tumor.jx <- c(perc.tumor.jx,"NA")}
        
        if("text" %in% names(slidex$percent_normal_cells)){
          perc.norm.jx <- c(perc.norm.jx,slidex$percent_normal_cells$text)
        } else{perc.norm.jx <- c(perc.norm.jx,"NA")}
        
        if("text" %in% names(slidex$percent_stromal_cells)){
          perc.strom.jx <- c(perc.strom.jx,slidex$percent_stromal_cells$text)
        } else{perc.strom.jx <- c(perc.strom.jx,"NA")}
        
        if("text" %in% names(slidex$percent_necrosis)){
          perc.necr.jx <- c(perc.necr.jx,slidex$percent_necrosis$text)
        } else{perc.necr.jx <- c(perc.necr.jx,"NA")}
        
        if("text" %in% names(slidex$bcr_slide_barcode)){
          slide.bc.jx <- c(slide.bc.jx,slidex$bcr_slide_barcode$text)
        } else{slide.bc.jx <- c(slide.bc.jx,"NA")}
        
        if("text" %in% names(slidex$image_file_name)){
          slide.filename.jx <- c(slide.filename.jx,slidex$image_file_name$text)
        } else{slide.filename.jx <- c(slide.filename.jx,"NA")}
        
      }
      
      
    }
    
    
  }
  
  if(length(perc.tumor.jx)>0){
    ret <- data.frame(pat.id=rep(pat.idi,length(perc.tumor.jx)),
                      nsamples=rep(length(samplesi),length(perc.tumor.jx)),
                      nslides=rep(paste0(nslide.j,collapse=";"),length(perc.tumor.jx)),
                      slide.file=slide.filename.jx,
                      slide.bc=slide.bc.jx,
                      perc.norm=perc.norm.jx,
                      perc.tumor=perc.tumor.jx,
                      perc.strom=perc.strom.jx,
                      perc.necr=perc.necr.jx,stringsAsFactors = F)
    
    slide.df <- rbind(slide.df,ret)
    
  } else{
    ret <- data.frame(pat.id=pat.idi,
                      nsamples=length(samplesi),
                      nslides=paste0(nslide.j,collapse=";"),
                      slide.file="NA",slide.bc="NA",perc.norm="NA",perc.tumor="NA",perc.strom="NA",
                      perc.necr="NA",stringsAsFactors = F)
    slide.df <- rbind(slide.df,ret)
  }
  
  
  message(i)
}

dim(slide.df)
#[1] 1305    9
dim(dfslide.coadread)
#[1] 1144   10
length(unique(slide.df$pat.id))
#[1] 633
table(slide.df$nslides) # format: '#slides-sample1; #slides-sample2; etc.'
#0;0     1;0   1;0;0   1;0;1     1;1   1;1;0   1;2;0     2;0 2;0;0;1   2;0;1   2;0;2     2;1     2;2   2;2;0 2;2;0;1 2;2;0;2 
#2     110       1       4       2       2       9     804       9     132      16     102      68      12      20      12
length(unique(slide.df[!slide.df$perc.necr=="NA",]$pat.id))
#[1] 631

write.csv(slide.df,"biospec-gdcDL_slide-df-allsamples__coad-read-tcga.csv")
save(slide.df,file="biospec-gdcDL_slide-df-allsamples__coad-read-tcga.rda")
