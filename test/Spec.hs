import PdePreludat
import Test.Hspec

main :: IO ()
main = hspec $ do
  describe "Test de ejemplo" $ do
    it "El pdepreludat se instaló correctamente" $ do
      (1 + 1) `shouldBe` 2

