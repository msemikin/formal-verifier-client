module Profile.Types exposing (..)

import Http
import Material
import Form exposing (Form)

import Types exposing (Project, Route)

type alias ProjectForm =
  { name : String
  , description : String
  }

type alias Model =
  { mdl : Material.Model
  , projectForm : Form () ProjectForm
  , projects : List Project
  }

type Msg =
    Mdl (Material.Msg Msg)
  | FormMsg (Form.Msg)
  | ProjectsResult (Result Http.Error (List Project))
  | UpdateRoute Route
  | CreateProject Form.Msg
  | CreateProjectResult (Result Http.Error (Project))