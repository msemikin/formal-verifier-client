module State exposing (init, update)

import Navigation
import Material
import Maybe
import Platform.Cmd as Cmd

import Model exposing (Model)
import Messages exposing (Msg(..))
import Register.Types as RegisterTypes
import Register.State as RegisterState
import Routing exposing (..)

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    (registerModel, registerCmd) = RegisterState.init
  in
    ( { mdl = Material.model
      , history = [ parseLocation location ]
      , user = Nothing
      , register = registerModel
      }
    , Cmd.map RegisterMsg registerCmd
    )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Mdl mdlMsg ->
      Material.update mdlMsg model

    RegisterMsg (RegisterTypes.RegisterResult (Result.Ok user)) ->
      ({ model | user = Just user }, Cmd.none)
     
    RegisterMsg msg ->
      let
        (newRegisterModel, registerCmd) = RegisterState.update msg model.register
      in
        ({ model | register = newRegisterModel }, Cmd.map RegisterMsg registerCmd)
    
    UrlChange location ->
      let
        newRoute = parseLocation location
      in
      ( { model | history = newRoute :: model.history }
      , Cmd.none
      )
