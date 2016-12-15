module State exposing (init, update, subscriptions)

import Debug
import Material
import Maybe
import Platform.Cmd as Cmd
import Dict exposing (Dict)
import Array

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
import Rest exposing (..)

init : ( Model, Cmd Msg )
init =
  let 
    model =
      { mdl = Material.model
      , currentRoute = LoginRoute
      , pageData = LoginData <| Tuple.first Login.State.init
      , user = Nothing
      , accessToken = Nothing
      , routeAfterLogin = Nothing
      , projects = Dict.empty
      }
    
    effects = Cmd.batch
      [ Cmd.map LoginMsg <| Tuple.second Login.State.init
      , read "accessToken"
      ]
  in
    (model, effects)


initPage : Model -> Route -> ( Model, Cmd Msg )
initPage model route =
  case route of
    LoginRoute ->
      let
        (data, effect) = Login.State.init
      in
        ( { model | pageData = LoginData data }, Cmd.map LoginMsg effect)

    ProfileRoute ->
      let
        (data, effect) = Profile.State.init
      in
        ( { model | pageData = ProfileData data }
        , Cmd.batch
          [ Cmd.map ProfileMsg effect
          , case model.accessToken of
              Just accessToken -> fetchProjects accessToken
              Nothing -> Cmd.none
          ]
        )

    RegisterRoute ->
      let
        (data, effect) = Register.State.init
      in
        ( { model | pageData = RegisterData data }, Cmd.map RegisterMsg effect)
    
    ProjectRoute projectId ->
      case model.accessToken of
        Just accessToken ->
          let
            (data, effect) = Project.State.init project projectId accessToken
            project = Dict.get projectId model.projects
            _ = Debug.log "state initPage" <| toString effect
          in
            ( { model | pageData = ProjectData data }, Cmd.map ProjectMsg effect)

        _ -> (model, Cmd.none)

    NotFoundRoute -> (model, Cmd.none)
 

insertModelInProject : String -> LTS -> Dict String Project -> Dict String Project
insertModelInProject projectId lts projects =
  Dict.update
    projectId
    (\project -> Maybe.map
      (\project -> { project | models = Dict.insert lts.id lts project.models })
      project
    )
    projects


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    _ = Debug.log "msg" (toString msg)
  in
    case msg of
      UpdateRoute route -> updateRoute route model

      Mdl mdlMsg -> Material.update mdlMsg model

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

      LoginMsg (Login.Types.LoginResult (Ok { accessToken, user })) ->
        let
          (updatedModel, effect) = update
            (UpdateRoute <| Maybe.withDefault ProfileRoute model.routeAfterLogin)
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
      
      ProfileMsg (Profile.Types.UpdateRoute route) ->
        update (UpdateRoute route) model

      ProfileMsg (Profile.Types.CreateProjectResult (Ok project)) ->
        let
          updatedModel =
            { model | projects = Dict.insert project.id project model.projects }
        in
          updateProfile (Profile.Types.CreateProjectResult (Ok project)) updatedModel
      
      ProfileMsg msg -> updateProfile msg model
      
      ProjectMsg (Project.Types.CreateModelResult (Ok newModel)) ->
        let
          updatedModel =
            case model.currentRoute of
              ProjectRoute projectId ->
                { model | projects = insertModelInProject projectId newModel model.projects }
              _ -> model
        in
          updateProject (Project.Types.CreateModelResult (Ok newModel)) updatedModel
      
      ProjectMsg (Project.Types.ProjectResult (Ok project)) ->
        let
          updatedModel =
            { model | projects = Dict.insert project.id project model.projects }
        in
          updateProject (Project.Types.ProjectResult (Ok project)) updatedModel
      
      ProjectMsg (Project.Types.UpdateModelResult (Ok updatedLTS)) ->
        let
          updatedModel =
            case model.currentRoute of
              ProjectRoute projectId ->
                { model | projects = insertModelInProject projectId updatedLTS model.projects }
              _ -> model
        in
          updateProject (Project.Types.UpdateModelResult (Ok updatedLTS)) updatedModel

      
      ProjectMsg msg -> updateProject msg model

      AccessTokenResult accessToken ->
        case accessToken of
          "" -> (model, Cmd.none)
          _ -> ({ model | accessToken = Just accessToken }, silentLogin accessToken)

      SilentLoginResult (Ok user) ->
        update
          (UpdateRoute <| Maybe.withDefault ProfileRoute model.routeAfterLogin)
          { model | user = Just user }

      SilentLoginResult _ -> (model, Cmd.none)
      
      ProjectsResult (Ok projects) ->
        ( { model |
            projects =
              List.map (\project -> (project.id, project)) projects
                |> Dict.fromList
          }
        , Cmd.none
        )
      
      ProjectsResult (Err _) ->
        (model, Cmd.none)


updateRoute : Route -> Model -> (Model, Cmd Msg)
updateRoute route model =
  let
    proceedToPage =
      let
        (updatedModel, effect) = initPage model route
      in
        ( { updatedModel | currentRoute = route }
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
        let
          requireLogin _ = update
            (UpdateRoute LoginRoute)
            { model | routeAfterLogin = Just route }
        in
          case route of
            ProfileRoute -> requireLogin ()
            ProjectRoute _ -> requireLogin ()
            _ -> proceedToPage


updateProject : Project.Types.Msg -> Model -> (Model, Cmd Msg)
updateProject msg model =
  case (model.pageData, model.currentRoute) of
    (ProjectData data, ProjectRoute projectId) ->
      let
        project = Dict.get projectId model.projects
        (pageData, effect) =
          Project.State.update project msg data
      in
        ({ model | pageData = ProjectData pageData }, Cmd.map ProjectMsg effect)
    _ -> (model, Cmd.none)


updateProfile : Profile.Types.Msg -> Model -> (Model, Cmd Msg)
updateProfile msg model =
  case model.pageData of
    ProfileData data ->
      let
        (pageData, effect) =
          case model.accessToken of
            Just accessToken -> Profile.State.update accessToken msg data
            Nothing -> (data, Cmd.none)
      in
        ({ model | pageData = ProfileData pageData }, Cmd.map ProfileMsg effect)

    _ -> (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ readResult AccessTokenResult
  , Sub.map ProjectMsg Project.State.subscriptions
  ]

