#' Retrieve specified data files from CARDAT data storage in CloudStor via cloudstoR
#' 
#' Data files are downloaded to the specified directory with a mirrored directory structure, via the cloudstoR package.
#'
#' @param paths A vector of Cloudstor file paths to retrieve.
#' @param outdir The directory in which to mirror the CARDAT directory structure.
#' @param force_download A boolean. If TRUE, downloads and overwrites existing files, otherwise skips if exists.
#'
#' @return Returns vector of local file paths mirrored from CARDAT data storage on CloudStor.
#' 
#' @examples
#' download_cardat(
#'   "Environment_General/Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201001_201012-RH35-NoNegs_AUS_20180618.tif",
#'   "~/CARDAT"
#' )

download_cardat <- function(paths, outdir, force_download = FALSE){
  # check if outdir exists, create if not
  if (!dir.exists(outdir)) dir.create(outdir)
  
  ## loop over paths
  outs <- sapply(paths, function(p) {
    
    ## if the file does not already in the outdir, or force_download is set to TRUE, get from CloudStor
    if (!file.exists(file.path(outdir, p)) | force_download) {
      # mirror folder structure
      if (!dir.exists(file.path(outdir, dirname(p)))) {
        dir.create(file.path(outdir, dirname(p)),
                   recursive = TRUE)
      }
      # retrieve data
      message(paste("Downloading", basename(p)))
      outpath <- cloudstoR::cloud_get(
        file.path("Shared", p),
        dest = file.path(outdir, p),
        open_file = FALSE
      )
      message("Download complete")
    } else {
      
      ## otherwise return the existing file path
      outpath <- file.path(outdir, p)
      message(paste("Data file already exists at", file.path(outdir, p)), stdout())
    }
    
    # return the file path
    outpath
  })
  names(outs) <- names(paths)
  outs
}

# download_cardat(
#   "Environment_General/NPI/NPI_2010_2013/data_provided/emissions.csv",
#   "~/CARDAT"
# )
