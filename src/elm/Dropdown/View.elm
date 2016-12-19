module Dropdown.View exposing (..)

import Html exposing (..)
import Material.Options as Options exposing (cs, css)
import Material.Textfield as Textfield
import Material.Icon as Icon
import Material.Menu as Menu

import Types exposing (..)
import Dropdown.Types exposing (..)

view : List LTS -> Maybe LTS -> Model -> Html DropdownMsg
view options value { mdl } =
  let 
    checkmark id =  
      case value of
        Just lts ->
          if id == lts.id then 
            Icon.view "check" [ css "width" "40px" ]
          else 
            Options.span [ css "width" "40px" ] [] 
        _ -> Options.span [ css "width" "40px" ] [] 
  in
    div []
    [ Textfield.render Mdl [0] mdl
      [ Textfield.label ""
      , Textfield.disabled
      , Textfield.value <|
          case value of
            Just lts -> lts.name
            _ -> "Select Model"
      ]
    , Menu.render Mdl [0] mdl 
        [ Menu.ripple, Menu.bottomLeft ]
        ( List.map (\{ id, name } ->
              Menu.item
                [ Menu.onSelect (DropdownSelect id) ] 
                [ checkmark id, text name ]
            )
            options
        )
    ]