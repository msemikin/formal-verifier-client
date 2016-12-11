module Helpers.Form exposing (getField, getFieldValue, connectField, getError)

import Material.Options as Options
import Material.Textfield as Textfield
import Form exposing (Form, FieldState)
import Form.Field as Field exposing (Field)
import Maybe

getField : Form e o -> String -> FieldState e String
getField form fieldName = Form.getFieldAsString fieldName form

getFieldValue : Form e o -> String -> String
getFieldValue form fieldName = Maybe.withDefault "" (getField form fieldName).value

handleInput : (Form.Msg -> msg) -> String -> String -> msg
handleInput tag fieldName value = tag (Form.Input fieldName Form.Text (Field.String value))

connectField : (Form.Msg -> msg) -> Form e o -> String -> List (Textfield.Property msg)
connectField tag form fieldName =
  [ Textfield.value (getFieldValue form fieldName)
  , Textfield.onInput (handleInput tag fieldName)
  ]

getError : Form e o -> String -> String -> Textfield.Property msg
getError form fieldName errorMsg =
  let
    field = getField form fieldName
  in
    case field.liveError of
      Just error -> Textfield.error errorMsg
      Nothing -> Options.nop