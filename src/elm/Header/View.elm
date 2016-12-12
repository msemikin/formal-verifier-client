module Header.View exposing (view)

import Debug
import Html exposing (..)
import Material.Button as Button
import Html.Attributes exposing (href, class, style)

import Model exposing (Model)
import Messages exposing (Msg(..))
import Types exposing (Route(..))

view : Model -> Html Msg
view { mdl, user } =
  div [ class "header" ]
    [ h4 [ class "title" ] [ text "Formal verifier" ]
    , div [ class "header-actions" ]
        <| case user of
          Just user ->
            [ Button.render Mdl [0] mdl
              [ Button.onClick (UpdateRoute ProfileRoute) ]
              [ text <| user.firstName ++ " " ++ user.lastName ]
            ]
          Nothing ->
            [ Button.render Mdl [0] mdl
              [ Button.onClick (UpdateRoute LoginRoute) ]
              [ text "Login" ]
            , Button.render Mdl [1] mdl
              [ Button.onClick (UpdateRoute RegisterRoute) ]
              [ text "Register" ]
            ]
    ]
