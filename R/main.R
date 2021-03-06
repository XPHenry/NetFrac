#===========Working version of the dist_mult(NetFrac?) and dist_paths

#=========== Function multicore (taken from BRIDES.r)

multicore<- function(nc=0) {
  cores <- if (.Platform$OS.type == "windows")
    1
  else
    min(8L, ceiling(detectCores()/2))

  getOption("mc.cores", cores)
  if (nc!=0) return (nc)
  return (cores)
}

#============ Main function

#====================================================================================================
#= Main function that returns distance measures for a tree or a graph
#=
#= Input: x, an igraph object (with $weight attribute and $tax attribute for colors, see SDDE::load_network()) or a phylo-class object(see ape::read_tree)
#=		  type, "graph" or "tree"
#=		  distance, "all" #TODO rajouter les autres options pour s?lectionner une seule distance
#=		  col1 and col2, colors to be analyzed (correspond to the factor levels of V(g)$tax)
#=		  info (for tree only), dataframe (of characters) that indicates the color of each tips
#=								 VertexName       Group
#=									  1             A
#=									  2             B
#=									  3             B
#=									  4             A
#=
#= Output: numeric vector with all results
#=
#= All distances are made with vertices of same colors (graph) or external nodes (tree) of same colors
#= and take into account the shortest path
#= Need igraph, SDDE, ape, foreach and doParallel packages
#= Only works with graph and tree with two colors #TODO Works with two colors at a time Ex: for ABC colors, do A and B, B and C, A and C
#=====================================================================================================
#===== rajouter notes sur les distances et aussi dans dist_par

