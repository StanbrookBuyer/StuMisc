install.packages(c("shiny", "DT","rsconnect"))
library(shiny)
library(DT)
library(rsconnect)

rsconnect::writeManifest()

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #872046; color: black; }
      .btn { background-color: #ffb92a; color: black; border: none; }
      .form-control { background-color: #ffb92a; color: black; }
      .dataTables_wrapper .dataTables_filter input { background-color: #ffb92a; color: white; }
    "))
  ),
  navbarPage("Misconduct Records: College of Science, Engineering, and Math",
             tabPanel("Data Entry",
                      sidebarLayout(
                        sidebarPanel(h3("Student Information"),
                          textInput("student_name", "Student Name"),
                          textInput("student_id", "Student ID"),
                          textInput("course_code", "Course Code"),
                          selectInput("semester", "Semester", choices = c("Spring", "Summer", "Fall")),
                          numericInput("year", "Year", value = 2025, min = 2024, max = 2050),
                          textInput("instructor_name", "Instructor Name"),
                          textAreaInput("misconduct", "Nature of Misconduct", ""),
                          actionButton("submit", "Submit")
                        ),
                        mainPanel(
                          tags$figure(class = "centreFigure",
                          tags$img(src = "logo.png", height = "550px"))
                        )
                      )
             ),
             
             tabPanel("Records",
                      sidebarLayout(
                        sidebarPanel(
                          textInput("search_name", "Search by Student Name"),
                          selectInput("filter_course", "Filter by Course Code", choices = NULL),
                          selectInput("filter_semester", "Filter by Semester", choices = NULL),
                          downloadButton("downloadData", "Download Data")
                        ),
                        mainPanel(
                          DTOutput("data_table")
                        )
                      )
             )
  )
)

# Define Server
server <- function(input, output, session) {
  records <- reactiveVal(data.frame(
    Student_Name = character(),
    Student_ID = character(),
    Course_Code = character(),
    Semester = character(),
    Year = numeric(),
    Instructor_Name = character(),
    Misconduct = character(),
    stringsAsFactors = FALSE
  ))
  
  observeEvent(input$submit, {
    new_record <- data.frame(
      Student_Name = input$student_name,
      Student_ID = input$student_id,
      Course_Code = input$course_code,
      Semester = input$semester,
      Year = input$year,
      Instructor_Name = input$instructor_name,
      Misconduct = input$misconduct,
      stringsAsFactors = FALSE
      )
    
    records(rbind(records(), new_record))
  })
  
  output$data_table <- renderDT({
    datatable(records(), options = list(pageLength = 10))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { "misconduct_records.csv" },
    content = function(file) {
      write.csv(records(), file, row.names = FALSE)
    }
  )
}

# Run App
shinyApp(ui, server)
