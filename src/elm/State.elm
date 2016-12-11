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
import Profile.State
import Profile.Types
import Routing exposing (..)

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    (registerModel, registerCmd) = Register.State.init
    (loginModel, loginCmd) = Login.State.init
    (profileModel, profileCmd) = Profile.State.init
  in
    ( { mdl = Material.model
      , history = [ parseLocation location ]
      , user = Nothing
      , accessToken = Nothing
      , register = registerModel
      , login = loginModel
      , profile = profileModel
      }
    , Cmd.batch
      [ Cmd.map RegisterMsg registerCmd
      , Cmd.map LoginMsg loginCmd
      , Cmd.map ProfileMsg profileCmd
      ]
    )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Mdl mdlMsg ->
      Material.update mdlMsg model

    RegisterMsg (Register.Types.RegisterResult (Result.Ok user)) ->
      ({ model | user = Just user }
      , Navigation.newUrl "#/profile"
      )
    
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
    
    ProfileMsg msg ->
      let
        (newProfileModel, profileCmd) = Profile.State.update msg model.profile
      in
        ({ model | profile = newProfileModel }, Cmd.map ProfileMsg profileCmd)
        

    ShowProfile ->
      ( model, Navigation.newUrl "#/profile" )