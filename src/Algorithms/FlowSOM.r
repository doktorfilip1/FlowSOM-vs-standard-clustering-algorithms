library(FlowSOM)
library(data.table)
library(cluster)
library(clusterSim)
library(ggplot2)


datasets <- list(
  full = "../../data/processed/ProcessedData.csv",
  pca  = "../../data/reduced/dataPCA.csv",
  fs   = "../../data/reduced/dataFS.csv"
)


outDir <- "../../results/flowsom"


xdim <- 10
ydim <- 10
metaClusters <- 4
set.seed(42)


results <- list()


for (name in names(datasets)) {
  
  df <- fread(datasets[[name]])
  if ("Class" %in% colnames(df)) {
    df[, Class := NULL]
  }
  
  X <- as.matrix(df)
  
  fsom <- FlowSOM(
    X,
    scale = FALSE,
    colsToUse = 1:ncol(X),
    xdim = xdim,
    ydim = ydim,
    nClus = metaClusters,
    seed = 42
  )
  
  
  labels <- fsom$metaclustering[ fsom$map$mapping[,1] ]
  labels <- as.integer(labels)
  
  
  sil <- silhouette(labels, dist(X))
  silScore <- mean(sil[, 3])
  
  dbScore <- index.DB(X, labels)$DB
  
  outClusters <- copy(df)
  outClusters[, cluster := labels]
  
  fwrite(
    outClusters,
    file = paste0(outDir, "/flowsom_", name, "_clusters.csv")
  )
  

  pca <- prcomp(X, center = TRUE, scale. = FALSE)
  pcaData <- data.frame(
    PC1 = pca$x[,1],
    PC2 = pca$x[,2],
    cluster = factor(labels)
  )
  
  p <- ggplot(pcaData, aes(PC1, PC2, color = cluster)) +
    geom_point(size = 0.6) +
    theme_minimal() +
    ggtitle(paste("FlowSOM (", name, ")", sep = ""))
  
  ggsave(
    filename = paste0(outDir, "/flowsom_", name, ".png"),
    plot = p,
    width = 6,
    height = 5,
    dpi = 200
  )
  

  results[[name]] <- data.table(
    Dataset = name,
    Algorithm = "FlowSOM",
    SOM_grid = paste0(xdim, "x", ydim),
    Meta_clusters = metaClusters,
    Silhouette = silScore,
    Davies_Bouldin = dbScore
  )
}


summary <- rbindlist(results)
fwrite(summary, paste0(outDir, "/flowsom_summary.csv"))

print(summary)