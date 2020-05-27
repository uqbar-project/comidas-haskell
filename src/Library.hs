module Library
where

import PdePreludat

type Kilos = Number
type Ingrediente = String

data Persona = Persona {
  colesterol :: Number,
  peso :: Kilos
}

-- Queremos que la persona pueda comer distintas comidas. 
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

-- ************************************************************
-- CON DATA
-- ************************************************************

-- Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
data Comida' = Ensalada Kilos | Hamburguesa [Ingrediente] | Palta
  deriving (Eq, Ord, Show)

comer :: Comida' -> Persona -> Persona
comer (Ensalada kilos) persona = persona {
  peso = peso persona + (kilos / 2)
}

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
comer (Hamburguesa ingredientes) persona = persona {
  peso = peso persona + (3 * length ingredientes),
  colesterol = colesterol persona * 1.5
}

-- la palta aumenta 2 kilos a quien la consume
comer (Palta) persona = persona {
  peso = peso persona + 2
}


almuerzo' :: [Comida']
almuerzo' = [Ensalada 1, Hamburguesa ["cheddar", "bacon"], Palta, Ensalada 3]

almorzar' :: Persona -> Persona
almorzar' persona = foldr comer persona almuerzo'


-- ************************************************************
-- CON TYPECLASSES
-- ************************************************************
-- Queremos que la persona pueda comer distintas comidas. 
-- Existen las ensaladas, las hamburguesas y las paltas, 
-- quiero comer las distintas cosas y cada cosa aporta distinto 
-- al comerla

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
class Comida'' a where
   comer'' :: a -> Persona -> Persona

   repetir'' :: a -> Persona -> Persona
   repetir'' comida persona = (comer'' comida . comer'' comida) persona

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
data Ensalada'' = Ensalada'' Kilos
  deriving (Eq, Ord, Show)

data Hamburguesa'' = Hamburguesa'' [Ingrediente]
  deriving (Eq, Ord, Show)

data Palta'' = Palta''
  deriving (Eq, Ord, Show)

instance Comida'' Ensalada'' where
  comer'' (Ensalada'' kilos) persona = persona {
    peso = peso persona + (kilos / 2)
  }

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
instance Comida'' Hamburguesa'' where
  comer'' (Hamburguesa'' ingredientes) persona = persona {
    peso = peso persona + (3 * length ingredientes),
    colesterol = colesterol persona * 1.5
  }

-- la palta aumenta 2 kilos a quien la consume
instance Comida'' Palta'' where
  comer'' (Palta'') persona = persona {
    peso = peso persona + 2
  }
