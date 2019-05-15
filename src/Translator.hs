{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module Translator where

import Parser
import Typechecker

class Translate a g where
    translate :: a -> g -> String

instance Translate IExp Gamma where
    translate (IExpInt a) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = (show a)
    translate (IExpVar (Identifier a)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = a
    translate (IExp ie1 iBinOp ie2) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = translate ie1 (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) ++ " "++ (show iBinOp) ++ " " ++ translate ie2 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))

instance Translate Exp Gamma where
    translate (ExpVariable (Identifier id)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = id
    translate (ExpInteger a) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = (show a)
    translate (ExpString a) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = (show a)
    translate (ExpLambda e1 _ e2 _) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = "function(" ++ (translate e1 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ ") {" ++ (translate e2 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ "}"
    translate (ExpIExp a) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = (translate a (Gamma (Env l, TldMap m, TcDef td, TcImp ti)))
    translate (ExpUnaryFOCall (Identifier id) e1) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = id ++ "(" ++ (translate e1 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ ")"
    translate (ExpNullaryFOCall (Identifier id)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = id ++ "()"

instance Translate CDef Gamma where
    translate (NullaryConstructor (Identifier id)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = id ++ ":{}"
    -- translate (UnaryConstructor (Identifier id) _) = id ++ "()" -- NEEDS Monadic implementation to generate variable names

instance Translate Tld Gamma where
    translate (DataDef (Identifier id) [c]) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = "let " ++ id ++ " = Data(function(){ " ++ (translate c (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ "};" 
    translate (Func (FuncDefUnary (Identifier fName) (Identifier pName) _ e1 _)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = "function " ++ fName ++ "(" ++ pName ++ ") { " ++ (translate e1 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ " }"
    translate (Func (FuncDefNullary (Identifier fName) e1 _)) (Gamma (Env l, TldMap m, TcDef td, TcImp ti)) = "function " ++ fName ++ "() { " ++ (translate e1 (Gamma (Env l, TldMap m, TcDef td, TcImp ti))) ++ " }"
