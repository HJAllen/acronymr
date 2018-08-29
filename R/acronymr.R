#' Acronym handling function
#'
#' \code{ac} formats acronyms when called inline in rmarkdown.
#'
#' \code{ac} handles inline acronyms and references a dataframe with the acronym name, alternate formatting, definition and include flag and returns a character string. Options include whether the acronym usage is singular or plural and whether the full definition should be used. The function handles missing acronyms, checks for first time usage, and formats the return accordingly. This function is most commonly used in rmarkdown documents.
#'
#' The \code{acronyms} data frame must contain the following columns:
#' \itemize{
#'   \item{Acronym = (character) name of acronym}
#'   \item{Alternate = (character) alternate formatting for use when the acronym uses special characters or other formatting such as super/subscripts, italics, etc.}
#'   \item{Definition = (character) long form of acronym}
#'   \item{Include = (logical) flag indicating if the acronym has been used in the document and must be reset to FALSE at the beginning of each render}
#' }
#' @return
#' When an acronym is used, the \code{acronym} entry is found in \code{acronmys} and if Include is set to \code{FALSE} indicating first usage, the return value is the long form of the acronym followed by either the acronym name or alternate form depending on \code{altFrm} enclosed in parentheses. \code{acronyms$Include} is set to \code{TRUE}. Subsequent usage of an acronym will return the acronym name or alternate form.
#'
#' If \code{acronyms} is not found or if \code{acronyms} exists but is not a data frame or does not include the necessary columns, the function stops and issues an error. If the acronym is not found in \code{acronyms} a warning is issued and XXXacro:Acronym Not DefinedXXX is returned.
#'
#' @param acronym character string matching value in Acronym column of \code{acronyms}
#' @param acronyms character string containing name of acronym data frame
#' @param p logical indicating if the acronym is plural
#' @param altFrm logical indicating if alternate form of acronym should be used
#' @param lngFrm logical indicating if long form of acronym should be used
#' @examples
#' # Example acronyms data frame
#' acronyms <-
#'   tibble::tribble(
#'     ~Acronym, ~Alternate, ~Definition,
#'     "IMO", NA,"In My Opinion",
#'     "PCR", NA, "Polymerase Chain Reaction",
#'     "RNA", NA, "Ribonucleic Acid",
#'     "H2NO3", "H~2~NO~3~", "Nitric Acid")
#'
#' # Add inclusion flag
#' acronyms$Include <- FALSE
#' # Alphabetize acronyms for ease of reading
#' acronyms <- acronyms[order(acronyms$Acronym),]
#'
#' # inline usage
#' `r ac(acronym = "IMO", acronyms = "acronyms", p = FALSE, altFrm = FALSE, lngFrm = FALSE)`
#' # or simply
#' ` ac("IMO")`
#' @export
ac <- function(acronym = NULL, # Reference name of the acronym
               acronyms = "acronyms", # dataframe containing acronyms
               p = FALSE, # Is usage plural?
               altFrm = FALSE, # Return alternate form?
               lngFrm = FALSE) # Return full definition?
{
  # check if acronyms exists
  if(!exists(acronyms)){
    stop(paste("Acronyms data frame", acronyms, "not found"))
  }else acronyms_ <- get(acronyms, envir = parent.frame())

  # Check if acronyms_ is a data frame
  if(!is.data.frame(acronyms_)){
    stop(paste(acronyms, "is not a data frame"))
  }

  # Check if acronyms_ dataframe has correct columns
  acronyms_cols <- c("Acronym", "Alternate", "Definition", "Include")
  if(!all(acronyms_cols %in% names(acronyms_))){
    stop(paste("acronym data frame found but missing columns:",
                 paste(names(acronyms_cols)[!acronyms_cols %in% colnames(acronyms_)],
                       collapse = ", "), "."))
  }

  # Check if acro exists in acronyms_ data frame
  # if not found insert attention text and issue warning
  if (!any(acronym %in% acronyms_$Acronym)){
    warning(paste0("XXX", acronym,":Acronym Not Defined XXX"))
    return(paste0("XXX", acronym,":Acronym Not Defined XXX"))
  }

  # set row of acro
  acronyms_row <- which(acronyms_$Acronym == acronym)

  # if first usage return long form and (Acronym)
  if(!acronyms_$Include[acronyms_row]){
    # set Include flag to TRUE in acronyms_ definition dataframe and update acronyms
    acronyms_$Include[acronyms_row] <- TRUE
    assign(as.character(acronyms), acronyms_, envir = parent.frame())
    # Return string
    return(paste0(acronyms_[acronyms_row, "Definition"],
                  " (", acronyms_[acronyms_row, ifelse(altFrm, "Alternate", "Acronym")], ")"))
  }

  # Format return for acronym already used
  # determine if alternate formatting is to be used
  if (altFrm == TRUE){
    # Make sure Alternate is not NA
    if(!is.na(acronyms_[acronyms_row, "Alternate"])){
      acronyms_col <- which(colnames(acronyms_) == "Alternate")
    }else{
      warning("Alternate Form requested but not found. Using Acronym.")
      acronyms_col <- which(colnames(acronyms_) == "Acronym")
    }
  }else acronyms_col <- which(colnames(acronyms_) == "Acronym")

  # Return acronym from appropriate column
  # if plural is True make plural by adding s
  if(p){
    return(paste0(acronyms_[acronyms_row, acronyms_col], "s"))
  } else return(as.character(acronyms_[acronyms_row, acronyms_col]))
}

