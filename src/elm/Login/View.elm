module Login.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Form exposing (Form)
import Material.Options as Options exposing (cs)
import Material.Textfield as Textfield
import Material.Elevation as Elevation
import Material.Button as Button

import Login.Types exposing (Model, Msg(..))
import Helpers.Form as FormHelpers

view : Model -> Html Msg
view { mdl, loginForm } =
  let
    getField = FormHelpers.getField loginForm
    getFieldValue = FormHelpers.getFieldValue loginForm
    connectField = FormHelpers.connectField FormMsg loginForm
    getError = FormHelpers.getError loginForm

    onlyLetters = "Can contain only letters"
  in
    div
      [ class "mdl-grid container" ]
      [ div [ class "mdl-cell mdl-cell--12-col-tablet mdl-cell--6-col-desktop mdl-cell--3-offset-desktop" ]
        [ Options.div
          [ Elevation.e2, cs "login-form" ]
          [ h4 [] [ text "Login" ]
          , div []
            [ div []
              [  Textfield.render Mdl [3] mdl
                ([ Textfield.label "Username"
                , Textfield.floatingLabel
                , cs "field"
                , getError "username" "Can contain letters, numbers and underscore"
                ] ++ connectField "username")

              , Textfield.render Mdl [4] mdl
                ([ Textfield.label "Password"
                , Textfield.floatingLabel
                , Textfield.password
                , cs "field"
                , getError "password" "Should be at least 8 characters"
                ] ++ connectField "password")
              ]
            , div [ class "btn-submit-container" ]
              [ Button.render Mdl [0] mdl
                [ Button.raised
                , Button.colored
                , Button.onClick <| Login Form.Submit
                , cs "btb-submit"
                ]
                [ text "Login" ]
              ]
            ]
          ]
        ]
      ]
