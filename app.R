library(shiny)
library(ggplot2)
library(dplyr)
library(shinydashboard)
library(DT)
library(shinyWidgets)
library(plotly)
library(magrittr)
library(scales)
library(tinytex)
library(knitr)


# Load the superstore data
superstore <- read.csv("cleaned.csv", header= TRUE)

# Define the UI
ui <- dashboardPage(
  dashboardHeader(
    title= "Superstore Sales Analysis"
  ),
  
  dashboardSidebar(
    dateRangeInput('dateRange',
                   label = 'Date Range',
                   start = as.Date('2012-01-01'), end = as.Date('2015-12-31')),
    
    selectInput(inputId = "category",
                label = "Select Product Category:",
                choices = unique(superstore$Category))
    
  ),
  
  dashboardBody(
    fluidRow(
      valueBoxOutput("RetailSales"),
      valueBoxOutput("ProfitMargin"),
      valueBoxOutput("CustomersVisited")
    ),
    
    fluidRow(
      box(
        title = "Sales & Profit by Category", background = "maroon", solidHeader = TRUE, width = 12, collapsible = TRUE, collapsed = FALSE, plotlyOutput("CategorySalesPlot", height = 200)
      )
    ),
    
    fluidRow(
      box(
        title = "Sales by Sub-Category", background = "navy", solidHeader = TRUE, width = 12, collapsible = TRUE, collapsed = TRUE, plotlyOutput("SubSales")
      )
    ),
    
    fluidRow(
      box(
        title = "State-wise Shipping Cost", background = "fuchsia", solidHeader = TRUE, width = 12, collapsible = TRUE, collapsed = TRUE, plotlyOutput("StateShippingCost")
      )
    ),
    
    
  ) #dashboardBody
) # dashboardPage

# Define the server
server <- function(input, output) {
  # Filter the data based on user inputs
  
  # Sales
  output$RetailSales <- renderValueBox({
    deliveredToDate <- superstore %>%
      filter(OrderDate <= input$dateRange[2] & OrderDate >= input$dateRange[1])
    
    valueBox(
      paste0("$", prettyNum(ceiling(sum(deliveredToDate$Sales)), big.mark = ",")),
      "Total Retail Sales",
      color = "teal",
      icon = icon("dollar-sign")
    )
  }) # Sales
  
  #Profit
  output$ProfitMargin <- renderValueBox({
    deliveredToDate <- superstore %>%
      filter(OrderDate <= input$dateRange[2] & OrderDate >= input$dateRange[1])
    
    valueBox(
      paste0("$", prettyNum(ceiling(sum(deliveredToDate$Profit)), big.mark = ",")),
      "Profit Margin",
      color = "fuchsia",
      icon = icon("dollar-sign")
    )
  }) # Profit
  
  # Total Customers Visited
  output$CustomersVisited <- renderValueBox({
    UserToDate <- superstore %>%
      filter(OrderDate <= input$dateRange[2] & OrderDate >= (input$dateRange[2] - 30))
    valueBox(
      prettyNum(length(unique(UserToDate$OrderID)),big.mark = ","),
      "Customers",
      color = "light-blue",
      icon = icon("user-alt")
    )
  }) # Total Customers Visited
  
  # Sales & Profit by Category
  output$CategorySalesPlot <- renderPlotly({
    dailyRetail <- superstore %>% 
      filter(OrderDate <=input$dateRange[2] & OrderDate >= (input$dateRange[2] - 30) &
      Category %in% input$category)
    
    cateSal <- ggplot(dailyRetail, aes(x = Sales, y = Profit)) + geom_point(color= 'blue', alpha= .6, na.rm= TRUE) + labs(x = "Sales", y = "Profit") + ggtitle("Sales vs Profit in Category")
    ggplotly(cateSal)
  }) # Sales & Profit by Category
  
  # Sales by Sub-Category
  output$SubSales <- renderPlotly({
    dailyRetail <- superstore %>% 
      filter(OrderDate <=input$dateRange[2] & OrderDate >= (input$dateRange[2] - 30) &
      Category %in% input$category)
    
    SubSale <- ggplot(dailyRetail, aes(x= factor(Sub.Category), y= Sales)) + geom_boxplot(aes(fill= factor(Sub.Category)))
    ggplotly(SubSale)
  }) # Sales by Sub-Category
  
  #State-wise Shipping Cost
  output$StateShippingCost <- renderPlotly({
    dailyRetail <-superstore %>% 
      filter(OrderDate <=input$dateRange[2] & OrderDate >= (input$dateRange[2] - 30) & 
      Category %in% input$category)
    
    ShipState <- ggplot(dailyRetail, aes(x= State, y= ShippingCost)) + geom_violin(alpha= .6) + labs(x= 'State', y= 'Shipping Cost') + ggtitle("State-wise Shipping Cost")
    ggplotly(ShipState)
  })
} # end

# Run the Shiny app
shinyApp(ui = ui, server = server)