#' Main function that computes all the distances and indices
#'
#' @param x The network (or tree) to be analyzed. The network must be in the igraph format, the edges
#' being accessible with E(x) and vertices with V(x). The communities are under V(x)$tax and the branch weights
#' are under E(x)$weight. These functions are applicable with igraph objects only.
#' @param distances Distances or indices to calculate: Transfer, Transfer2, Spaths, UniFrac and Motifs. The Transfer index,
#' Spaths and Unifrac distances can also be calculated for trees.
#' @param paths This parameter is used to decide whether all the shortest paths between network nodes should be
#' calculated ("all"), or only one of them ("single"). The last option can significantly reduce the time of
#' computation. For Motifs distance, decide the size of the motifs (i.e. 2 or 3).
#' @param mats The similarity matrix used to reconnect the network. See also the function \code{\link{reconnect}}.
#' @param maxcores Uses the multicore function to set up the number of cores to be used.
#' @param share_weight Weight if there are mixed communities (when some species belong to different commmunities).
#'
#' @return
#' $`Spp`\cr
#'A           B\cr
#'A 0.0000000 0.5555556\cr
#'B 0.5555556 0.0000000\cr
#'
#'$Spep\cr
#'A           B\cr
#'A 0.0000000 0.6296296\cr
#'B 0.6296296 0.0000000\cr
#'
#'$Spelp\cr
#'A           B\cr
#'A 0.0000000 0.6296296\cr
#'B 0.6296296 0.0000000\cr
#'
#'$Spinp\cr
#'A           B\cr
#'A 0.0000000 0.9907407\cr
#'B 0.9907407 0.0000000\cr
#
#'$Transfer\cr
#'A           B\cr
#'A 0.0000000 0.6666667\cr
#'B 0.3333333 0.0000000\cr
#' @export
#'
#' @examples NetFrac(net_a)
#'NetFrac(net_a,"Spaths","all")
NetFrac <- function(x, distances = "UniFrac",paths="single", mats="", maxcores=1, share_weight =0){
  #create the different combinations using combn on the taxa levels
  taxlvl <- levels(as.factor(V(x)$tax))
  taxlvl <-unique(unlist(strsplit(taxlvl,"-")))
  taxlevel <- combn(taxlvl,2)

  #create an empty matrix with the size of the taxa levels, that we will fill
  mat <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  mat2 <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  mat3 <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  mat4 <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))
  mat5 <- matrix(0,length(taxlvl),length(taxlvl),dimnames = list(taxlvl,taxlvl))

  #use a matrix to show the results between pairs of communities
  if (distances == "Transfer"){
    mat <- Transfer(x)
    return(mat)
  }
  for (i in 1:(length(taxlevel)/2)){
    if(distances == "Transfer2"){
      #recuperate the return of the dist_path for Transfer distance (asymmetric)
      transf = dist_paths(x,taxlevel[1,i],taxlevel[2,i], matr=mats, distance = distances, paths, maxcores=maxcores,share_w=share_weight)
      mat[taxlevel[1,i],taxlevel[2,i]] <- transf[[1]]
      mat[taxlevel[2,i],taxlevel[1,i]] <- transf[[2]]
      mat2[taxlevel[1,i],taxlevel[2,i]] <- transf[[3]]
      mat2[taxlevel[2,i],taxlevel[1,i]] <- transf[[4]]

    # }else if (distances == "Transfer"){
    #   transf = Transfer(x)
    }else if(distances == "Spaths"){
    #if distance chosen are the paths, then there are multiple values
      transf = dist_paths(x,taxlevel[1,i],taxlevel[2,i], matr=mats, distance = distances, paths, maxcores=maxcores,share_w=share_weight)
      mat[taxlevel[1,i],taxlevel[2,i]] <- transf[[1]]
      mat2[taxlevel[1,i],taxlevel[2,i]] <- transf[[2]]
      mat3[taxlevel[1,i],taxlevel[2,i]] <- transf[[3]]
      mat4[taxlevel[1,i],taxlevel[2,i]] <- transf[[4]]
      mat5[taxlevel[1,i],taxlevel[2,i]] <- transf[[5]]
      mat5[taxlevel[2,i],taxlevel[1,i]] <- transf[[6]]
      # mat[is.na(mat)] <- 0
      # mat2[is.na(mat2)] <- 0
      # mat3[is.na(mat3)] <- 0
      # mat4[is.na(mat4)] <- 0
      # mat5[is.na(mat5)] <- 0
      mat[taxlevel[2,i],taxlevel[1,i]] = mat[taxlevel[1,i],taxlevel[2,i]]
      mat2[taxlevel[2,i],taxlevel[1,i]] = mat2[taxlevel[1,i],taxlevel[2,i]]
      mat3[taxlevel[2,i],taxlevel[1,i]] = mat3[taxlevel[1,i],taxlevel[2,i]]
      mat4[taxlevel[2,i],taxlevel[1,i]] = mat4[taxlevel[1,i],taxlevel[2,i]]

    }else if(distances == "Spp" || distances == "Spep" || distances == "Spelp" || distances == "Spinp"){
      transf = dist_paths(x,taxlevel[1,i],taxlevel[2,i], matr=mat, distance = distances, paths, maxcores=maxcores,share_w=share_weight)
      mat[taxlevel[1,i],taxlevel[2,i]] <- transf[[1]]
      mat[taxlevel[2,i],taxlevel[1,i]] = mat[taxlevel[1,i],taxlevel[2,i]]
      # mat[is.na(mat)] <- 0
    }else if(distances == "UniFrac"){
      mat[taxlevel[1,i],taxlevel[2,i]] <- NetUnifrac(x,taxlevel[1,i],taxlevel[2,i])
      mat[taxlevel[2,i],taxlevel[1,i]] = mat[taxlevel[1,i],taxlevel[2,i]]
    }else if(distances == "Motifs"){
      mat[taxlevel[1,i],taxlevel[2,i]] <- dist_paths(x,taxlevel[1,i],taxlevel[2,i],distance = distances, paths, maxcores=maxcores,share_w=share_weight)

    # #take care of NAs
    # mat[is.na(mat)] <- 0
    # mat2[is.na(mat)] <- 0
    }
  }
  if (distances == "Spaths"){
    mat = list(Spp = mat,Spep = mat2,Spelp = mat3,Spinp = mat4,Transfer = mat5)
  }else if (distances == "Transfer" || distances == "Transfer2"){
    mat = list(Transfer = mat, Transfer2 = mat2)
  }
  return(mat)

}

