library(shiny)
library(shinyBS)
library(shinyjs)
library(shinydashboard)

body = dashboardBody(
  useShinyjs(),
  inlineCSS(list(.opacity = "opacity: 0.5; pointer-events: none")),
  fluidRow(
    column(8, offset = 2, {
      div(id = "formTypeBox", 
          box(
            title = "1. Select Form Type",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            helpText("Please select the form type you are scanning."),
            selectInput("formType", label = NULL,
                        c("Please Select a Form Type", 
                          "Hybrid" = "hybrid", 
                          "Numeric" = "numeric", 
                          "Multiple Choice" = "multi"))
          ))
    })
  ), 
  fluidRow(
    column(8, offset = 2, {
      div(id = "uploadBox",
          box(
            title = "2. Upload Forms",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            helpText("Please upload the forms as one multi-page PDF or a zip file containing JPEG images."),
            fileInput("fileUpload", label = NULL, 
                      accept = c(
                        "application/pdf",
                        "application/zip",
                        ".pdf",
                        ".zip"
                      )),
            uiOutput("processResult")
          ))
      
    })
  ), 
  fluidRow(
    column(8, offset = 2, {
      div(id = "downloadBox",
          box(
            title = "3. Download Result",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            helpText("Download the result as an Excel file, a CSV file, or download a ZIP file containing seperate images of every form."),
            downloadButton("downloadFile", "Download Excel File"),
            downloadButton("downloadCSV", "Download CSV"),
            downloadButton("downloadImages", "Download Images")
          ))
      
    })
  ),
  fluidRow(
    column(8, offset = 2, align = "center", 
           actionButton("reset", "Reset", width = "10%", 
                        icon("refresh"), style = "color: #fff; background-color: #64090F; border-color: #64090F"))
  ),
  # Styling look
  tags$head(tags$style(HTML('
                            .main-header .logo {
                                                font-family: "Georgia", Times, "Times New Roman", serif;
                                                font-weight: bold;
                                                font-size: 35px;
                                                text-align: left;
                            }
                            .skin-blue .main-header .logo {background-color: #64090F;}
                            .skin-blue .main-header .logo:hover {background-color: #64090F;}
                            .skin-blue .main-header .navbar {background-color: #64090F;}
                            .skin-blue .main-sidebar {background-color: #64090F;}
                            .box.box-solid.box-primary>.box-header {color: #fff; background: #64090F;}
                            .box.box-solid.box-primary {
                                                          border-bottom-color: #64090F;
                                                          border-left-color: #64090F;
                                                          border-right-color: #64090F;
                                                          border-top-color: #64090F;
                                                          }')))
)

#Ugly hack to get links into the header
header = dashboardHeader(title = "RHScan",
  tags$li(class = "dropdown",
          tags$a("About", target="_blank", href = "http://www.sphericalcows.net/RHScan/about-rhscan.html")),
  tags$li(class = "dropdown",
          tags$a("Download Forms", target="_blank", href = "http://www.sphericalcows.net/RHScan/download-files.html")),
  tags$li(class = "dropdown",
          tags$a("FAQs", target="_blank", href = "https://google.com")),
  tags$li(class = "dropdown",
          tags$a("Documentation", target="_blank", href = "https://google.com"))
)
dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)
