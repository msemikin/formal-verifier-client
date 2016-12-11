module View exposing (view)

import Material.Layout as Layout
import Html exposing (..)
import Html.Attributes exposing (href, class, style)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Register.View


view : Model -> Html Msg
view { mdl, register } =
  Layout.render Mdl mdl
    [ Layout.fixedHeader
    ]
    { header = [ h4 [ class "header" ] [ text "Counter" ] ]
    , drawer = []
    , tabs = ( [], [] )
    , main = [ Html.map RegisterMsg (Register.View.view register) ]
    }

