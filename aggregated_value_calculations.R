CWM_trait <- function(trait_vec,intensity_matrix,relative=TRUE){
  intensity_matrix[is.na(intensity_matrix)] <- c(0)
  if(relative==FALSE){
    col_sums <- colSums(intensity_matrix)
    intensity_matrix <- sweep(intensity_matrix, 2, col_sums, '/')
  }
  as.numeric( matrix(trait_vec, nrow = 1) %*% as.matrix(intensity_matrix) )
}