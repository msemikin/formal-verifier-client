module Project.Types exposing (..)

import Dict exposing (Dict)
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
  | AddFormulaDialog
  | EditFormulaDialog


type alias ValidationResult =
  { graph : String
  , valid : Bool
  } 
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
  , formulasResults : Maybe (Dict String ValidationResult )
  , currentFormula : Maybe String
  , syntaxError : Maybe String
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
  | OpenAddFormula
  | SelectTab Int
  | UpdateModelSource String
  | CheckModel
  | CheckModelResult (Result Http.Error (Dict String ValidationResult))
  | SelectFormula String
  | EditFormula String
  | UpdateFormula Form.Msg
  | DeleteFormula String
  | DeleteModel String
  | DeleteModelResult (Result Http.Error Bool) String
