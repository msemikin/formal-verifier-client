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
import Profile.Types
import Project.State
import Project.Types
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
      }
    
    effects = Cmd.batch
      [ Cmd.map LoginMsg <| Tuple.second Login.State.init
      , read "accessToken"
      ]
  in
    (model, effects)

initPage : PageData -> Route -> Maybe String -> ( PageData, Cmd Msg )
initPage pageData route accessToken =
  let
    (newPageData, effect) =
      case route of
        LoginRoute ->
          let
            (data, effect) = Login.State.init
          in
            (LoginData data, Cmd.map LoginMsg effect)

        ProfileRoute ->
          let
            (data, effect) = Profile.State.init accessToken
          in
            (ProfileData data, Cmd.map ProfileMsg effect)

        RegisterRoute ->
          let
            (data, effect) = Register.State.init
          in
            (RegisterData data, Cmd.map RegisterMsg effect)
        
        ProjectRoute ->
          let
            (data, effect) = Project.State.init
          in
            (ProjectData data, Cmd.map ProjectMsg effect)

        NotFoundRoute -> (pageData, Cmd.none)


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
              (pageData, effect) = initPage model.pageData route model.accessToken
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
                ProjectRoute -> update (UpdateRoute LoginRoute) model
                _ -> proceedToPage

      Mdl mdlMsg ->
        Material.update mdlMsg model

      RegisterMsg (Register.Types.RegisterResult (Result.Ok user)) ->
        update
          (UpdateRoute ProfileRoute)
          { model | user = Just user, currentRoute = ProfileRoute }
      
      RegisterMsg msg ->
        case model.pageData of
          RegisterData data ->
            let
              (pageData, effect) = Register.State.update msg data
            in
              ({ model | pageData = RegisterData pageData }, Cmd.map RegisterMsg effect)

          _ -> (model, Cmd.none)

      LoginMsg (Login.Types.LoginResult (Result.Ok { accessToken, user })) ->
        let
          (updatedModel, effect) = update
            (UpdateRoute ProfileRoute)
            { model | user = Just user
            , accessToken = Just accessToken
            }
        in
          ( updatedModel
          , Cmd.batch
            [ effect, save <| "accessToken=" ++ accessToken ]
          )
      
      LoginMsg msg ->
        case model.pageData of
          LoginData data ->
            let
              (pageData, effect) = Login.State.update msg data
            in
              ({ model | pageData = LoginData pageData }, Cmd.map LoginMsg effect)

          _ -> (model, Cmd.none)
      
      ProfileMsg (Profile.Types.UpdateRoute route)
        -> update (UpdateRoute route) model
      
      ProfileMsg msg ->
        case model.pageData of
          ProfileData data ->
            let
              (pageData, effect) = Profile.State.update msg data
            in
              ({ model | pageData = ProfileData pageData }, Cmd.map ProfileMsg effect)

          _ -> (model, Cmd.none)
      
      ProjectMsg msg ->
        case model.pageData of
          ProjectData data ->
            let
              (pageData, effect) = Project.State.update msg data
            in
              ({ model | pageData = ProjectData pageData }, Cmd.map ProjectMsg effect)
          _ -> (model, Cmd.none)
      
      AccessTokenResult accessToken ->
        case accessToken of
          "" -> (model, Cmd.none)
          _ -> ({ model | accessToken = Just accessToken }, silentLogin accessToken)

      SilentLoginResult (Result.Ok user) ->
        update (UpdateRoute ProfileRoute) { model | user = Just user }

      SilentLoginResult _ -> (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  readResult AccessTokenResult

