port module Graphviz exposing (..)

port generateDiagram : String -> Cmd msg

port diagramResult : (String -> msg) -> Sub msg
