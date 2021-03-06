#' Create a module
#' 
#' This function creates a module inside the `R/` folder, based 
#' on a specific module structure. 
#' 
#' @param name The name of the module
#' @param pkg Path to the root of the package. Default is `"."`.
#' @note This function will prefix the `name` argument with `mod_`.
#' @export
#' @importFrom glue glue
#' @importFrom cli cat_bullet
#' @importFrom utils file.edit

add_module <- function(name, pkg = "."){
  old <- setwd(normalizePath(pkg))
  on.exit(setwd(old))
  where <- file.path(
    "R", paste0("mod_", name, ".R")
  )
  if (file.exists(where)){
    if (!yesno("File already exists, override?")){
      return(invisible(NULL))
    }
  }
  file.create(where)
  write_there <- function(...){
    write(..., file = where, append = TRUE)
  }
  glue <- function(...){
    glue::glue(..., .open = "%", .close = "%")
  }
  write_there("# Module UI")
  
  write_there(glue("#' @title   mod_%name%ui and mod_%name%"))
  write_there("#' @description  A shiny Module that ...")
  write_there("#'")
  write_there("#' @param id shiny id")
  write_there("#'")
  write_there("#' @export ") 
  write_there("#' @importFrom shiny NS tagList ") 
  write_there("#' @examples ") 
  
  write_there(glue("mod_%name%ui <- function(id){"))
  write_there("  ns <- NS(id)")
  write_there("  tagList(")
  write_there("  ")
  write_there("  )")
  write_there("}")
  write_there("    ")
  
  write_there("# Module server")
  
  write_there(glue("#' mod_%name% server function"))
  write_there("#'")
  write_there("#' @param input internal")
  write_there("#' @param output internal")
  write_there("#' @param session internal")
  write_there("#'")
  write_there("#' @export")
  write_there(glue("#' @rdname mod_%name%ui"))
  write_there("    ")
  
  write_there(glue("mod_%name% <- function(input, output, session){"))
  write_there("  ns <- session$ns")
  write_there("}")
  write_there("    ")

  write_there("## To be copied in the UI")
  write_there(glue('# mod_%name%ui("%name%ui_1")'))
  write_there("    ")
  write_there("## To be copied in the server")
  write_there(glue('# callModule(mod_%name%, "%name%ui_1")'))
  write_there(" ")
  cat_bullet(glue("File created at %where%"), bullet = "tick", bullet_col = "green")
  if (rstudioapi::isAvailable()){
    rstudioapi::navigateToFile(where)
  } else {
    cat_bullet(glue("Go to %where%"), 
               bullet = "square_small_filled", 
               bullet_col = "red")
  }
}

#' Add an app.R at the root of your package to deploy on RStudio Connect
#'
#' @inheritParams add_module
#' @importFrom cli cat_bullet
#' @export
add_rconnect_file <- function(pkg = "."){
  where <- file.path(pkg, "app.R")
  write_there <- function(..., here = where){
    write(..., here, append = TRUE)
  }
  file.create( where )
  usethis::use_build_ignore( where )
  write_there("# To deploy, run: rsconnect::deployApp()")
  write_there("")
  write_there("pkgload::load_all()")
  write_there("options( \"golem.app.prod\" = TRUE)")
  write_there("shiny::shinyApp(ui = app_ui(), server = app_server)")
  usethis::use_build_ignore(where)
  usethis::use_package("pkgload")
  cat_bullet(glue("File created at {where}"), bullet = "tick", bullet_col = "green")
  cat_bullet("To deploy, run:")
  cat(darkgrey("rsconnect::deployApp()\n"))
  
  
  if (rstudioapi::isAvailable()){
    rstudioapi::navigateToFile(where)
  } else {
    cat_bullet(glue::glue("Go to {where}"), 
               bullet = "square_small_filled", 
               bullet_col = "red")
  }
  
}
