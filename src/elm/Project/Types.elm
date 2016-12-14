module Project.Types exposing (..)

import Http
import Material
import Form exposing (Form)

import Types exposing (..)

type alias ModelForm =
  { name : String
  }

type alias Model =
  { mdl : Material.Model
  , modelForm : Form () ModelForm
  , currentModelIndex : Maybe Int
  , projectId : String
  , accessToken : String
  }

type Msg =
    Mdl (Material.Msg Msg)
  | FormMsg (Form.Msg)
  | CreateModel Form.Msg
  | CreateModelResult (Result Http.Error LTS)
  | ProjectResult (Result Http.Error Project)
  | UpdateModelResult (Result Http.Error LTS)
