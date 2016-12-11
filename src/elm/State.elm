module State exposing (init, update)

import Debug
import Navigation
import Material
import Maybe
import Platform.Cmd as Cmd

import Model exposing (Model)
import Messages exposing (Msg(..))
import Register.Types
import Register.State
import Login.State
import Login.Types
import Routing exposing (..)

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    (registerModel, registerCmd) = Register.State.init
    (loginModel, loginCmd) = Login.State.init
  in
    ( { mdl = Material.model
      , history = [ parseLocation location ]
      , user = Nothing
      , accessToken = Nothing
      , register = registerModel
      , login = loginModel
      }
    , Cmd.batch
      [ Cmd.map RegisterMsg registerCmd
      , Cmd.map LoginMsg loginCmd
      ]
    )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Mdl mdlMsg ->
      Material.update mdlMsg model

    RegisterMsg (Register.Types.RegisterResult (Result.Ok user)) ->
      ({ model | user = Just user }, Cmd.none)
    
    RegisterMsg msg ->
      let
        (newRegisterModel, registerCmd) = Register.State.update msg model.register
      in
        ({ model | register = newRegisterModel }, Cmd.map RegisterMsg registerCmd)

    LoginMsg (Login.Types.LoginResult (Result.Ok { accessToken, user })) ->
      ( { model | user = Just user
        , accessToken = Just accessToken
        }
      , Navigation.newUrl "#/profile"
      )

    LoginMsg msg ->
      let
        (newLoginModel, loginCmd) = Login.State.update msg model.login
      in
        ({ model | login = newLoginModel }, Cmd.map LoginMsg loginCmd)
    
    UrlChange location ->
      let
        newRoute = parseLocation location
      in
        ( { model | history = newRoute :: model.history }
        , Cmd.none
        )

    ShowProfile ->
      ( model, Navigation.newUrl "#/profile" )