module Library
where

import PdePreludat

type Kilos = Number
type Ingrediente = String

data Persona = Persona {
  colesterol :: Number,
  peso :: Kilos
} deriving Show

pesoPar :: Persona -> Bool
pesoPar = even . peso

--1) Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
type Comida = Persona -> Persona

ensalada :: Kilos -> Comida
ensalada kilos persona = persona {
  peso = peso persona + (kilos / 2)
}

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
hamburguesa :: [Ingrediente] -> Comida
hamburguesa ingredientes persona = persona {
  peso = peso persona + (3 * length ingredientes),
  colesterol = colesterol persona * 1.5
}

-- la palta aumenta 2 kilos a quien la consume
palta :: Comida
palta persona = persona {
  peso = peso persona + 2
}

almuerzo :: [Comida]
almuerzo = [ensalada 1, hamburguesa ["cheddar", "bacon"], palta, ensalada 3]

almorzar :: Persona -> Persona
almorzar persona = foldr ($) persona almuerzo

-- para mayor expresividad
-- almorzar persona = foldr comer persona almuerzo
-- comer persona comida = comida persona

--2) Queremos que todas las comidas se puedan comer dos veces seguidas
repetir:: Comida -> Persona -> Persona
repetir comida = comida.comida

--3) Queremos ver si un almuerzo contiene una comida dada
--contieneComida::Comida -> [Comida]->Bool
-- No podemos hacerlo porque las comidas no son Eq

--4) Queremos averiguar si una comida es sabrosa.
-- las ensaladas son sabrosas cuando tienen más de un kilo
-- las hamburguesas son sabrosas cuando tienen cheddar
-- las paltas son sabrosas
-- No podemos hacerlo

--5) Queremos averiguar si una comida va a ser disfrutada por alguien.
-- Para quienes pesan una cantidad par, todas las comidas son disfrutadas, 
-- para los demás, solo son disfrutadas las comidas sabrosas
-- Necesitamos nuevas funciones para disfrutar cada comida 
-- (tal vez convenga renombrar las anteriores, x ej comerEnsalada en vez de ensalada)
disfrutarEnsalada :: Kilos -> Persona -> Bool
disfrutarEnsalada kilos alguien = pesoPar alguien || kilos > 1

disfrutarHamburguesa :: [Ingrediente] -> Persona -> Bool
disfrutarHamburguesa ingredientes alguien = pesoPar alguien || elem "cheddar" ingredientes

disfrutarPalta:: Persona -> Bool
disfrutarPalta _ = True

-- ************************************************************
-- CON DATA
-- ************************************************************

-- Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

data Comida' = Ensalada Kilos | Hamburguesa [Ingrediente] | Palta
  deriving (Eq, Ord, Show)

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
comer' :: Comida' -> Persona -> Persona
comer' (Ensalada kilos) persona = persona {
  peso = peso persona + (kilos / 2)
}

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
comer' (Hamburguesa ingredientes) persona = persona {
  peso = peso persona + (3 * length ingredientes),
  colesterol = colesterol persona * 1.5
}

-- la palta aumenta 2 kilos a quien la consume
comer' Palta persona = persona {
  peso = peso persona + 2
}


almuerzo' :: [Comida']
almuerzo' = [Ensalada 1, Hamburguesa ["cheddar", "bacon"], Palta, Ensalada 3]

almorzar' :: Persona -> Persona
almorzar' persona = foldr comer' persona almuerzo'

--2) Queremos que todas las comidas se puedan comer dos veces seguidas
repetir':: Comida' -> Persona -> Persona
repetir' comida persona = (comer' comida.comer' comida) persona

--3) Queremos ver si un almuerzo contiene una comida dada
contieneComida'::Comida'->[Comida']->Bool
contieneComida' comida comidas = elem comida comidas
--contieneComida = elem

--4) Queremos averiguar si una comida es sabrosa.
sabrosa' :: Comida' -> Bool

