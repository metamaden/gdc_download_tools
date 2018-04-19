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
dfslide.coadread <- as.data.frame(matrix(nrow=0,ncol=10))
namesx <- c("bc","patid","hist.id","hist.type","tumorcell.perc","normcell.perc",
            "necr.perc","strom.perc","slide.side","filename")
colnames(dfslide.coadread) <- namesx

for(i in 1:length(xmlcr.list)){
  xi <- xmlcr.list[[i]]
  
  # grab xml list data for patient sample/slide i
  
  pidi <- xi$patient_id$text # patient id
  hist.codei <- xi$samples$sample$sample_type_id$text # histology tissue code 
  hist.typei <- xi$samples$sample$sample_type$text # histology description
  
  if(!is.null(xi$samples$sample$portions$portion$slides)){
    
    nslidesi <- length(xi$samples$sample$portions$portion$slides)
    return.row <- list()
    
    
    if(nslidesi>1){
      for(x in 1:nslidesi){
        slidex <- xi$samples$sample$portions$portion$slides[[x]]
        
        bci <- slidex$bcr_slide_barcode$text # barcode,full
        
        if(length(slidex$percent_tumor_cells)==2){
          tcellperci <- slidex$percent_tumor_cells$text # tumor cell percent
        } else{
          tcellperci <- "NA"
        }
        
        if(length(slidex$percent_normal_cells)==2){
          ncellperci <- slidex$percent_normal_cells$text # norm cell percent
        } else{
          ncellperci <- "NA"
        }
        
        if(length(slidex$percent_necrosis)==2){
          necrperci <- slidex$percent_necrosis$text # necrosis percent
        } else{
          necrperci <- "NA"
        }
        
        if(length(slidex$percent_stromal_cells)==2){
          stromperci <- slidex$percent_stromal_cells$text # stromal cell percent
        }else{
          stromperci <- "NA"
        }
        
        if(!is.null(slidex$section_location)){
          slidesidei <- slidex$section_location$text # slide side (TOP/BOTTOM)
        } else{
          slidesidei <- "NA"
        }
        
        if(length(slidex$image_file_name)==2){
          filenamei <- slidex$image_file_name$text
        } else{
          filenamei <- "NA"
        }
        
        rrv <- as.vector(c(bci,pidi,
                           hist.codei,hist.typei,
                           tcellperci,ncellperci,necrperci,stromperci,
                           slidesidei,
                           filenamei))
        names(rrv) <- namesx
        
        return.row[[x]] <- rrv
        
      }
    } else{
      
      slidex1 <- xi$samples$sample$portions$portion$slides$slide
      
      bci <- slidex$bcr_slide_barcode$text # barcode,full
      
      if(length(slidex1$percent_tumor_cells)==2){
        tcellperci <- slidex1$percent_tumor_cells$text # tumor cell percent
      } else{
        tcellperci <- "NA"
      }
      
      if(length(slidex1$percent_normal_cells)==2){
        ncellperci <- slidex1$percent_normal_cells$text # norm cell percent
      } else{
        ncellperci <- "NA"
      }
      
      if(length(slidex1$percent_necrosis)==2){
        necrperci <- slidex1$percent_necrosis$text # necrosis percent
      } else{
        necrperci <- "NA"
      }
      
      if(length(slidex1$percent_stromal_cells)==2){
        stromperci <- slidex1$percent_stromal_cells$text # stromal cell percent
      }else{
        stromperci <- "NA"
      }
      
      if(!is.null(slidex1$section_location)){
        slidesidei <- slidex1$section_location$text # slide side (TOP/BOTTOM)
      } else{
        slidesidei <- "NA"
      }
      
      if(length(slidex1$image_file_name)==2){
        filenamei <- slidex1$image_file_name$text
      } else{
        filenamei <- "NA"
      }
      
      rrv <- as.vector(c(bci,pidi,
                         hist.codei,hist.typei,
                         tcellperci,ncellperci,necrperci,stromperci,
                         slidesidei,
                         filenamei))
      names(rrv) <- namesx
      
      return.row[[1]] <- rrv
      
    }
  } else{
    bci <- tcellperci <- ncellperci <- necrperci <- stromperci <- slidesidei <- filenamei <- "NA"
    
    rrv <- as.vector(c(bci,pidi,
                       hist.codei,hist.typei,
                       tcellperci,ncellperci,necrperci,stromperci,
                       slidesidei,
                       filenamei))
    names(rrv) <- namesx
    
    return.row[[1]] <- rrv
  }
  
  # rbind the rows to return, can accept multiple rows where multiple slides available
  if(nslidesi>1){
    
    for(x in 1:length(return.row)){
      dfbindx <- as.data.frame(matrix(return.row[[x]],ncol=10))
      colnames(dfbindx) <- names(return.row[[x]])
      dfslide.coadread <- rbind(dfslide.coadread,dfbindx)
      
    }
    
  } else{
    dfbindx <- as.data.frame(matrix(return.row[[1]],ncol=10))
    colnames(dfbindx) <- names(return.row[[1]])
    dfslide.coadread <- rbind(dfslide.coadread,dfbindx)
  }
  
  message(i)
}

dim(dfslide.coadread) # [1] 1148   10
dfslide.coadread <- dfslide.coadread[!duplicated(dfslide.coadread$filename),]; 
dim(dfslide.coadread) # [1] 1144   10

write.csv(dfslide.coadread,file="dfslide-biospecimen_coadread_gdcDL.csv",row.names=F)
save(dfslide.coadread,file="dfslide_coadread_gdcDL.rda")

