#==================================
#Find clusters, betweenness, and connect the clusters with the highest betweeness centrality node
#For unconnected subgraphs, since it will alter the shortest path possibilities

#Requires the igraph package
#==================================


#' Connects the network using betweenness centrality
#'
#' Creates a connected network using the betweenness centrality principle.
#'
#' @param graph The disconnected igraph object
#'
#' @return
#' @export
#' @seealso \code{\link{reconnect}}
#' @examples
#'
reconnect_btw <- function(graph){
  #find the clusters in the graph
  cl <- components(graph)
  #associate the nodes to the cluster
  all_cluster = lapply(seq_along(cl$csize), function(x) V(graph)$name[cl$membership %in% x])
  #print(all_cluster)

  #store all the maximum betweenness nodes
  max_btw = c()
  #find the nodes with the highest bet. centrality - we will use those ones to make new edges
  for(clique in all_cluster){
    clust = induced.subgraph(graph,clique)

    V(clust)$btw = betweenness(clust)
    max_node = which(V(clust)$btw == max(V(clust)$btw))
    if(length(max_node >1)){
      max_btw <- append(max_btw,V(clust)[max_node[1]]$name)
    }else{max_btw = append(max_btw,V(clust)[max_node]$name)}
  }

  #also consider the lonely nodes
  deg = which(igraph::degree(graph,V(graph),mode = "all")==0)
  max_btw <- append(max_btw,V(graph)[deg]$name)
  #pair up all the possible combinations of nodes
  pairs_btw <- c()
  if(length(max_btw > 1)){
    pairs_btw <- combn(max_btw,2)
  }

  #set the length of the edge (will be equal to the sum of the graph edges weights)
  e_weight = sum(E(graph)$weight)

  for (i in 1:length(pairs_btw)/2){
    graph = add.edges(graph,c(pairs_btw[1,i],pairs_btw[2,i]),weight = e_weight)
  }
  return(graph)
}

#version de la fonction s'il y a une matrice
#' Connects the network using a similarity matrix
#'
#' Creates a connected network using a similarity matrix between nodes.
#'
#' @param graph The disconnected igraph object
#' @param matrice The similarity matrix containing pairwise distances between the nodes
#'
#' @return
#' @export
#' @seealso \code{\link{reconnect_btw}}
#' @examples
reconnect <- function(graph,matrice = ""){
  #find the clusters in the graph
  cl <- components(graph)
  #associate the nodes to the cluster
  all_cluster = lapply(seq_along(cl$csize), function(x) V(graph)$name[cl$membership %in% x])

  #stocker les paires de cluster
  pairs_mat <- combn(seq(1:length(all_cluster)),2)

  #all_pairs va aller chercher les paires de noeuds par nom, puis stocker les noeuds de valuer max dans max_mat
  #dans une matrice de similarité
  max_mat <- c()
  for (i in 1:(length(pairs_mat)/2)){
    all_pairs <- expand.grid(all_cluster[[pairs_mat[1,i]]],all_cluster[[pairs_mat[2,i]]])
    for(j in 1:length(all_pairs$Var1)){
      all_pairs$Val[j] = mat1[all_pairs[j,1],all_pairs[j,2]]
    }
    n = which(all_pairs$Val== max(all_pairs$Val))[1]
    max_mat <- base::append(max_mat, as.character(all_pairs$Var1[n]))
    max_mat <- base::append(max_mat, as.character(all_pairs$Var2[n]))
  }
  if (sum(E(graph)$weight) == 0){
    e_weight = 1
  }else{
    e_weight = sum(E(graph)$weight)
  }
  graph = add.edges(graph,max_mat,weight = e_weight)
  return(graph)
}
