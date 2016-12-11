module Register.State exposing (init, update)

import Material
import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Maybe
import Debug
import Regex

import Register.Types as Types exposing (Model, RegistrationForm, Msg(..))
import Register.Rest exposing (registerUser)


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


init : ( Model, Cmd Msg )
init =
  ({ mdl = Material.model
   , registrationForm = Form.initial [] validate
   }
  , Cmd.none)

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
      
      RegisterResult _ -> (model, Cmd.none)

      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)