-- las ensaladas son sabrosas cuando tienen más de un kilo
sabrosa' (Ensalada kilos) = kilos > 1

-- las hamburguesas son sabrosas cuando tienen cheddar
sabrosa' (Hamburguesa ingredientes) = "cheddar" `elem` ingredientes

--las paltas son sabrosas
sabrosa' Palta = True

--5) Queremos averiguar si una comida va a ser disfrutada por alguien.
-- Para quienes pesan una cantidad par, todas las comidas son disfrutadas, 
-- para los demás, solo son disfrutadas las comidas sabrosas
disfrutar' :: Comida' -> Persona -> Bool
disfrutar' comida alguien = pesoPar alguien || sabrosa' comida




-- ************************************************************
-- CON TYPECLASSES
-- ************************************************************
--1) Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
class Comida'' a where
   comer'' :: a -> Persona -> Persona

   repetir'' :: a -> Persona -> Persona
   repetir'' comida persona = (comer'' comida . comer'' comida) persona

   sabrosa'' :: a -> Bool

data Ensalada'' = Ensalada'' {kilos::Kilos}
  deriving (Eq, Ord, Show)

data Hamburguesa'' = Hamburguesa'' {ingredientes::[Ingrediente]}
  deriving (Eq, Ord, Show)

data Palta'' = Palta''
  deriving (Eq, Ord, Show)

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
instance Comida'' Ensalada'' where
  comer'' ensalada persona = persona {
    peso = peso persona + (kilos ensalada / 2)
  }
-- las ensaladas son sabrosas cuando tienen más de un kilo
  sabrosa'' ensalada = kilos ensalada > 1

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
instance Comida'' Hamburguesa'' where
  comer'' hamburguesa persona = persona {
    peso = peso persona + (3 * length (ingredientes hamburguesa)),
    colesterol = colesterol persona * 1.5
  }
-- las hamburguesas son sabrosas cuando tienen cheddar
  sabrosa'' hamburguesa = "cheddar" `elem` ingredientes hamburguesa
  --sabrosa'' = elem "cheddar".ingredientes

-- la palta aumenta 2 kilos a quien la consume
instance Comida'' Palta'' where
  comer'' _ persona = persona {
    peso = peso persona + 2
  }
--las paltas se repiten comiendolas tres veces  
  repetir'' palta persona = (comer'' palta.comer'' palta.comer'' palta) persona
--las paltas son sabrosas
  sabrosa'' _ = True

--Como las listas no pueden mezclar diferentes tipos, los almuerzos esta compuestas por comidas del mismo tipo 
almuerzo'' :: [Hamburguesa'']
almuerzo'' = [Hamburguesa'' ["cheddar", "bacon"], Hamburguesa'' ["J","Q","L","T"] ]
--almuerzo'' = [Ensalada'' 1, Ensalada'' 5, Ensalada 2]
--almuerzo'' = [Palta'']

almorzar'' :: Persona -> Persona
almorzar'' persona = foldr comer'' persona almuerzo''

--2) Queremos que todas las comidas se puedan repetir,
-- es decir, que se pueden comer dos veces seguidas, 
-- excepto la palta, que se come tres veces
-- Resuelto en la definicion de la typeClass y cada data

--3) Queremos ver si un almuerzo contiene una comida dada
contieneComida''::(Comida'' a, Eq a) => a->[a]->Bool
contieneComida'' comida comidas = elem comida comidas
--contieneComida = elem

--4) Queremos averiguar si una comida es sabrosa.
-- Resuelto en la definicion de la typeClass y cada data

--5) Queremos averiguar si una comida va a ser disfrutada por alguien.
-- Para quienes pesan una cantidad par, todas las comidas son disfrutadas, 
-- para los demás, solo son disfrutadas las comidas sabrosas
disfrutar'' :: Comida'' a => a -> Persona -> Bool
disfrutar'' comida alguien = pesoPar alguien || sabrosa'' comida


