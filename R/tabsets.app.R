# Load the shiny package
library(shiny)

# Define the UI
ui <- fluidPage(
  # Add a title
  titlePanel("R Shiny Code Example"),
  
  # Add two tabsets with different names and contents
  tabsetPanel(
    tabPanel("Risk", 
             # Add some text and a plot
             h3("This is the risk tab"),
             plotOutput("risk_plot")
    ),
    tabPanel("P&L", 
             # Add some text and a table
             h3("This is the P&L tab"),
             tableOutput("pl_table")
    )
  )
)

# Define the server logic
server <- function(input, output) {
  
  # Generate some random data for the risk plot
  output$risk_plot <- renderPlot({
    x <- rnorm(100)
    y <- rnorm(100)
    plot(x, y, main = "Risk Plot")
  })
  
  # Generate some random data for the P&L table
  output$pl_table <- renderTable({
    df <- data.frame(
      Product = c("A", "B", "C"),
      Profit = runif(3, min = -1000, max = 1000),
      Loss = runif(3, min = -1000, max = 1000)
    )
    df
  })
}

# Run the app
shinyApp(ui = ui, server = server)
