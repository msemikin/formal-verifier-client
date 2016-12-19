module Project.Types exposing (..)

import Dict exposing (Dict)
import Http
import Material
import Form exposing (Form)

import Types exposing (..)
import Dropdown.Types

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
  | ComposeDialog


type alias ValidationResult =
  { graph : String
  , valid : Bool
  } 

type alias Model =
  { mdl : Material.Model
  , modelForm : Form () ModelForm
  , formulaForm : Form () FormulaForm
  , composeForm : Form () ModelForm
  , firstDropdown : Dropdown.Types.Model
  , secondDropdown : Dropdown.Types.Model
  , composeModelFirst : Maybe String
  , composeModelSecond : Maybe String
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
  | ComposeFormMsg (Form.Msg)
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
  | OpenComposeDialog
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
  | ComposeModels Form.Msg
  | ComposeModelsResult (Result Http.Error LTS)
  | FirstDropdownMsg Dropdown.Types.DropdownMsg
  | SecondDropdownMsg Dropdown.Types.DropdownMsg
