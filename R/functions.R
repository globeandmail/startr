# =======================================================================
# Project-specific functions.
# =======================================================================


#' Wrap text with newline.
#'
#' @param x character vector.
#' @param width number of spaces before wrapping.
#' @return character vector with individual elements wrapped.
#'
#' @details Return atomic vector if input is atomic. Else return list.
wrap_text <- function(x, width = 19){
  if (is.factor(x))
    stop(paste("You haven't implementend this functionality yet.",
               "MAYBE YOU SHOULD DO THAT NOW."))
  wrapped <- lapply(x, function(char) strwrap(char, width))
  wrapped <- lapply(wrapped, paste, collapse = '\n')
  if (is.atomic(x))
    wrapped <- unlist(wrapped)
  return(wrapped)
}
