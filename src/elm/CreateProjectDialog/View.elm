module CreateProjectDialog.View exposing (..)

import Form exposing (Form)
import Html exposing (..)
import Material
import Material.Options as Options exposing (cs)
import Material.Dialog as Dialog
import Material.Button as Button
import Material.Textfield as Textfield

import Profile.Types exposing (..)
import Helpers.Form as FormHelpers

view : Form e o -> Material.Model -> Html Msg
view projectForm mdl =
  let
    getField = FormHelpers.getField projectForm
    getFieldValue = FormHelpers.getFieldValue projectForm
    connectField = FormHelpers.connectField FormMsg projectForm
    getError = FormHelpers.getError projectForm
  in
    Dialog.view
      [ cs "project-dialog" ]
      [ Dialog.title [] [ text "New project" ]
      , Dialog.content []
        [ p [] [ text "Enter the new project details" ]
        , div []
          [ Textfield.render Mdl [0] mdl
            ([ Textfield.label "Name"
            , Textfield.floatingLabel
            , cs "field"
            , getError "name" "Name is required"
            ] ++ connectField "name")

          , Textfield.render Mdl [1] mdl
            ([ Textfield.label "Description"
            , Textfield.textarea
            , Textfield.floatingLabel
            , cs "field"
            , getError "description" "Description is required"
            ] ++ connectField "description")
          ]
        ]
      , Dialog.actions []
        [ Button.render Mdl [1] mdl
          [ Button.colored
          , Button.onClick <| CreateProject Form.Submit
          ]
          [ text "Create" ]
        , Button.render Mdl [0] mdl
          [ Dialog.closeOn "click" ]
          [ text "Close" ]
        ]
      ]
