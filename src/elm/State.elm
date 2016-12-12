module State exposing (init, update, subscriptions)

import Debug
import Material
import Maybe
import Platform.Cmd as Cmd

import Model exposing (Model, PageData(..))
import Types exposing (..)
import Messages exposing (Msg(..))
import Register.Types
import Register.State
import Login.State
import Login.Types
import Profile.State
import LocaleStorage exposing (..)
import Rest exposing (silentLogin)

init : ( Model, Cmd Msg )
init =
  let 
    model =
      { mdl = Material.model
      , currentRoute = LoginRoute
      , pageData = LoginData <| Tuple.first Login.State.init
      , user = Nothing
      , accessToken = Nothing
      , projects = []
      }
    
    effects = Cmd.batch
      [ Cmd.map LoginMsg <| Tuple.second Login.State.init
      , read "accessToken"
      ]
  in
    (model, effects)

initPage : PageData -> Route -> ( PageData, Cmd Msg )
initPage pageData route =
  let
    newPageData = case route of
      LoginRoute -> LoginData <| Tuple.first Login.State.init
      ProfileRoute -> ProfileData <| Tuple.first Profile.State.init
      RegisterRoute -> RegisterData <| Tuple.first Register.State.init
      NotFoundRoute -> pageData

    effect = case route of
      LoginRoute -> Cmd.map LoginMsg <| Tuple.second Login.State.init
      ProfileRoute -> Cmd.map ProfileMsg <| Tuple.second Profile.State.init
      RegisterRoute -> Cmd.map RegisterMsg <| Tuple.second Register.State.init
      NotFoundRoute -> Cmd.none

  in
    (newPageData, effect)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    _ = Debug.log "msg" (toString msg)
  in
    case msg of
      UpdateRoute route ->
        let
          proceedToPage =
            let
              (pageData, effect) = initPage model.pageData route
            in
              ( { model | currentRoute = route, pageData = pageData }
              , effect
              )
        in
          case model.user of
            Just user ->
              case route of
                LoginRoute -> update (UpdateRoute ProfileRoute) model
                RegisterRoute -> update (UpdateRoute ProfileRoute) model
                _ -> proceedToPage
            Nothing ->
              case route of
                ProfileRoute -> update (UpdateRoute LoginRoute) model
                _ -> proceedToPage

      Mdl mdlMsg ->
        Material.update mdlMsg model

      RegisterMsg (Register.Types.RegisterResult (Result.Ok user)) ->
        ({ model | user = Just user, currentRoute = ProfileRoute }
        , Cmd.none
        )
      
      RegisterMsg msg ->
        case model.pageData of
          RegisterData data ->
            let
              (pageData, effect) = Register.State.update msg data
            in
              ({ model | pageData = RegisterData pageData }, Cmd.map RegisterMsg effect)

          _ -> (model, Cmd.none)

      LoginMsg (Login.Types.LoginResult (Result.Ok { accessToken, user })) ->
        ( { model | user = Just user
          , accessToken = Just accessToken
          , currentRoute = ProfileRoute
          }
        , save <| "accessToken=" ++ accessToken
        )
      
      LoginMsg msg ->
        case model.pageData of
          LoginData data ->
            let
              (pageData, effect) = Login.State.update msg data
            in
              ({ model | pageData = LoginData pageData }, Cmd.map LoginMsg effect)

          _ -> (model, Cmd.none)
      
      ProjectsResult (Ok projects) ->
        ( { model | projects = projects }
        , Cmd.none
        )
      
      ProjectsResult (Err _) ->
        (model, Cmd.none)
      
      ProfileMsg msg ->
        case model.pageData of
          ProfileData data ->
            let
              (pageData, effect) = Profile.State.update msg data
            in
              ({ model | pageData = ProfileData pageData }, Cmd.map ProfileMsg effect)

          _ -> (model, Cmd.none)
      
      AccessTokenResult accessToken ->
        case accessToken of
          "" -> (model, Cmd.none)
          _ -> ({ model | accessToken = Just accessToken }, silentLogin accessToken)

      SilentLoginResult (Result.Ok user) ->
        ( { model | user = Just user
          , currentRoute = ProfileRoute
          }
        , Cmd.none
        )

      SilentLoginResult _ -> (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  readResult AccessTokenResult

