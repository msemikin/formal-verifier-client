import Html exposing (..)
import Html.Attributes exposing (href, class, style)

import Material
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

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodePipeline exposing (required)

-- MODEL

type alias User =
  { firstName: String
  , lastName: String
  , username: String
  , email: String
  }


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
  , user: Maybe User
  }


init : ( Model, Cmd Msg )
init =
  ( { registrationForm = Form.initial [] validate
    , mdl = Material.model
    , user = Nothing
    }
  , Cmd.none
  )

-- VALIDATION

validate : Validation () RegistrationForm
validate =
  let
    textPattern = Regex.regex "^[a-zA-Z]+$"
    usernamePattern = Regex.regex "^[a-zA-Z]+[a-zA-Z0-9_]*$"
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
  | Register (Form.Msg)
  | RegisterResult (Result Http.Error User)

userDecoder : Decode.Decoder User
userDecoder =
  DecodePipeline.decode User
    |> required "first_name" Decode.string
    |> required "last_name" Decode.string
    |> required "username" Decode.string
    |> required "email" Decode.string

registerUser : RegistrationForm -> Cmd Msg
registerUser
  { firstName
  , lastName
  , username
  , email
  , password
  } =
    let
      accountData = Encode.object
        [ ("first_name", Encode.string firstName)
        , ("last_name", Encode.string lastName)
        , ("username", Encode.string username)
        , ("email", Encode.string email)
        , ("password", Encode.string password)
        ]

      body = Http.jsonBody accountData

      request = Http.post "http://localhost:5000/register" body userDecoder
    in
      Http.send RegisterResult request

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    updateForm formMsg =
      { model | registrationForm = Form.update formMsg model.registrationForm }
  in
    case msg of
      -- Boilerplate: Mdl action handler.
      Mdl mdlMsg ->
        Material.update mdlMsg model

      Register formMsg ->
        let
          newModel = updateForm formMsg
          output = Form.getOutput newModel.registrationForm
          _ = Debug.log "output" (toString output)
        in
          case output of
            Just formData -> (newModel, registerUser formData)
            Nothing -> (newModel, Cmd.none)

      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)

      RegisterResult (Result.Ok user) ->
        ({ model | user = Just user }, Cmd.none)

      RegisterResult (Result.Err _) ->
        (model , Cmd.none)



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


main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , subscriptions = always Sub.none
    , update = update
    }
