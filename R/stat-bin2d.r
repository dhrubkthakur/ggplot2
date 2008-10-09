StatBin2d <- proto(Stat, {
  objname <- "bin2d" 
  desc <- "2d binning"
  default_aes <- function(.) aes(fill = ..count..)
  required_aes <- c("x", "y")
  default_geom <- function(.) GeomRect
  
  calculate <- function(., data, scales, binwidth = NULL, breaks = NULL, origin = NULL, drop = TRUE, ...) {
    
    range <- list(
      x = scales$get_scales("x")$output_set(),
      y = scales$get_scales("y")$output_set()
    )
    
    # Determine binwidth, if omitted
    if (is.null(binwidth)) {
      binwidth <- c(NA, NA)
      if (is.integer(data$x)) {
        binwidth[1] <- 1
      } else {
        binwidth[1] <- diff(range$x) / 30
      }
      if (is.integer(data$y)) {
        binwidth[2] <- 1
      } else {
        binwidth[2] <- diff(range$y) / 30
      }      
    }
    stopifnot(is.numeric(binwidth))
    stopifnot(length(binwidth) == 2)
    
    # Determine breaks, if omitted
    if (is.null(breaks)) {
      if (is.null(origin)) {
        breaks <- list(
          fullseq(range$x, binwidth[1]),
          fullseq(range$y, binwidth[2])
        )
      } else {
        breaks <- list(
          seq(origin[1], max(range$x) + binwidth[1], binwidth[2]),
          seq(origin[2], max(range$y) + binwidth[2], binwidth[2])
        )
      }
    }
    stopifnot(is.list(breaks))
    stopifnot(length(breaks) == 2)
    stopifnot(all(sapply(breaks, is.numeric)))
    names(breaks) <- c("x", "y")
    
    xbin <- cut(data$x, sort(breaks$x), include.lowest=TRUE)
    ybin <- cut(data$y, sort(breaks$y), include.lowest=TRUE)
    
    if (is.null(data$weight)) data$weight <- 1
    
    counts <- as.data.frame(
      xtabs(weight ~ xbin + ybin, data), responseName="count")
    if (drop) counts <- subset(counts, count > 0)
    
    within(counts,{
      xint <- as.numeric(xbin)
      xmin <- breaks$x[xint]
      xmax <- breaks$x[xint + 1]

      yint <- as.numeric(ybin)
      ymin <- breaks$y[yint]
      ymax <- breaks$y[yint + 1]
    })
  }
  

  examples <- function(.) {
  }
  
})
