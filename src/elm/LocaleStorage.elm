port module LocaleStorage exposing (..)

port save : String -> Cmd msg

port read : String -> Cmd msg

port readResult : (String -> msg) -> Sub msg