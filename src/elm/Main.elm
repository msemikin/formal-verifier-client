import Html exposing (..)
import Html.Attributes exposing (href, class, style)

import Material
import Material.Scheme
import Material.Button as Button
import Material.Options as Options exposing (cs, css)
import Material.Layout as Layout
import Material.Elevation as Elevation
import Material.Textfield as Textfield

import Form exposing (Form)
import Form.Field as Field
import Form.Validate as Validate exposing (..)

import Maybe
import Debug
import Regex
import Result


-- MODEL

type alias RegistrationForm =
  { firstName: String
  , lastName: String
  , username: String
  , email: String
  , password: String
  , passwordRepeat: String
  }

type alias Model =
  { mdl : Material.Model -- Boilerplate: model store for any and all Mdl components you use.
  , registrationForm: Form () RegistrationForm
  }


init : ( Model, Cmd Msg )
init =
  ( { registrationForm = Form.initial [] validate
    , mdl = Material.model
    }
  , Cmd.none
  )

-- VALIDATION

validate : Validation () RegistrationForm
validate =
  let
    textPattern = Regex.regex "^[a-zA-Z]+$"
    usernamePattern = Regex.regex "^(a-zA-Z)+[a-zA-Z0-9_]*$"
  in
    map6 RegistrationForm
      (field "firstName" (string |> andThen (format textPattern)))
      (field "lastName" (string |> andThen (format textPattern)))
      (field "username" (string |> andThen (format usernamePattern)))
      (field "email" email)
      (field "password" (string |> andThen (minLength 8)))
      (field "passwordRepeat" string)

-- ACTION, UPDATE


type Msg =
    FormMsg (Form.Msg)
  | Mdl (Material.Msg Msg)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Boilerplate: Mdl action handler.
    Mdl mdlMsg ->
      Material.update mdlMsg model

    FormMsg formMsg ->
      ( { model | registrationForm = Form.update formMsg model.registrationForm }, Cmd.none )


-- VIEW


type alias Mdl =
  Material.Model

view : Model -> Html Msg
view model =
  Layout.render Mdl
    model.mdl
    [ Layout.fixedHeader
    ]
    { header = [ h4 [ class "header" ] [ text "Counter" ] ]
    , drawer = []
    , tabs = ( [], [] )
    , main = [ viewBody model ]
    }

viewBody : Model -> Html Msg
viewBody { mdl, registrationForm } =
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
        _ = Debug.log fieldName field
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
                , Button.onClick <| FormMsg Form.Submit
                , cs "btb-submit"
                ]
                [ text "Register" ]
              ]
            ]
          ]
        ]
      ]


main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , subscriptions = always Sub.none
    , update = update
    }
