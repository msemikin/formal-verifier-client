module Dropdown.State exposing (..)

import Material

import Dropdown.Types exposing(..)

init : Model
init =
  { mdl = Material.model
  }


update : DropdownMsg -> Model -> (Model, Cmd DropdownMsg)
update msg model =
  case msg of
    Mdl mdlMsg ->
      Material.update mdlMsg model
    DropdownSelect _ -> (model, Cmd.none)
