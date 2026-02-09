library(FlowSOM)
library(data.table)
library(cluster)
library(clusterSim)
library(ggplot2)
library(mclust)
library(infotheo)
library(Rtsne)
library(uwot)

datasets <- list(
  full = "../../data/processed/ProcessedData.csv",
  pca  = "../../data/reduced/dataPCA.csv",
  fs   = "../../data/reduced/dataFS.csv"
)

outDir <- "../../results/flowsom"
dir.create(outDir, showWarnings=FALSE, recursive=TRUE)

xdim <- 10
ydim <- 10
set.seed(42)

select_meta_clusters <- function(codes, mapping, k_range=2:15){
  sil_scores <- numeric(length(k_range))
  
  for(i in seq_along(k_range)){
    k <- k_range[i]
    meta <- kmeans(codes, centers=k, nstart=20)$cluster
    labels <- meta[mapping[,1]]
    
    idx <- sample(seq_along(labels), min(3000, length(labels)))
    sil <- silhouette(labels[idx], dist(codes[mapping[idx,1], ]))
    sil_scores[i] <- mean(sil[,3])
  }
  return(k_range[which.max(sil_scores)])
}

results <- list()

for(name in names(datasets)){
  
  df <- fread(datasets[[name]])
  
  if("Class" %in% colnames(df)){
    y_true <- df$Class
    df[, Class := NULL]
  } else y_true <- NULL
  
  if("V129" %in% colnames(df)) df[, V129 := NULL]
  
  X <- as.matrix(df)
  storage.mode(X) <- "numeric"
  X <- na.omit(X)

  fsom <- FlowSOM(
    X,
    scale = TRUE,
    colsToUse = 1:ncol(X),
    xdim = xdim,
    ydim = ydim,
    seed = 42
  )

  codes <- fsom$map$codes
  mapping <- fsom$map$mapping

  best_k <- select_meta_clusters(codes, mapping, 2:15)
  meta <- kmeans(codes, centers=best_k, nstart=50)$cluster
  labels <- meta[mapping[,1]]

  idx <- sample(1:nrow(X), min(5000, nrow(X)))

  sil <- silhouette(labels[idx], dist(X[idx, ]))
  silScore <- mean(sil[,3])

  dbScore <- index.DB(X[idx, ], labels[idx])$DB

  if(!is.null(y_true)){
    ari <- adjustedRandIndex(y_true, labels)
    nmi <- mutinformation(y_true, labels) / sqrt(entropy(y_true)*entropy(labels))
  } else {
    ari <- NA
    nmi <- NA
  }

  outClusters <- copy(df)
  outClusters[, cluster := labels]
  fwrite(outClusters, paste0(outDir, "/flowsom_", name, "_clusters.csv"))

  umap_emb <- umap(X, n_components=2)
  umap_df <- data.frame(UMAP1=umap_emb[,1], UMAP2=umap_emb[,2], cluster=factor(labels))
  
  ggsave(paste0(outDir,"/flowsom_umap_",name,".png"),
         ggplot(umap_df, aes(UMAP1,UMAP2,color=cluster)) + geom_point(size=0.4))

  tsne_emb <- Rtsne(X, perplexity=30)$Y
  tsne_df <- data.frame(TSNE1=tsne_emb[,1], TSNE2=tsne_emb[,2], cluster=factor(labels))
  
  ggsave(paste0(outDir,"/flowsom_tsne_",name,".png"),
         ggplot(tsne_df, aes(TSNE1,TSNE2,color=cluster)) + geom_point(size=0.4))

  results[[name]] <- data.table(
    Dataset=name,
    Algorithm="FlowSOM",
    SOM_grid=paste0(xdim,"x",ydim),
    MetaClusters=best_k,
    Silhouette=silScore,
    Davies_Bouldin=dbScore,
    ARI=ari,
    NMI=nmi
  )
}

summary <- rbindlist(results)
fwrite(summary, paste0(outDir,"/flowsom_summary.csv"))
print(summary)
