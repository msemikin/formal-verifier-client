module Header.View exposing (view)

import Debug
import Html exposing (..)
import Material.Button as Button
import Html.Attributes exposing (href, class, style)

import Model exposing (Model)
import Messages exposing (Msg(..))

view : Model -> Html Msg
view { mdl, user } =
  div [ class "header" ]
    [ h4 [ class "title" ] [ text "Formal verifier" ]
    , div [ class "header-actions" ]
        <| case user of
          Just user ->
            [ a [href "/#/profile"]
                [ Button.render Mdl [0] mdl []
                    [ text <| user.firstName ++ " " ++ user.lastName ]
                ]
            ]
          Nothing ->
            [ a [href "/#/login"]
                [ Button.render Mdl [0] mdl []
                    [ text "Login" ]
                ]
            , a [href "/#/register"]
                [ Button.render Mdl [1] mdl []
                    [ text "Register" ]
                ]
            ]
    ]