-- **************************************************************************
-- COMBINANDO FUNCIONES Y DATA
-- **************************************************************************

-- También es posible combinar diferentes estrategias y definir como funcion
-- alguna de las componentes del data
-- Es util en casos donde hay variedad en los comportamientos, pero la misma
-- estructura de datos 

-- Consideremos el ejemplo anterior, pero ahora  de todas las comidas se conoce 
-- la misma información (kilos y lista de ingredientes). 
-- Los comportamientos son inicialmente los  mismos, pero se prevee 
-- que haya otras alternativas y que un mismo alimento puedan modificarlos

type FormaDeComer = Comida'''->Persona->Persona
type CriterioSabroso = Comida'''->Bool

data Comida''' = Comida''' {
  ingr:: [Ingrediente],
  kil::Kilos,
  formaDeComer:: FormaDeComer,
  criterioSabroso:: CriterioSabroso
}


--1) Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
ensalada'''::FormaDeComer
ensalada''' comida persona = persona {
  peso = peso persona + (kil comida / 2)
}

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
hamburguesa'''::FormaDeComer
hamburguesa''' comida persona = persona {
  peso = peso persona + (3 * length (ingr comida)),
  colesterol = colesterol persona * 1.5
}

-- la palta aumenta 2 kilos a quien la consume
palta'''::FormaDeComer
palta''' _ persona  = persona {
  peso = peso persona + 2
}

comer'''::Comida'''->Persona->Persona
comer''' comida persona = (formaDeComer comida) comida persona

almuerzo''' :: [Comida''']
almuerzo''' = [Comida''' [] 1 ensalada''' saborContundente, Comida''' ["cheddar", "bacon"] 0 hamburguesa''' saborChedar, Comida''' [] 0 palta''' siempreSabroso, Comida''' [] 3 ensalada''' siempreSabroso]

almorzar''' :: Persona -> Persona
almorzar''' persona = foldr comer''' persona almuerzo'''

--2) Queremos que todas las comidas se puedan comer dos veces seguidas
repetir''':: Comida''' -> Persona -> Persona
repetir''' comida persona = (comer''' comida.comer''' comida) persona

--3) Queremos ver si un almuerzo contiene una comida dada
instance Eq Comida''' where
  comida1 == comida2 = ingr comida1 == ingr comida2 && kil comida1 == kil comida2

contieneComida'''::Comida'''->[Comida''']->Bool
contieneComida''' comida comidas = elem comida comidas
--contieneComida''' = elem

--4) Queremos averiguar si una comida es sabrosa.
--Se debe agregar otra componente más al data con la correspondiente función
--No necesariamente deben corresponderse con las formas de comer

sabrosa''':: Comida''' -> Bool
sabrosa''' comida = (criterioSabroso comida) comida

saborChedar, saborContundente, siempreSabroso::CriterioSabroso
saborChedar comida = elem "cheddar" (ingr comida)
saborContundente comida = kil comida > 1
siempreSabroso _ = True

--5) Queremos averiguar si una comida va a ser disfrutada por alguien.
-- Para quienes pesan una cantidad par, todas las comidas son disfrutadas, 
-- para los demás, solo son disfrutadas las comidas sabrosas
disfrutar''' :: Comida''' -> Persona -> Bool
disfrutar''' comida alguien = pesoPar alguien || sabrosa''' comida

--Nuevas formas de comer
comidaLigth::FormaDeComer
comidaLigth comida persona
  | length (ingr comida) >= 2 = persona {peso = peso persona * 1.02}
  | otherwise = persona

comidaInofensiva::FormaDeComer
comidaInofensiva _ p = p

cambiarFormaDeComer::FormaDeComer->Comida'''->Comida'''
cambiarFormaDeComer forma comida = comida {formaDeComer = forma}