#' Return acronyms used dataframe
#'
#' Create an acronym table of acronyms used and insert into text.
#'
#' \code{acTable} is most often used within a knitted document. The function checks if an \code{acronyms} exists and whether any acronyms were used in the document. If both criteria are true, a dataframe containing the acronym and definition of all acronyms used in the document is returned.
#' @return
#' If acronyms are used in the document, a dataframe. If \code{acronyms} does not exist or no acronyms were used in the document, a message is raised and returns \code{NULL}.
#' @param acronyms name of acronym data frame as character string
#' @param altFrm logical indicating whether to use alternate form where available
#' @param Caption acronmy table caption
#' @examples
#' # This example assumes use within an rmarkdown documnet
#' acronyms <-
#'   tibble::tribble(
#'     ~Acronym, ~Alternate, ~Definition,
#'     "IMO", NA,"In My Opinion",
#'     "PCR", NA, "Polymerase Chain Reaction",
#'     "RNA", NA, "Ribonucleic Acid",
#'     "H2NO3", "H~2~NO~3~", "Nitric Acid")
#'
#' # Add inclusion flag
#' acronyms$Include <- FALSE
#' # Alphabetize acronyms for ease of reading
#' acronyms <- acronyms[order(acronyms$Acronym),]
#'
#' # place an acronym inline
#' `r ac("IMO")`
#'
#' # generate acronym table
#' acTable("acronyms")
#' @export
acTable <- function(acronyms = "acronyms",
                     altFrm = FALSE,
                     Caption = NULL,
                     Tag = FALSE){
  # Check if acronyms exists
  if(!exists(acronyms)){
    message(paste("Acronyms data frame", acronyms, "not found."))
    return()
  }else{
    # get acronyms data frame
    acronyms_ <- get(acronyms, envir = parent.frame())
  }

  # Check if any acronyms were used
  if(!any(acronyms_$Include)){
    message("No acronyms used: skipping acronym dataframe generation\n")
    return(NULL)
  } else {
    # Modify acronyms and ouput table
    # If altFrm, use Alternate form where available
    if(altFrm){
      acronyms_$Acronym[!is.na(acronyms_$Alternate)] <-
        acronyms_$Alternate[!is.na(acronyms_$Alternate)]
    }
    return(acronyms_[acronyms_$Include, c("Acronym", "Definition")])
  }
}
