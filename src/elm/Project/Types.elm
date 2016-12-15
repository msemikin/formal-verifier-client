module Project.Types exposing (..)

import Http
import Material
import Form exposing (Form)

import Types exposing (..)

type alias ModelForm =
  { name : String
  }

type alias FormulaForm =
  { content : String
  }

type CurrentDialog =
    ModelDialog
  | FormulaDialog

type alias Model =
  { mdl : Material.Model
  , modelForm : Form () ModelForm
  , formulaForm : Form () FormulaForm
  , currentModelId : Maybe String
  , projectId : String
  , accessToken : String
  , diagram : Maybe String
  , currentDialog : CurrentDialog
  , currentTab : Int
  , modelSource : Maybe String
  }

type Msg =
    Mdl (Material.Msg Msg)
  | ModelFormMsg (Form.Msg)
  | FormulaFormMsg (Form.Msg)
  | CreateModel Form.Msg
  | CreateModelResult (Result Http.Error LTS)
  | ProjectResult (Result Http.Error Project)
  | UpdateModel
  | UpdateModelResult (Result Http.Error LTS)
  | SelectModel String
  | DiagramGenerated String
  | AddFormula Form.Msg
  | OpenModelDialog
  | OpenFormulaDialog
  | SelectTab Int
  | UpdateModelSource String
