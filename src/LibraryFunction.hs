module LibraryFunction where
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

