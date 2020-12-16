import paramiko
import time

GPIOS=(4,14,15,17,18,27,22,23,24,10,9,25,11,8,7,5)

class Laboratorio():

    def __init__(self,hostname,username,password):
        self.username = username
        self.hostname = hostname
        self.password = password
        self.values = {i:"0" for i in GPIOS}
    
    def make_connection(self):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
            ssh.connect(hostname=self.hostname,username=self.username,password=self.password)
            return ssh
        except:
            raise Exception("Error al establecer la comunicación")
    def execute_fast_commands(self,commands):
        ssh = self.make_connection()
        shell = ssh.invoke_shell()
        for command in commands:
            shell.send(command)
            time.sleep(0.25)
        ssh.close()
        return
    def execute_command(self,command):
        ssh = self.make_connection()
        _,stdout,stderr = ssh.exec_command(command)
        output = stdout.read().decode()
        error = stderr.read().decode()

        ssh.close()

        if error:
            raise Exception(error)
        return output.replace("\r","")

    def habilitar_GPIOS(self):
        commands = [f"echo {i} > /sys/class/gpio/export\n" for i in GPIOS]
        self.execute_fast_commands(commands)
        print("GPIOS habilitadas")

    def configurar_GPIOS(self):
        commands = [f'echo "out" > /sys/class/gpio/gpio{i}/direction\n' for i in GPIOS]
        self.execute_fast_commands(commands)
    
    def borrar_GPIOS(self):
        commands = [f'echo "0" > /sys/class/gpio/gpio{i}/value\n' for i in GPIOS]
        self.execute_fast_commands(commands)
    def deshabilitar_GPIOS(self):
        commands = [f"echo {i} > /sys/class/gpio/unexport\n" for i in GPIOS]
        self.execute_fast_commands(commands)
        print("GPIOS deshabilitadas")
    def leer_GPIOS(self):
        gpios = r"\|".join(str(i) for i in GPIOS)
        comando = r"""cd /sys/class/gpio && find . -regex ".\/gpio\("""+gpios+r"""\)" -exec cat {}/value ';'"""
        res = self.execute_command(comando)
        if res:
            for index,line in enumerate(res.split("\n")):
                if line:
                    self.values[index] = line
        print(self.values)

    def escribir_GPIOS(self):
        commands = [f'echo "{value}" > /sys/class/gpio/gpio{i}/value\n' for i,value in self.values.items()]
        self.execute_fast_commands(commands)
        print("Escritura terminada")
    