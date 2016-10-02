import Html exposing (Html, button, div, text, h6)
import Html.App as App
import Html.Attributes exposing (style)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Svg exposing (svg, circle, line, rect, use)
import Svg.Attributes exposing (viewBox, width, x, y, x1, y1, x2, y2, xlinkHref, stroke, transform)

import Model exposing (Model)
import Config exposing (config)

-- Main
main : Program Never
main = App.program
  {
   subscriptions = subscriptions,
   view = view,
   update = update,
   init = init
 }

-- Update

type Msg
  = KeyDown KeyCode
  | KeyUp KeyCode
  | Tick Float

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick intervalLengthMs ->
      (Model.tick {model | intervalLengthMs = intervalLengthMs}, Cmd.none)
    KeyDown code ->
      case code of
        32 -> -- Spacebar
          ({model | paused = not model.paused}, Cmd.none)
        37 -> -- Left
          ({model | leftThruster = True, paused = False}, Cmd.none)
        38 -> -- Up
          ({model | mainEngine = True, paused = False}, Cmd.none)
        39 -> -- Right
          ({model | rightThruster = True, paused = False}, Cmd.none)
        _ ->
          (model, Cmd.none)
    KeyUp code ->
      case code of
        37 ->
          ({model | leftThruster = False}, Cmd.none)
        38 ->
          ({model | mainEngine = False}, Cmd.none)
        39 ->
          ({model | rightThruster = False}, Cmd.none)
        82 ->
          init
        _ ->
          (model, Cmd.none)

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs KeyDown
      , Keyboard.ups KeyUp
      , AnimationFrame.diffs Tick
    ]

-- View

view : Model -> Html Msg
view model =
  let
    divStyle = Html.Attributes.style [("padding", "0px")]
  in
    div [ divStyle ]
      [ gameView model ]

gameView : Model -> Html Msg
gameView model =
  svg [ viewBox "0 0 200 100", width "100%" ]
    [
      line [ x1 "0", y1 "100", x2 "200", y2 "100", stroke "darkgreen" ] []
      , use [
      xlinkHref ("graphics/coin.svg#coin")
      , x (toString model.coin.x)
      , y (100 - config.coin.y - model.coin.y |> toString)
      ] []
      , vehicleView model
      , vehicleView {model | x = model.x - 200}
    ]

vehicleView : Model -> Svg.Svg a
vehicleView model =
  let
    vehicleY = (100 - config.vehicle.y - model.y)
    rotateX = model.x + config.vehicle.x / 2 |> toString
    rotateY = 100 - model.y - config.vehicle.y / 2 |> toString
    vehicleTransform = "rotate(" ++ toString model.theta ++ " " ++ rotateX ++ " " ++ rotateY ++ ")"
    svgId =
      if model.paused then "none"
      else if model.mainEngine && (model.rightThruster || model.leftThruster) then "all"
      else if model.mainEngine then "main"
      else if model.rightThruster || model.leftThruster then "turn"
      else "none"
  in
    use [
      xlinkHref ("graphics/helicopter.svg#" ++ svgId)
      , x (toString model.x)
      , y (toString vehicleY)
      , transform (vehicleTransform)
      ] []

-- Init

init : (Model, Cmd Msg)
init =
  (
    {
      paused = True,
      mainEngine = False,
      rightThruster = False,
      leftThruster = False,
      x = 100,
      y = 0,
      theta = 0,
      dx = 0,
      dy = 0,
      dtheta = 0,
      intervalLengthMs = 0
      , coin =
        { x = 100 + 15
        , y = 0 + 2
        }
    },
    Cmd.none
  )
