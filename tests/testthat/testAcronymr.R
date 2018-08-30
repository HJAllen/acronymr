context("acronym output")
library(acronymr)

# Test acronyms frame
{
  acronyms <-
    # Create acronyms lookup table
    tibble::tribble(
      ~Acronym, ~Alternate, ~Definition,
      "GMO", NA, "Genetically Modified Organism",
      "IMO", NA,"In My Opinion",
      "PCR", NA, "Polymerase Chain Reaction",
      "DNA", NA, "Deoxyribonucleic Acid",
      "H2NO3", "H~2~NO~3~", "Nitric Acid")
  # Add inclusion flag
  acronyms$Include <- FALSE
  # Alphabetize acronyms for ease of reading
  acronyms <- acronyms[order(acronyms$Acronym),]
}

test_that("ac finds GMO", {
  expect_equal(ac("GMO"), "Genetically Modified Organism (GMO)")
  expect_equal(acronyms$Include[acronyms$Acronym == "GMO"], TRUE)
  expect_equal(nrow(acTable("acronyms")), 1)
  expect_equal(ncol(acTable("acronyms")), 2)
  expect_equal(acTable("acronyms")$Acronym, "GMO")
  expect_equal(ac("GMO", lngFrm = TRUE), "Genetically Modified Organism")
})

test_that("altFrm is returned", {
  expect_equal(ac("H2NO3", altFrm = TRUE), "Nitric Acid (H~2~NO~3~)")
  expect_equal(acronyms$Include[acronyms$Acronym == "H2NO3"], TRUE)
  expect_equal(nrow(acTable("acronyms")), 1)
  expect_equal(ncol(acTable("acronyms")), 2)
  expect_equal(any(grepl("H~2~NO~3~", acTable("acronyms", altFrm = TRUE))), TRUE)
})
