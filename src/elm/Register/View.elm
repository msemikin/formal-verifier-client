module Register.View exposing (view)

import Form exposing (Form)
import Form.Field as Field
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material.Button as Button
import Material.Elevation as Elevation
import Material.Textfield as Textfield
import Material.Options as Options exposing (cs)

import Register.Types exposing (Model, Msg(..))

view: Model -> Html Msg
view { mdl, registrationForm } =
  let
    getField fieldName = Form.getFieldAsString fieldName registrationForm
    getFieldValue fieldName = Maybe.withDefault "" (getField fieldName).value

    handleInput : String -> String -> Msg
    handleInput fieldName value = FormMsg (Form.Input fieldName Form.Text (Field.String value))

    connectField : String -> List (Textfield.Property Msg)
    connectField fieldName =
      [ Textfield.value (getFieldValue fieldName)
      , Textfield.onInput (handleInput fieldName)
      ]

    getError : String -> String -> Textfield.Property Msg
    getError fieldName errorMsg =
      let
        field = getField fieldName
      in
        case field.liveError of
          Just error -> Textfield.error errorMsg
          Nothing -> Options.nop

    onlyLetters = "Can contain only letters"

  in
    div
      [ class "mdl-grid container" ]
      [ div [ class "mdl-cell mdl-cell--12-col-tablet mdl-cell--6-col-desktop mdl-cell--3-offset-desktop" ]
        [ Options.div
          [ Elevation.e2, cs "register-form" ]
          [ h4 [] [ text "Register" ]
          , div []
            [ div []
              [ Textfield.render Mdl [0] mdl
                ([ Textfield.label "First name"
                , Textfield.floatingLabel
                , cs "field"
                , getError "firstName" onlyLetters
                ] ++ connectField "firstName")

              , Textfield.render Mdl [1] mdl
                ([ Textfield.label "Last name"
                , Textfield.floatingLabel
                , cs "field"
                , getError "lastName" onlyLetters
                ] ++ connectField "lastName")

              , Textfield.render Mdl [2] mdl
                ([ Textfield.label "Email"
                , Textfield.floatingLabel
                , cs "field"
                , getError "email" "Invalid email"
                ] ++ connectField "email")


              , Textfield.render Mdl [3] mdl
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

              , let
                  error = getError "passwordRepeat" "This field is required"
                  passwordsEqual = (getFieldValue "password") == (getFieldValue "passwordRepeat")
                  passwordRepeatField = getField "passwordRepeat"
                in
                  Textfield.render Mdl [5] mdl
                    ([ Textfield.label "Repeat password"
                    , Textfield.floatingLabel
                    , Textfield.password
                    , cs "field"
                    , if error == Options.nop &&
                          not passwordsEqual &&
                          passwordRepeatField.isDirty
                        then Textfield.error "Passwords don't match"
                        else error
                    ] ++ connectField "passwordRepeat")
              ]
            , div [ class "btn-submit-container" ]
              [ Button.render Mdl [0] mdl
                [ Button.raised
                , Button.colored
                , Button.onClick <| Register Form.Submit
                , cs "btb-submit"
                ]
                [ text "Register" ]
              ]
            ]
          ]
        ]
      ]
