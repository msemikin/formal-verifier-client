module Dropdown.Types exposing(..)

import Material

type DropdownMsg =
    DropdownSelect String
  | Mdl (Material.Msg DropdownMsg)

type alias Model =
  { mdl : Material.Model
  }
