

function(input, output, session){
  
  output$globo <- render_globe({
    
    create_globe(height = "100vh") |> 
      globe_background(color = "#2B2B2B") |> 
      globe_img_url(image_url("blue-marble")) |> 
      globe_pov(
        altitude = 2.3,
        0.6345,
        -80.5528
      )
    
    
  })
  
  observeEvent(input$temp_find, {
    globe_proxy("globo") |> 
      globe_pov(
        altitude = 2.3,
        input$lat,
        input$lng
      ) 
  })
  
  
  output$map <- renderMapboxer({
    
    mapboxer(
      style = "mapbox://styles/mapbox/dark-v11",
      token = "pk.eyJ1Ijoiam9yZ2VoZGV6MTk5OCIsImEiOiJja2o2dnNyeWUzOGx2MzJteTA1cGp3eHdqIn0.2tlIRcZ5xTzSRR0Pj57G2w",
      center = c(-99,22),
      zoom = 4.5,
      maxZoom = 9
    ) 
    
    
  })
  
  
  coordenadas <- reactive({
    
    dir <- geocode(location = input$direction)
    dir
  })
  
  observeEvent(input$direction,{
    
    req(coordenadas())
    
    updateNumericInput(session, "lat", value = coordenadas()$lat)
    updateNumericInput(session, "lng", value = coordenadas()$lon)
    
  })
  
  
  temperaturas_data <- reactive({
    
    solicitud <- weather_forecast_req(lat = input$lat, lon = input$lng, tibble_format = T)
    
    x <- 
      tibble(
        solicitud$dt, solicitud$main$temp,
        solicitud$main$temp_min,
        solicitud$main$temp_max,
        solicitud |> 
          select(weather) |> 
          tidyr::unnest() |> 
          select(icon)) |> 
      setNames(c("Datetime", "Temp", "Min", "Max", "Icon")) |> 
      mutate(
        Icon = paste0(
          "http://openweathermap.org/img/w/",Icon,".png"
        ),
        Datetime = strftime(Datetime, format = "%A, %I %p"),
        Min = Min -273.15,
        Max = Max -273.15,
        Temp = Temp -273.15,
      )
    
    x
    
  })
  
  output$tabla_temperaturas <- renderReactable({
    
    req(temperaturas_data())
    
    temperaturas_data() |> 
      reactable(
        theme = reactablefmtr::nytimes(centered = TRUE, 
                                       header_font_size = 12,
                                       font_color = "#fff",
                                       background_color = "transparent"),
        defaultColDef = colDef(headerStyle = list(background = "#2B2B2B", 
                                                  color = "#fff"),
                               vAlign = "center"),
        compact = TRUE,
        language = reactableLang(
          noData = "No data found",
          pageInfo = "{rowStart}\u2013{rowEnd} of {rows} pages",
          pagePrevious = "\u276e",
          pageNext = "\u276f",
        ),
        bordered = F,
        onClick = "select",
        #selection = "single",
        pagination = F,
        height = 390,
        columns = list(
          Datetime = colDef(name = "Dia/hora",minWidth = 60),
          Icon = colDef(
            minWidth = 25,
            header = icon("cloud-sun"),
            cell = function(value) {
              image <- img(src = value, style = "height: 24px;", alt = value)
              tagList(
                div(style = "display: inline-block; width: 45px;", image)
              )
            }
          ),
          Temp = colDef(
            minWidth = 60,
            header = icon("temperature-low"),
            cell = function(value, index){
              Min <- temperaturas_data()$Min[index]
              Max <- temperaturas_data()$Max[index]
              div(
                div(style = "font-weight: 600", value, "°"),
                div(style = "font-size: 0.75rem", paste0("Min: ",Min,"°, Max: ", Max,"°"))
              )
            }
          ),
          Min = colDef(show = F),
          Max = colDef(show = F)
        )
      )
    
    
  }) |> 
    bindEvent(input$temp_find)
  
  output$temperatura_actual <- renderText({
    
    x <- weather_actual_req(lat = input$lat, lon = input$lng, tibble_format = T)
    
    paste0("Temperatura actual: ", x$main.temp-273.15,"°")
    
  }) |> 
    bindEvent(input$temp_find)
  
  
  output$grafico_temperatura <- renderEcharts4r({
    
    req(temperaturas_data())
    
    x <- temperaturas_data()
    
    temperaturas_data() |> 
      e_charts(Datetime) |> 
      e_bar(Temp, symbol = "none", smooth = F, 
             name = "Temperatura") |> 
      e_theme("auritus") |> 
      e_color(color = "darkred") |> 
      e_tooltip(trigger = "axis") |> 
      e_y_axis(show = F) |> 
      e_title(" ", left = "center") |> 
      e_legend(right = 0, textStyle = list(color = "#fff"))
    
  }) |> 
    bindEvent(input$temp_find)
  
  bounds <- reactive({
    
    x <- c(input$lng,input$lat, input$lng+0.1, input$lat+0.1)
    
    x
    
  })
  
  
  
  observeEvent(input$temp_find,{
    
    req(bounds())
    
    mapboxer_proxy("map") |>
      fit_bounds(bounds()) |>
      update_mapboxer()
    
  })
  
}