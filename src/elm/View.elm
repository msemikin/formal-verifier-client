module View exposing (view)

import Material.Layout as Layout
import Html exposing (..)
import Html.Attributes exposing (href, class, style)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Register.View
import Login.View
import Routing exposing (..)
import List exposing (head)
import Maybe exposing (withDefault)


view : Model -> Html Msg
view model =
  Layout.render Mdl model.mdl
    [ Layout.fixedHeader
    ]
    { header = [ h4 [ class "header" ] [ text "Counter" ] ]
    , drawer = []
    , tabs = ( [], [] )
    , main = [ page model ]
    }

page : Model -> Html Msg
page { history, register } =
  case withDefault RegistrationRoute (head history) of
    RegistrationRoute ->
      Html.map RegisterMsg (Register.View.view register) 
    
    LoginRoute -> Login.View.view

    NotFoundRoute -> notFoundView


notFoundView : Html Msg
notFoundView =
    div []
        [ text "Not found"
        ]