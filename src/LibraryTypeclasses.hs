module LibraryTypeclasses where
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
class Comida a where
   comer :: a -> Persona -> Persona

-- una ensalada de x kilos aporta la mitad de peso para la persona
--     y no agrega colesterol
data Ensalada = Ensalada Kilos
  deriving (Eq, Ord, Show)

data Hamburguesa = Hamburguesa [Ingrediente]
  deriving (Eq, Ord, Show)

data Palta = Palta
  deriving (Eq, Ord, Show)

instance Comida Ensalada where
  comer (Ensalada kilos) persona = persona {
    peso = peso persona + (kilos / 2)
  }

-- cada hamburguesa tiene una cantidad de ingredientes
-- el colesterol aumenta un 50%
-- el peso aumenta en 3 kilos * la cantidad de ingredientes
instance Comida Hamburguesa where
  comer (Hamburguesa ingredientes) persona = persona {
    peso = peso persona + (3 * length ingredientes),
    colesterol = colesterol persona * 1.5
  }

-- la palta aumenta 2 kilos a quien la consume
instance Comida Palta where
  comer (Palta) persona = persona {
    peso = peso persona + 2
  }

-- comidas = [Palta, Ensalada 5, Hamburguesa 1]

-- • Couldn't match expected type ‘Palta’ with actual type ‘Ensalada’
-- • In the expression: Ensalada 5
--   In the expression: [Palta, Ensalada 5, Hamburguesa 1]
--   In an equation for ‘comidas’:
--       comidas = [Palta, Ensalada 5, Hamburguesa 1]