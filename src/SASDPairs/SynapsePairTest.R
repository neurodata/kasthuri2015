# This script runs a series of tests to evaluate the the assertions of 

require(R.matlab)
require(plyr)
require(dplyr)
require(ggplot2)
require(doParallel)
registerDoParallel(3)



#' Multiple plot function
#
# 
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
#' If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
#' then plot 1 will go in the upper left, 2 will go in the upper right, and
#' 3 will go all the way across the bottom.
#'
#' 
#' 
#' @param  plotlist=NULL list of plots 
#' @param  cols=1 number of columns
#' @param  layout=NULL matrix indicating where to place plots (see descritipion)
#' @export
multiplot <- function(..., plotlist=NULL, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

density.plot <- function(df,name){
    n <- nrow(df)
    df$a <- df[,name]
    df <- df %.% group_by(pair) %.% mutate(m=mean(a))
    df$sp <- (rank(df$m)+0.5)/2
    g <- ggplot(df, aes_string(paste0("x=",name)))+geom_density()+
        theme(legend.position="none")+
        stat_function(fun = dnorm,args=list(mean=mean(df$a),sd=sd(df$a)),color="grey")

    gb <- ggplot_build(g)
    ymax <<- gb$panel$ranges[[1]]$y.range[2]

    g+geom_line(aes(y=1.8*ymax*sp/n,color=factor(pair)))
}

pair.to.df <- function(p){
    p <- drop(p)
    df <- ldply(p,rbind)
    dft <- data.frame(t(df[,2:ncol(df)]))
    colnames(dft) <- df[,1]
    return(dft)
}


get.diffs <- function(df,col,type){
    pairs <- expand.grid(p1=1:nrow(df),p2=1:nrow(df)) %.% 
        filter(p1<p2) %.% 
        mutate(sd = df$dparentid[p1]==df$dparentid[p2]) %.% 
        mutate(sa = df$aparentid[p1]==df$aparentid[p2])
    if(type=="factor"){
        pairs <- pairs %.% mutate(col = as.numeric(df[p1,col]!=df[p2,col]))
    }
    if(type=="difference"){
        pairs <- pairs %.% mutate(col = abs(df[p1,col]-df[p2,col]))  
    }
    if(type=="ratio"){
        pairs <- pairs %.% mutate(col = abs(log(df[p1,col])-log(df[p2,col])))
    }
    colnames(pairs)[ncol(pairs)] = col
    return(pairs)
}

get.all.diffs <- function(df){
    pairs <- expand.grid(p1=1:nrow(df),p2=1:nrow(df)) %.% filter(p1<p2) 
    for(col in colnames(df)){
        if(is.factor(df[,col])){
            pairs <- pairs %.% mutate(abc= as.numeric(df[p1,col]!=df[p2,col])) 
        }
        if(is.numeric(df[,col])){
            pairs <- pairs %.% mutate(abc = abs(df[p1,col]-df[p2,col]))
        }
        colnames(pairs)[ncol(pairs)]=col
    }

    return(add.sasd(pairs))
}

add.sasd <- function(pairs){
    pairs <- pairs %.% mutate(sd = dparentid==0, sa = aparentid==0, sasd = factor(sa+2*sd )) %.%
        mutate(sd = factor(sd),sa=factor(sa)) %.% 
        select(-spineid,-dparentid,-aparentid)

    levels(pairs$sasd) = c("DADD","SADD","DASD","SASD")
    return(pairs)
}

get.mean.diff <- function(pairs,col,p=FALSE){
    df <- eval(substitute(
        summarise(pairs %.% group_by(sasd) , mean(col)),
        list(col = as.name(col))))
    if(p){
        cat(paste(col, signif(df[2,2],3), signif(df[1,2],3), signif(df[1,2]-df[2,2],3), "", sep=" & " ))
    }
    df[1,2]-df[2,2]

}


permute <- function(pairs){
    pairs$sasd = sample(pairs$sasd,nrow(pairs))
    return(pairs)
}
abs.diff <- function(a,b) abs(a-b)
neq.diff <- function(a,b) as.numeric(a!=b)

compare <- function(df,save=F){

    test.col = c("spinevolume","psdvol","spineapp","nrmitos","nrvesicles")
    test.type = c("ratio","ratio","factor","factor","ratio")

    res.df <- data.frame(name=character(), mean.same=numeric(),mean.notsame = numeric(),mean.diff=numeric(), type=character(),p.value=numeric()  )

    for(i in 1:length(test.col)){
        col = test.col[i]
        cat(paste0("\n\n",col,"\n"))
        type = test.type[i]
        res.df <- rbind(res.df,compare.pairs(df,col,type,save))

    }
#    multiplot(plotlist=g,cols=3)
    return(res.df)
}


compare.pair.which <- function(pairs, col, which=c(T,F),nmc = 1000){
    if(is.list(which)){
        p <- filter(pairs, sasd %in% unlist(which))
        p <- mutate(p, sasd = sasd %in% which[[1]])
    }
    else{
        p <- filter(pairs, sasd %in% which)
        p <- mutate(p, sasd = sasd==which[1])
    }


    diff.true <- get.mean.diff(p,col,TRUE)
    
    diff.perm <- foreach(i=1:nmc, .combine='c') %dopar% {
        get.mean.diff(permute(p),col,F)        
    }
    pv <-  mean(diff.true<diff.perm)
    cat(pv)
    cat(" \\\\ \n")
    return(list(perm=diff.perm,true=diff.true))
}

diff.density.plot <-  function(pairs,fn=NULL){
    gLsv <- ggplot(pairs, aes(x=log.spinevolume, color=sasd,linetype=sasd))+geom_density()
    gLpv <- ggplot(pairs, aes(x=log.psdvol, color=sasd,linetype=sasd))+geom_density()
    gLnv <- ggplot(pairs, aes(x=log.nrvesicles, color=sasd,linetype=sasd))+geom_density()
    gsv <- ggplot(pairs, aes(x=spinevolume, color=sasd,linetype=sasd))+geom_density()
    gpv <- ggplot(pairs, aes(x=psdvol, color=sasd,linetype=sasd))+geom_density()
    gnv <- ggplot(pairs, aes(x=nrvesicles, color=sasd,linetype=sasd))+geom_density()

    if(!is.null(fn)){
        pdf(fn,width=12,height=6)
        multiplot(gLsv,gsv,gLpv,gpv,gLnv,gnv,cols=3)
        dev.off()
    }
    else{
        multiplot(gLsv,gsv,gLpv,gpv,gnv,gLnv,cols=3)
    }
    # return(g)
}

compare.pairs <- function(df, col,type,save=F){
        pairs <- get.diffs(df,col,type)

        if(type != "factor"){
            g <- ggplot(pairs,aes_string(x=col,color="sasd"))+geom_density()+xlab(paste(col,type))
            print(g)
            if(save){
                ggsave(paste0("./Figures/sasdpairs_",col,"_diff_density.pdf"),g,width=6,height=4)
            }
        }

        diff.true <- get.mean.diff(pairs,col,TRUE)
        print(diff.true)
        
        diff.perm <- replicate(10000,get.mean.diff(permute(pairs),col,F))
        p <-  mean(diff.true>diff.perm)
        print(mean(diff.true>diff.perm))
        g <- qplot(diff.perm,geom="density")+geom_vline(xintercept=diff.true)+ggtitle(col)
        if(save){
            ggsave(paste0("./Figures/sasdpairs_",col,"_meandiff_density.pdf"),g,width=4,height=4)
        }

        print(wilcox.test(pairs[pairs$sasd,4],pairs[!pairs$sasd,4],alternative="less"))

        data.frame(name=col,mean.diff=diff.true, type=type,p.value=p)
}

main <- function(df){
    pairs <- get.all.diffs(df)
    test.cols <- c("log.spinevolume","log.psdvol","log.nrvesicles","spineapp","nrmitos")


    cat("Difference Densities Plots\n\n")
    diff.density.plot(pairs,"./Figures/sasdDensityPlots.pdf")

    cat("Compare SASD to the Rest\n\n")
    which = list(c("SASD"),c("DASD","SADD","DADD"))

    sasd.rest.list <- list()
    plot.list <- list()
    cat("Feat. & Avg 1 & Avg 2 & Difference & pval ")
    for(col in test.cols){
        sasd.rest.list[[col]] <- compare.pair.which(pairs,col, which,1000)
        plot.list[[col]] <- qplot(sasd.rest.list[[col]][[1]],geom="density")+
            geom_vline(xintercept=sasd.rest.list[[col]][[2]])+
            xlab(col)

    }
    pdf("./Figures/permutationDensity_sasdVSrest.pdf",width=12, height=6)
    print(multiplot(plotlist = plot.list,cols=3))
    dev.off()


    cat("Compare SASD to SADD\n\n")
    which = list(c("SASD"),c("SADD"))

    sasd.sadd.list <- list()
    plot.list <- list()
    cat("Feat. & Avg 1 & Avg 2 & Difference & pval ")
    for(col in test.cols){
        sasd.sadd.list[[col]] <- compare.pair.which(pairs,col, which,10000)
        plot.list[[col]] <- qplot(sasd.sadd.list[[col]][[1]],geom="density")+
            geom_vline(xintercept=sasd.sadd.list[[col]][[2]])+
            xlab(col)

    }
    pdf("./Figures/permutationDensity_sasdVSsadd.pdf",width=12, height=6)
    print(multiplot(plotlist = plot.list,cols=3))
    dev.off()


    cat("Compare SADD to DADD\n\n")
    which = list(c("SADD"),c("DADD"))

    sadd.dadd.list <- list()
    plot.list <- list()
    cat("Feat. & Avg 1 & Avg 2 & Difference & pval ")
    for(col in test.cols){
        sadd.dadd.list[[col]] <- compare.pair.which(pairs,col, which,10000)
        plot.list[[col]] <- qplot(sadd.dadd.list[[col]][[1]],geom="density")+
            geom_vline(xintercept=sadd.dadd.list[[col]][[2]])+
            xlab(col)

    }
    pdf("./Figures/permutationDensity_saddVSdadd.pdf",width=12, height=6)
    print(multiplot(plotlist = plot.list,cols=3))
    dev.off()


    cat("\nCompare DADD to the rest\n\n")
    which = list(c("SASD","DASD","SADD"),c("DADD"))
    rest.dadd.list <- list()
    plot.list <- list()
    cat("Feat. & Avg 1 & Avg 2 & Difference & pval ")
    for(col in test.cols){
        rest.dadd.list[[col]] <- compare.pair.which(pairs,col, which,1000)
        plot.list[[col]] <- qplot(sasd.rest.list[[col]][[1]],geom="density")+
            geom_vline(xintercept=sasd.rest.list[[col]][[2]])+
            xlab(col)

    }
    pdf("./Figures/permutationDensity_daddVSrest.pdf",width=12, height=6)
    print(multiplot(plotlist = plot.list,cols=3))
    dev.off()

    cat("\nAdjusted $p$-values via BY")
    print(p.adjust(laply(sasd.rest.list,function(a)mean(a[[1]]<a[[2]]))))

    cat("Compare SASD to DASD")
    which = c("SASD","DASD")
    sasd.dasd.list <- list()
    plot.list <- cat()
    print("Feat. & Avg 1 & Avg 2 & Difference & pval ")
    for(col in test.cols){
        sasd.dasd.list[[col]] <- compare.pair.which(pairs,col, which,1000)
        plot.list[[col]] <- qplot(sasd.dasd.list[[col]][[1]],geom="density")+
            geom_vline(xintercept=sasd.dasd.list[[col]][[2]])+
            xlab(col)

    }
    pdf("./Figures/permutationDensity_sasdVSdasd.pdf",width=12, height=6)
    print(multiplot(plotlist = plot.list,cols=3))
    dev.off()

    
    list(sasd.rest.list,sasd.sadd.list,sadd.dadd.list,rest.dadd.list,sasd.dasd.list)

}

# Load Data
pairmat <- readMat("./sasdpairs.mat")$sasdpairs

# Reformat and add some columns
df <- pairmat %.% ldply(pair.to.df) %.% as.tbl() %.%
    select(-.id,-axpartid) %.%
    mutate(log.spinevolume=log10(spinevolume),log.psdvol = log10(psdvol),log.nrvesicles=log10(nrvesicles))
df$spineid = as.factor(df$spineid)
df$dparentid = as.factor(df$dparentid)
df$aparentid = as.factor(df$aparentid)
df$spineapp = as.factor(df$spineapp)
df$nrmitos = as.factor(df$nrmitos)
df$spineid = as.factor(df$spineid)

# Run the analysis
allResults <- main(df)

print("DONE")