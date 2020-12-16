import eel #Importamos la biblioteca eel
from Lab.Remoto import Laboratorio
import yaml

with open("./config.yml") as file:
    CONFIG = yaml.load(file, Loader=yaml.FullLoader)

HOSTNAME = CONFIG["hostname"]
USERNAME = CONFIG["username"]
PASSWORD = CONFIG["password"]
LAB = Laboratorio(HOSTNAME,USERNAME,PASSWORD)
@eel.expose #Exponemos la funcion a javascript
def reiniciar():
    LAB.habilitar_GPIOS()
    LAB.configurar_GPIOS()
    LAB.borrar_GPIOS()
    eel.reiniciar()
    eel.alertar("Reinicio completado")
    return
@eel.expose #Exponemos la funcion a javascript
def guardar(values):
    LAB.values = values
    #print(LAB.values)
    LAB.escribir_GPIOS()
    eel.alertar("Escritura completa")
    return

def main():
    eel.init('gui') # Carpeta de la interfaz
    eel.start('index.html',size=(1500, 1000),mode=None) # Archivo con la inferfaz

if __name__ == '__main__':
    main()
