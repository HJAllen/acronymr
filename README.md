
<!-- README.md is generated from README.Rmd. Please edit that file -->

# acronymr

acronymr is an R package to facilitate the use of acronyms in rmarkdown
documents. Acronyms and their definitions are stored in a data frame
which are then referenced inline to place the formatted acronym in the
rendered document. Initial use of an acronym will define the acronym
while subsequent use will just place the acronym. Options are available
to use the plural form, an alternate form which may include special
formatting such as italics or super and subscripts, or the definition.

acronymr tracks which acronyms are used and provides a function to
return a data frame of used acronyms suitable for output in a table.

## Installation

You can install acronymr from github with:

``` r
# install.packages("devtools")
devtools::install_github("HJAllen/acronymr")
```

## Example

A data frame with acronyms and definitions provided by the user:

``` r
library(acronymr)

acronyms <-
  # Create acronyms lookup table
  tibble::tribble(
    ~Acronym, ~Alternate, ~Definition,
    "GMO", NA, "Genetically Modified Organism",
    'IMO', NA,'In My Opinion',
    'PCR', NA, 'Polymerase Chain Reaction',
    'DNA', NA, 'Deoxyribonucleic Acid',
    'H2NO3', 'H~2~NO~3~', 'Nitric Acid')
# Add inclusion flag
acronyms$Include <- FALSE
# Alphabetize acronyms for ease of reading
acronyms <- acronyms[order(acronyms$Acronym),]

acronyms
#> # A tibble: 5 x 4
#>   Acronym Alternate Definition                    Include
#>   <chr>   <chr>     <chr>                         <lgl>  
#> 1 DNA     <NA>      Deoxyribonucleic Acid         FALSE  
#> 2 GMO     <NA>      Genetically Modified Organism FALSE  
#> 3 H2NO3   H~2~NO~3~ Nitric Acid                   FALSE  
#> 4 IMO     <NA>      In My Opinion                 FALSE  
#> 5 PCR     <NA>      Polymerase Chain Reaction     FALSE
```

The function `ac` will insert the formatted acronym. When an acronym is
used, if `acronyms$Include` is set to `FALSE` indicating first usage,
the return value is the long form of the acronym followed by either the
acronym name or alternate form depending on `altFrm`. Plural forms can
be generated using the parameter `p`. Subsequent uses of the acronym
will return the acronym formatted as requested.

The following:

The `` `r ac("DNA")` `` of a `` `r ac("GMO")` `` has been modified.
`` `r ac("PCR")` `` can be used to characterize `` `r ac("DNA")` `` in
`` `r ac("GMO", p = TRUE)` ``. Be careful to avoid introduction of `` `r
ac("H2NO3", altFrm = TRUE)` ``.

Produces:

The Deoxyribonucleic Acid (DNA) of a Genetically Modified Organism (GMO)
has been modified. Polymerase Chain Reaction (PCR) can be used to
characterize DNA in GMOs. Be careful to avoid introduction of Nitric
Acid (H<sub>2</sub>NO<sub>3</sub>).

There are instances when the long form of the acronym is needed such as
section headings: `` `r ac("GMO", lngFrm = TRUE)` ``.

## Genetically Modified Organism

When an acronym is used, `acronyms$Include` is updated to `TRUE` and a
data frame containing used acronyms suitable for table generation is
returned by `acTable`:

``` r
acTable("acronyms", altFrm = TRUE)
#> # A tibble: 4 x 2
#>   Acronym   Definition                   
#>   <chr>     <chr>                        
#> 1 DNA       Deoxyribonucleic Acid        
#> 2 GMO       Genetically Modified Organism
#> 3 H~2~NO~3~ Nitric Acid                  
#> 4 PCR       Polymerase Chain Reaction

knitr::kable(acTable("acronyms", altFrm = TRUE),
             caption = "*Table 1.* Acronyms Used.")
```

| Acronym                     | Definition                    |
| :-------------------------- | :---------------------------- |
| DNA                         | Deoxyribonucleic Acid         |
| GMO                         | Genetically Modified Organism |
| H<sub>2</sub>NO<sub>3</sub> | Nitric Acid                   |
| PCR                         | Polymerase Chain Reaction     |

*Table 1.* Acronyms Used.
