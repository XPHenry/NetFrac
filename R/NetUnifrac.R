#========================================
#= Unifrac distance for similarity sequence networks
#========================================

#going on the same basis as the UniFrac definition, where only unique branches are counted in the distance
#compare the nodes from an edge to determine if they are different (if so, the branch(edge) is shared)
#' NetUniFrac based on UniFrac for trees
#'
#' Calculates the network version of the UniFrac distance.
#'
#' @param igraph The igraph object
#' @param tax1 The first community
#' @param tax2 The second community
#' @param weight Use weights of the edges if existing
#'
#' @return
#' @export
#'
#' @examples
#' NetUnifrac(net_a,"A","B")
NetUnifrac <- function(igraph, tax1 ="", tax2 ="",weight =TRUE){

  #find the nodes with mixed communities
  col1_mix <- paste(append(tax1,"-"),collapse = "")
  col1_mix2 <- paste(append("-",tax1),collapse = "")

  #find the ones that contain the communities in this iteration
  v.mix <- grep(col1_mix,V(igraph)$tax)
  v.mix <- append(v.mix,grep(col1_mix2,V(igraph)$tax))
  #change to tax1, so it is not mixed anymore
  V(igraph)$tax[v.mix] = tax1

  #create subgraph that contains the two communities
  igraph2 <- igraph
  if (tax1 != ""){
    igraph2<-subgroup_graph(igraph,c(tax1,tax2))
  }
  igraph_edge <- get.edgelist(igraph2)
  igraph_V <- V(igraph2)
  #which pair of nodes that make an edge have same tax, select only number of pairs
  selection <- which(igraph_V[igraph_edge[,1]]$tax == igraph_V[igraph_edge[,2]]$tax)

  #same for second community
  col2_mix <- paste(append(tax2,"-"),collapse = "")
  col2_mix2 <- paste(append("-",tax2),collapse = "")
  v.mix2 <- grep(col2_mix,V(igraph)$tax)
  v.mix2 <- append(v.mix2,grep(col2_mix2,V(igraph)$tax))
  V(igraph)$tax[v.mix2] = tax2

  if (tax2 != ""){
    igraph2=subgroup_graph(igraph,c(tax1,tax2))
  }
  igraph_edge <- get.edgelist(igraph2)
  igraph_V <- V(igraph2)
  #which pair of nodes that make an edge have same tax, select only number of pairs
  selection <- append(selection,which(igraph_V[igraph_edge[,1]]$tax == igraph_V[igraph_edge[,2]]$tax))
  selection = unique(selection)

  if(weight){
    w_selection <- sum(E(igraph2)[selection]$weight)
    distance <- w_selection/sum(E(igraph2)$weight)
  }
  else{
    selection <- length(selection)
    distance <- selection/(length(igraph_edge)/2)
  }
  return (distance)
}
