module Login.State exposing (init, update)

import Debug
import Material
import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Maybe
import Regex

import Login.Types as Types exposing (Model, LoginForm, Msg(..))
import Login.Rest exposing (loginUser)


validate : Validation () LoginForm
validate =
  let
    textPattern = Regex.regex "^[a-zA-Z]+$"
    usernamePattern = Regex.regex "^[a-zA-Z]+[a-zA-Z0-9_]*$"
  in
    map2 LoginForm
      (field "username" (string |> andThen (format usernamePattern)))
      (field "password" (string |> andThen (minLength 8)))


init : ( Model, Cmd Msg )
init =
  ({ mdl = Material.model
   , loginForm = Form.initial [] validate
   }
  , Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    updateForm formMsg =
      { model | loginForm = Form.update formMsg model.loginForm }
  in
    case msg of
      -- Boilerplate: Mdl action handler.
      Mdl mdlMsg ->
        Material.update mdlMsg model

      Login formMsg ->
        let
          newModel = updateForm formMsg
          output = Form.getOutput newModel.loginForm
        in
          case output of
            Just formData -> (newModel, loginUser formData)
            Nothing -> (newModel, Cmd.none)
      
      LoginResult _ -> (model, Cmd.none)

      FormMsg formMsg ->
        (updateForm formMsg, Cmd.none)
