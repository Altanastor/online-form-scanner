library(shiny)
library(shinyBS)
library(shinyjs)
library(shinydashboard)
library(xlsx)
#library(openxlsx)

shinyServer(function(input, output, session) {
  
  options(shiny.maxRequestSize = 100*1024^2)
  
  downloadInputs = c("downloadFile", "downloadCSV", "downloadImages")
  
  for (name in downloadInputs) {
    shinyjs::disable(name)
  }
  
  tempDirectory = paste0(tempdir(), "/", format(Sys.time(), "%Y%m%d%H%M%S"), sample(0:100, 1))
  
  shinyjs::addClass("uploadBox", "opacity")
  shinyjs::addClass("downloadBox", "opacity")
  
  observe({
    if (input$formType != "Please Select a Form Type") {
      shinyjs::addClass("formTypeBox", "opacity")
      shinyjs::removeClass("uploadBox", "opacity")
    }
  })
  
  shinyjs::hide("processResult")
  
  output$processResult = renderUI({
    helpText(icon("spinner", "fa-spin"), "Scanning forms...")
  })
  
  formType = function() {
    switch(input$formType,
           "hybrid" = return("/home/shiny/formscanner/Hybrid_v3.2.xtmpl"),
           "numeric" = return("/home/shiny/formscanner/Numeric_v3.2.xtmpl"),
           "multi" = return("/home/shiny/formscanner/MC6_75_v3.2.xtmpl"))
  }
  
  excelType = function() {
    switch(input$formType,
           "hybrid" = return("ResultsHybridv3.2.xlsm"),
           "numeric" = return("ResultsNumericv3.2.xlsm"),
           "multi" = return("ResultsMCv3.2.xlsm"))
  }
  
  
  # TODO: Change indicator depending on step of process.
  observeEvent(input$fileUpload, {
    
    #print(formType())
    
    shinyjs::show("processResult")
    
    # rv$fileState = "uploaded"
    
    if(dir.exists(tempDirectory)) {
      shinyjs::disable("downloadFile")
      unlink(tempDirectory, recursive = TRUE)
    }
    
    print(tempDirectory)
    
    inputFile = input$fileUpload
    dir.create(tempDirectory)
    setwd(tempDirectory)
    dir.create("images")
    if (tools::file_ext(input$fileUpload$name) == "pdf") {
      file.copy(inputFile$datapath, "forms.pdf")
      system("nconvert -xall -dpi 300 -out jpeg -o 'images/%.jpeg' forms.pdf")
    } else {
      unzip(inputFile$datapath, exdir = "images")
    }
    system(paste("/bin/bash formscanner", formType(), "images"))
    system("mv images/*.csv result.tmp")
    system("java -jar /home/shiny/formscanner/ProcessCSV2.jar result.tmp results.csv")
    system(paste0("cp /home/shiny/formscanner/", excelType(), " ."))
    
    data = read.csv("results.csv")
    excelForm = loadWorkbook(excelType())
    sheets = getSheets(excelForm)
    addDataFrame(data, sheets[[1]], col.names = FALSE, row.names = FALSE, startRow=2, colStyle = NULL)
    saveWorkbook(excelForm, "results.xlsm")
    
    # data = read.csv("results.csv")
    # excelForm = loadWorkbook(excelType())
    # writeData(excelForm, "Scan", data, colNames = FALSE, rowNames = FALSE, startRow = 2)
    # saveWorkbook(excelForm, "results.xlsm")
    
    # output$processResult = renderUI({
    #   helpText(icon("check"), "Scanning Done!")
    # })
    
    # rv$fileState = "processed"
    
    output$processResult = renderUI({
      helpText(icon("check"), "Scanning Done!")
    })
    
    shinyjs::show("processResult")
    
    for (name in downloadInputs) {
      shinyjs::enable(name)
    }
    
    shinyjs::addClass("uploadBox", "opacity")
    shinyjs::removeClass("downloadBox", "opacity")
    # shinyjs::show("downloadBox", anim = TRUE)
    # shinyjs::hide("uploadBox", anim = TRUE)
    
  })
  
  observeEvent(input$reset, {
    shinyjs::runjs("location.reload(true);")
  })
  
  output$downloadFile = downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$fileUpload$name), ".xlsm")
    },

    content = function(file) {
      file.copy("results.xlsm", file)
    }
  )
  
  output$downloadCSV = downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$fileUpload$name), ".csv")
    },
    
    content = function(file) {
      file.copy("results.csv", file)
    }
  )
  
  output$downloadImages = downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$fileUpload$name), ".zip")
    },
    
    content = function(file) {
      system("zip files.zip images/*.jpeg")
      file.copy("files.zip", file)
    }
  )
  
  session$onSessionEnded(function() {
    unlink(tempDirectory, recursive = TRUE)
  })
})
