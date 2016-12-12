module View exposing (view)

import Material.Layout as Layout
import Html exposing (..)
import List exposing (head)
import Maybe exposing (withDefault)

import Messages exposing (Msg(..))
import Model exposing (Model, PageData(..))
import Register.View
import Login.View
import Header.View
import Profile.View
import Project.View
import Types exposing (Route(..))


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
page { accessToken, currentRoute, pageData } =
  case currentRoute of
    RegisterRoute ->
      case pageData of
        RegisterData data ->
          Html.map RegisterMsg (Register.View.view data) 
        _ -> blankView <| toString pageData

    LoginRoute ->
      case pageData of
        LoginData data ->
          Html.map LoginMsg (Login.View.view data) 
        _ -> blankView <| toString pageData
    
    ProfileRoute ->
      case pageData of
        ProfileData data ->
          Html.map ProfileMsg (Profile.View.view data) 
        _ -> blankView <| toString pageData
    
    ProjectRoute ->
      case pageData of
        ProjectData data ->
          Html.map ProjectMsg (Project.View.view data)
        _ -> blankView <| toString pageData

    NotFoundRoute -> blankView "Not found"


blankView : String -> Html Msg
blankView message =
    div []
        [ text message
        ]