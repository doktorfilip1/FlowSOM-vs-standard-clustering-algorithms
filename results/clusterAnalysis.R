library(data.table)
library(dplyr)
library(ggplot2)
library(pheatmap)

folders <- c("kmeans","flowsom","dbscan","gmm","hdbscan")
variants <- c("full","pca","fs")

for(f in folders){
  for(v in variants){
    
    path <- paste0("../results/", f, "/", f, "_", v, "_clusters.csv")
    if(!file.exists(path)) next
    
    cat("Processing:", path, "\n")
    df <- read.csv(path)
    
    dist <- table(df$cluster)
    write.csv(dist, paste0("../results/", f, "/clusterAnalysis/", v, "_cluster_distribution.csv"))
    
    prof <- df %>%
      group_by(cluster) %>%
      summarise(across(where(is.numeric), mean, na.rm=TRUE))
    
    write.csv(prof, paste0("../results/", f, "/clusterAnalysis/", v, "_cluster_profiles.csv"))
    
    pdf(paste0("../results/", f, "/clusterAnalysis/", v, "_heatmap.pdf"))
    mat <- as.matrix(prof[,-1])
    rownames(mat) <- paste0("C", prof$cluster)
    pheatmap(scale(mat))
    dev.off()
  }
}