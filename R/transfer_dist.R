#===== Using alpha that will determine the proportion of shortest paths as a threshold for transfer
#==== optimized Transfer index with components

#' Algorithm for a fast calculation of the Transfer index (for large networks)
#'
#' The Transfer index can be used to calculate the proportion of species/sequences of community X that have been
#' affected by horizontal gene transfers from species/sequences of community Y. The Transfer index is assymetric and directional.
#' The result is a pairwise matrix reporting the Transfer index for each pair of species communities.
#'
#' @param graph The igraph object
#'
#' @return
#' @export
#' @examples
#' Transfer(net_a)
Transfer <- function(graph){
  #tic("components")
  graph <- simplify(graph)
  V(graph)$pred <- "no"
  #prepare all the possible pairs of commmunity distance
  taxlvl <- levels(factor(V(graph)$tax))
  taxlevels <- combn(taxlvl,2)
  all_comp <- c()
  all_csize <- c()
  all_alpha <- rep(0, length(taxlvl))
  names(all_alpha) <- taxlvl
  list_all <- list()
  denom_all <- count(V(graph)$tax)

  #=== Add component in vertice, initialize matrix
  for (i in taxlvl){
    #== create the components
    group = subgroup_graph(graph,i)
    comp = components(group)

    #== calculate the size of alpha, first subtract, then find min() and the size of comm
    if(comp$no == 1){
      alpha = length(V(graph))/2
    }else{
      comp$diff <- ave(comp$csize[order(-comp$csize)], FUN=function(x) c(0, diff(x)))
      min_comp <- which(comp$diff == min(comp$diff))
      alpha <- (comp$csize[order(-comp$csize)][min_comp-1] + comp$csize[order(-comp$csize)][min_comp])/2
      if (length(alpha) > 1){
        all_alpha[i] <- alpha[1]
      }else{
        all_alpha[i] <- alpha
      }
    }

    #== create a unique name for each component
    name_comp <- names(comp$membership)
    comp$membership = paste0(i,comp$membership)

    #== store the information in lists to make it faster
    V(graph)[name_comp]$comp <- comp$membership
    all_comp <- append(all_comp,paste0(i,1:length(comp$csize)))
    list_all <- append(list_all,list(paste0(i,1:length(comp$csize))))

    #== save the size for further use
    names(comp$csize) <- paste0(i,1:length(comp$csize))
    all_csize <- append(all_csize,comp$csize)
  }
  names(list_all) <- taxlvl
  mat1 <- matrix(0, length(all_comp),length(all_comp))
  dimnames(mat1) <- list(all_comp,all_comp)
  edges <- as_edgelist(graph)
  #toc()
  #=== each edge determines if components are connected
  #tic("matrix")
  nodes <- V(graph)$name
  compon <- V(graph)$comp
  for (i in 1:length(edges[,1])){
    comp1 <- compon[which(nodes == edges[i,1])]
    comp2 <- compon[which(nodes == edges[i,2])]

    if (all_csize[comp1] < all_csize[comp2]){
      mat1[comp1,comp2] <- 1
    }else if (all_csize[comp2] < all_csize[comp1]){
      mat1[comp2,comp1] <- 1
    }else{
      mat1[comp1,comp2] <- 0.5
      mat1[comp2,comp1] <- 0.5
    }
    #too slow
    #mat1[V(graph)$comp[as.integer(edges[i,2])],V(graph)$comp[as.integer(edges[i,1])]] <- 1
  }
  result <- matrix("-",length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  result2 <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  #toc()
  #tic("calculation")
  for (i in 1:(length(taxlevels)/2)){
    col1 = noquote(taxlevels[1,i])
    col2 = noquote(taxlevels[2,i])
    list_col1 <- unlist(list_all[col1])
    list_col2 <- unlist(list_all[col2])
    mat1_col1 <- mat1[list_col1,list_col2,drop=FALSE]
    mat1_col2 <- mat1[list_col2,list_col1,drop=FALSE]
    denom_T = denom_all[which(denom_all$x==col1),2]
    # count the number of transferred nodes
    a = 0
    for(j in 1:length(mat1_col1[,1])){
      if(sum(mat1_col1[j,]) > 0){
        size = all_csize[row.names(mat1_col1)[j]]

        #alpha is the number of edges that are not connected to a monochrome path
        #any community smaller than 5 ( or another number) will automatically considered to be a transfer
        if (size <= all_alpha[col1] | denom_T <= 5){
          a = a + (size*max(mat1_col1[j,]))
          positive = which(V(graph)$comp == row.names(mat1_col1)[j])
          V(graph)$pred[positive] = "yes"
        }
      }
    }

    result[taxlevels[2,i],taxlevels[1,i]] <- (round((1-a/denom_T),3))

    #=== same operation for the other side
    denom_T2 = denom_all[which(denom_all$x==col2),2]
    a = 0
    for(j in 1:length(mat1_col2[,1])){
      if(sum(mat1_col2[j,]) > 0){
        size2 = all_csize[row.names(mat1_col2)[j]]

        if(size2 <= all_alpha[col2] | denom_T2 <= 5){
          a = a + (size2*max(mat1_col2[j,]))
          positive = which(V(graph)$comp == row.names(mat1_col2)[j])
          V(graph)$pred[positive] = "yes"
        }
      }
    }

    result[taxlevels[1,i],taxlevels[2,i]] <- (round((1-a/denom_T2),3))
  }
  #toc()
  #return(result)
  return(noquote(V(graph)$pred))
}

