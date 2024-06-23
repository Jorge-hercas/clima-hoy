



fluidPage(
  tags$head(tags$link(href = "https://fonts.googleapis.com/css?family=Oswald", rel = "stylesheet")),
  shinybusy::add_busy_spinner(position = "top-right", 
                              spin = "self-building-square", 
                              color = "darkred"),
  setBackgroundColor(
    color = "#2B2B2B",
    gradient = "radial"
  ),
  column(
    width = 3,
    align = "center",
    globeOutput("globo",
                width = 250, 
                height = 250),
    h1("El clima en tu ciudad",style="color:#ebb52d"),
    hr(),
    autocomplete_textOutput(label = " ", inputId = "direction", key = key,
                            use_shinywidgets = T, icon = icon("globe"), 
                            placeholder = "Ingresa tu ubicación"),
    column(width = 6, tags$style("label{color: #ebb52d;}"),numericInput("lat", "Latitud", value = 0)),
    column(width = 6, numericInput("lng", "Longitud", value = 0)),
    column(width = 12, actionButton("temp_find", "Ver clima", icon = icon("magnifying-glass"))),
    br(),br(),br(),br(),br(),br(),
    
    column(width = 12,
           align = "center",
           h4(textOutput("temperatura_actual"),style="color:#ebb52d"),
           reactableOutput("tabla_temperaturas"))
  ),
  column(
    width = 9,
    mapboxerOutput("map", height = "1000px", width = "1300px")
  ),
  absolutePanel(
    top = 10, right = 10, style = "z-index:500; text-align: right;",
    echarts4rOutput("grafico_temperatura", height = 250, width = 400)
  )
)