dist_paths<-function(x, col1, col2, matr="", distance="paths", paths="single", info=NULL, type="graph", maxcores, share_w){
  #cat("distance between ", col1, " and ", col2, "\n")
  #Register the doParallel parallel background
  if(type == "graph"){
    if(distance == "Spaths" || distance =="Transfer2" || distance == "Spp"){

      #Call the function that does the distances with foreach loops
      res_dist =dist_par(x, col1, col2, mat="", distance,paths,maxcores,share_w)
      #res_dist =dist_par(x, col1, col2,distance,paths,maxcores)
      return(unlist(res_dist))
    }
    else if(distance == "Motifs"){
      if(paths==2){

      # NetFrac for motifs of size 2: number of monocolor edges/total number of edges
      motif_dist = get_global_nb_motifs_by_colors(x, 2, col1, col2)
      }else if(paths==3){

      # NetFrac for motifs of size 3: number of monocolor size 3 motifs/total number of size 3 motifs
      motif_dist = get_global_nb_motifs_by_colors(x, 3, col1, col2)
      }
      return(motif_dist$ratio)
      #return(unlist(c(NetFrac_2=NetFrac_2$ratio, NetFrac_3= NetFrac_3$ratio)))
    }

    #res = c(res_dist,list(NetFrac_2=NetFrac_2$ratio, NetFrac_3= NetFrac_3$ratio))
    #return(unlist(res))

    else if(distance == "UniFrac"){
      return(NetUnifrac(x,col1,col2))
    }
  }else if(type == "tree"){
    if(!is.null(info)){

      ## convert tree to the corresponding network
      if(distance == "UniFrac"){
        return("ok")
      }
      else if(distance == "Spaths"){
        # reorder info according to tip labels order (phylo class has tips order from 1 to n and internal nodes n+1 to m)
        info <-info[match(x$tip.label, info[,1]),]

        # convert to character if necessary
        if(class(info[1,1]) != "character"){
          info[1,1] = as.character(info[1,1])
        }

        # remove tips with colors other than color 1 and 2
        rtips_pos <-which( (info[,2]!= col1) & (info[,2]!= col2) )
        rtips <-as.vector(info[,1][rtips_pos])

        if(length(rtips)!=0){ # if there are tips to remove
          x <-drop.tip(x, rtips)
          info <-info[-rtips_pos,]
        }

        tips_number <-c(1:length(x$tip.label))
        tips_name <-x$tip.label
        color_t <-as.vector(info[,2])

        # create graph from edges list
        gtree <-graph_from_edgelist(x$edge, directed = FALSE) #attention à la racine?

        # set colors for the vertices that correspond to the tips
        colored_tips <-intersect(V(gtree), which(tips_name %in% (info[,1]))) #la position des tips_name correspond à son index dans la séquence de vertices
        V(gtree)[colored_tips]$tax = color_t

        # set colors for the vertices that correspont to internal nodes
        tax <-V(gtree)$tax
        vvector <-as_ids(V(gtree))
        vlistna <-vvector[which(is.na(tax))]
        vlist <-vvector[which(!is.na(tax))]

        vtax<-set_node(x$edge, vvector, vlistna, vlist, tax, col1, col2)
        V(gtree)$tax = vtax

        # set weights for nodes
        E(gtree)$weight = x$edge.length

        # Get the vertices that correspond to the tips of the tree
        tips = V(gtree)[tips_number]

        # All paths are calculated from all pairs of same color external nodes in the tree

        #Register the doParallel parallel background

        #Call the function that does the distances with foreach loops
        res_dist_tree = dist_tree_par(gtree, col1, col2, tips)
      }

      return(unlist(res_dist_tree))
    }
    else{
      warning("Requires info argument")
      return(NULL)
    }
  } else {
    warning("Type not recognized")
    return(NULL)
  }
}
