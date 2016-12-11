module View exposing (view)

import Material.Layout as Layout
import Html exposing (..)
import List exposing (head)
import Maybe exposing (withDefault)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Register.View
import Login.View
import Routing exposing (..)
import Header.View
import Profile.View


view : Model -> Html Msg
view model =
  Layout.render Mdl model.mdl
    [ Layout.fixedHeader
    ]
    { header = [ Header.View.view model ]
    , drawer = []
    , tabs = ( [], [] )
    , main = [ page model ]
    }


page : Model -> Html Msg
page { history, register, login, profile } =
  case withDefault RegistrationRoute (head history) of
    RegistrationRoute ->
      Html.map RegisterMsg (Register.View.view register) 
    
    LoginRoute ->
      Html.map LoginMsg (Login.View.view login)
    
    ProfileRoute ->
      Html.map ProfileMsg (Profile.View.view profile)

    NotFoundRoute -> notFoundView


notFoundView : Html Msg
notFoundView =
    div []
        [ text "Not found"
        ]