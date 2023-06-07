# Comidas - Ejercicio de modelado en Haskell

[![build](https://github.com/uqbar-project/comidas-haskell/actions/workflows/build.yml/badge.svg)](https://github.com/uqbar-project/comidas-haskell/actions/workflows/build.yml)

## Enunciado

Definimos una persona en base a indicadores nutricionales como el nivel de colesterol y su peso:

```hs
data Persona = Persona {
  colesterol :: Number,
  peso :: Kilos
} deriving Show
```

Queremos que la persona pueda comer distintas comidas: existen las ensaladas, las hamburguesas y las paltas, cada alimento aporta diferentes cosas a la persona que la come.

- una ensalada de x kilos aporta la mitad de peso para la persona y no agrega colesterol. Por ejemplo: una ensalada de 6 kilos le aporta 3 kg. extra de peso a una persona.
- cada hamburguesa tiene una cantidad de ingredientes: el colesterol aumenta un 50% para la persona y lo hace engordar en (3 * la cantidad de ingredientes) kilos
- la palta aumenta 2 kilos a quien la consume (el colesterol que aporta es despreciable)

## Alternativa 1: la comida es una función

```hs
type Comida = Persona -> Persona

ensalada :: Kilos -> Comida
ensalada kilos persona = persona {
  peso = peso persona + (kilos / 2)
}

hamburguesa :: [Ingrediente] -> Comida
hamburguesa ingredientes persona = persona {
  peso = peso persona + (3 * length ingredientes),
  colesterol = colesterol persona * 1.5
}

palta :: Comida
palta persona = persona {
  peso = peso persona + 2
}
```

#### ¡Quiero mi menú!
¿Puedo tener una lista de comidas? Sí, claro:

```hs
[ensalada 1, hamburguesa ["cheddar", "bacon"], palta, ensalada 3]
[<una función>,<una función>,<una función>,<una función>]
```

Y puedo pedirle a una persona que coma un conjunto de comidas:

```hs
almuerzo :: [Comida]
almuerzo = [ensalada 1, hamburguesa ["cheddar", "bacon"], palta, ensalada 3]

almorzar :: Persona -> Persona
almorzar persona = foldr ($) persona almuerzo
```

#### Pero pero peeeeero

Comer es una acción intrínseca a la comida, no puedo hacer otra cosa: las comidas no se pueden comparar, ni podemos acceder a información de una comida (ingredientes, o calorías que genera).

#### ¿Ventajas?

La ventaja principal es en lo didáctico:
- Modelar con funciones ¡es pensar en funcional!
- Además, para poder comer necesitamos tener aplicación parcial y orden superior, así que de paso estamos repasando esos temas.

#### ¿Y el locro?

Cuando aparece una nueva comida, eso no afecta lo que construimos anteriormente, solo se escribe una nueva función y eso nos sirve para incorporarla a cualquier almuerzo.

## Segunda variante: múltiples constructores

Si pensamos que la comida se modela como un tipo de dato con múltiples constructores, donde cada comida necesita un constructor diferente, tenemos esta solución:

```hs
data Comida' = Ensalada Kilos | Hamburguesa [Ingrediente] | Palta
  deriving (Eq, Ord, Show)

comer :: Comida' -> Persona -> Persona
comer (Ensalada kilos) persona = persona {
  peso = peso persona + (kilos / 2)
}

comer (Hamburguesa ingredientes) persona = persona {
  peso = peso persona + (3 * length ingredientes),
  colesterol = colesterol persona * 1.5
}

comer Palta persona = persona {
  peso = peso persona + 2
}
```

#### ¿Ventajas?

Separamos aquí el dato comida vs. la acción de comer. Tenemos información sobre la comida (kilos, ingredientes), podemos comparar las comidas, e incluso tener acciones diferentes (comer, endulzar, mejorar, etc.)

#### ¡Quiero mi menú!

Podemos tener una lista de comidas también: 

```hs
[Ensalada 1, Hamburguesa ["cheddar", "bacon"], Palta, Ensalada 3]
```

Y para almorzar, necesito aplicar la función comer al dato de la comida:

```hs
almorzar' :: Persona -> Persona
almorzar' persona = foldr comer persona almuerzo'
```

#### Pero pero peeeeero
No aparece la aplicación parcial (estás construyendo valores simplemente), el orden superior necesita que no construyas una función recursiva donde solamente apliques la función comer.

#### ¿Y el locro?
Cuando aparece una nueva comida, eso requiere ir a modificar cada una de las funciones que trabajan sobre la comida: comer, endulzar, mejorar, etc. Esto no es una desventaja, sino algo que se desglosa de la ventaja de poder tener distintas operaciones con las comidas y no sólo la operación "comer", como en el caso de modelar con funciones. 

Más información en [este artículo](http://wiki.uqbar.org/wiki/articles/data--definiendo-nuestros-tipos-en-haskell.html)

## Alternativa 3: typeclasses

La variante más tirada de los pelos consiste en pensar en la comida como un typeclass:

```hs
class Comida'' a where
   comer'' :: a -> Persona -> Persona

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

instance Comida'' Hamburguesa'' where
  comer'' (Hamburguesa'' ingredientes) persona = persona {
    peso = peso persona + (3 * length ingredientes),
    colesterol = colesterol persona * 1.5
  }

instance Comida'' Palta'' where
  comer'' (Palta'') persona = persona {
    peso = peso persona + 2
  }
```

#### ¿Y el locro?
Agregar una nueva comida se hace fácilmente: se agrega un `data Locro` y después un `instance Comida Locro`, implementando el `comer''` como en el ejemplo de arriba. Incluso se puede agregar el Locro en otro archivo, como al modelar con funciones.

#### PEERO PEERO PEEEEEERO ¡No es un tipo!

Ojo, porque la comida **no es un tipo**, sino un agrupador de diferentes tipos. Esto significa que la palta podría tener funciones específicas mientras que la ensalada podría tener otras. Si queremos tener funciones para cada tipo de comida, debemos escribirlas en el typeclass. Una ventaja sería que podríamos definir una función en la typeclass en base a otra:

```hs
class Comida'' a where
   comer'' :: a -> Persona -> Persona

   repetir'' :: a -> Persona -> Persona
   repetir'' comida persona = (comer'' comida . comer'' comida) persona
```

Cada comida necesita un constructor específico, que es propio para el tipo: el constructor Ensalada define el tipo Ensalada, y nada más. 

#### Pero pero peeeero... No tengo menú
El primer problema (la comida no es un tipo) se vuelve evidente cuando queremos tener una lista de comidas:

```hs
comidas = [Palta'', Ensalada'' 5, Hamburguesa'' ["cheddar"]]

<interactive>:14:21: error:
    • Couldn't match expected type ‘Palta''’
                  with actual type ‘Ensalada''’
    • In the expression: Ensalada'' 5
      In the expression:
        [Palta'', Ensalada'' 5, Hamburguesa'' ["cheddar"]]
      In an equation for ‘comidas’:
          comidas = [Palta'', Ensalada'' 5, Hamburguesa'' ["cheddar"]]

<interactive>:14:35: error:
    • Couldn't match expected type ‘Palta''’
                  with actual type ‘Hamburguesa''’
    • In the expression: Hamburguesa'' ["cheddar"]
      In the expression:
        [Palta'', Ensalada'' 5, Hamburguesa'' ["cheddar"]]
      In an equation for ‘comidas’:
          comidas = [Palta'', Ensalada'' 5, Hamburguesa'' ["cheddar"]]
```

es decir, colisionan la palta, la ensalada y la hamburguesa porque son de diferente tipo. Tampoco puedo compararlas, el operador (==) necesita que los elementos a comparar sean del mismo tipo:

```hs
(==) :: Eq a => a -> a -> a
```

Por más que la palta y la ensalada deriven de Eq, no podemos asociarlas a variables del mismo tipo. Y lo propio pasa con los operadores de Ord: (<), (>), etc.

El segundo problema es que estamos queriendo utilizar un concepto que fue pensado para otra cosa, que [no tiene que ver con modelar datos](https://www.reddit.com/r/haskell/comments/1j0awq/definitive_guide_on_when_to_use_typeclasses/). Incluso hay gente que piensa que es un antipattern hacer esto: [Haskell Antipattern: Existential Typeclass](https://medium.com/@jonathangfischoff/existential-quantification-patterns-and-antipatterns-3b7b683b7d71)

En definitiva, los typeclasses permiten agrupar tipos diferentes, y a nosotros nos conviene pensar en compartir todas las comidas con el mismo tipo.

## Resumen

Hemos comparado las tres soluciones posibles para modelar comidas: si bien utilizar múltiples constructores es la opción que hoy suele usarse comercialmente en la programación funcional, hay motivos didácticos muy fuertes para modelar con funciones aquellas abstracciones sabiendo que tenemos la restricción de definir una única operación principal y que no nos interesa conocer información relacionada, a favor de trabajar más fuertemente los conceptos de orden superior y aplicación parcial.

| Implementación de comida | fx | Data | Typeclass |
|----------|-------------|------|------|
| Comer | es **la** función | necesita una función `comer` | necesita una función `comer` |
| Puedo tener lista de comidas? | Sí, con aplicación parcial | Sí, múltiples constructores con diferentes parámetros (no hay aplicación parcial) | No, cada comida es un tipo distinto, no los puedo agrupar |
| Comer muchas comidas | `foldr ($)` | `foldr comer` (la función comer específica) | N/A | 
| Puedo comparar comidas | No | Sí, mediante una función custom o usando _deriving_ | No, `Ord` y `Eq` necesitan que los elementos sean del mismo tipo |
| Puedo obtener información de la comida? | No | Sí, todo lo que forme parte del data | Sí, requiere definir funciones extra |
| Repetir comida | `comida . comida` | se compone la función comer: ` (comer comida.comer comida)` | también se compone la función comer, se puede definir como implementación default en el typeclass (es una ventaja) |
| Nueva comida: locro | Es una nueva función | Es un constructor nuevo, el tema es que si tengo varias operaciones con las comidas eso implica tocar en varios lados | Requiere definir un data nuevo, con un tipo nuevo que sea instancia de la typeclass (es más burocrático) |
| Ventajas | Permite pensar en funciones, aplicación parcial y composición | Es la que más variantes permite, trabaja con pattern matching. Separa el dato (comida) de la acción (comer) | Podrías definir funciones específicas para algunas comidas, pero es un anti-pattern. |