#!/bin/bash

# @brief: Este programa habilita los GPIOS de la raspberry para
# proporcionar valores de entrada al FPGA usando los conectores PMOD
# @author: Victor Hugo Garcia Ortega
# @version: 2.0
# @date: Noviembre 2020

GPIOS=(4 14 15 17 18 27 22 23 24 10 9 25 11 8 7 5)

#GPIOS=(24 22 18 15 23 27 17 14)

function habilitaGPIOS ()
{
	echo -e "\n \t Habilitando GPIOS...\n"

	for i in ${GPIOS[*]}
	do
		if [ ! -d /sys/class/gpio/gpio$i ]
		then
			echo $i > /sys/class/gpio/export
			echo -e "\t GPIO: $i habilitado"
		fi
	done
	sleep 1	#retardo necesario para dar tiempo a la habilitacion de GPIOS
}
function configGPIOS ()
{
	echo -e "\n \t Configurando GPIOS como salidas...\n"

	for i in ${GPIOS[*]}
	do
		if [ -d /sys/class/gpio/gpio$i ]
		then
			echo "out" > /sys/class/gpio/gpio$i/direction
			echo -e "\t GPIO: $i configurado"
		fi
	done
}
function borrarGPIOS ()
{
	echo -e "\n \t Borrando GPIOS...\n"

	for i in ${GPIOS[*]}
	do
		if [ -d /sys/class/gpio/gpio$i ]
		then
			echo "0" > /sys/class/gpio/gpio$i/value
			echo -e "\t GPIO: $i borrado"
		fi
	done
}
function deshabilitaGPIOS ()
{
	echo -e "\n \t Deshabilitando GPIOS...\n"

	for i in ${GPIOS[*]}
	do
		if [ -d /sys/class/gpio/gpio$i ]
		then
			echo $i > /sys/class/gpio/unexport
			echo -e "\t GPIO: $i deshabilitado"
		fi
	done
}
function obtenerValorGPIOS ()
{
	echo -e "\n \t Obteniendo valores de las terminales LAB...\n"

#	echo -n -e "\t"

	for(( i = 0; $i < ${#GPIOS[*]} ; i = $i + 1 ))
	do
		if [ -d /sys/class/gpio/gpio${GPIOS[$i]} ]
		then
			valor=$(cat /sys/class/gpio/gpio${GPIOS[$i]}/value)
			echo -e "\t LAB$i: $valor"
		#	echo -n -e "$i:$valor "
		fi
	done
}
function asignaValGPIOS ()
{
	while [ 1 ]
	do
		clear
		echo -e "\t Asignar valores a GPIOS"
		echo -e "\n \t Presiona (r) y ENTER  para regresar al menu principal en cualquier momento..."

		obtenerValorGPIOS

		echo -n -e "\n \t Selecciona la terminal LAB [ 0 - $[${#GPIOS[*]}-1] ] : "
		read numGPIO
		case $numGPIO in
			0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 )
				echo -n -e "\n \t Selecciona el valor a asignar [ 0 - 1 ] : "
				read valGPIO
				case $valGPIO in
					0 | 1 )
						echo $valGPIO > /sys/class/gpio/gpio${GPIOS[$numGPIO]}/value
					;;
					r )
						break;
					;;
					*)
						echo -e "\n \t Error, el valor $valGPIO no es valido "
						echo -e -n "\n \t Espere un momento..."
						sleep 2
					;;
				esac
			;;
			r )
				break;
			;;
			*)
				echo -e "\n \t Error, el GPIO $numGPIO no es valido "
				echo -e -n "\t Espere un momento..."
				sleep 2
			;;
		esac
	done
}
function aplicacion ()
{
	clear
	habilitaGPIOS
	configGPIOS
	borrarGPIOS

	echo -e -n "\n\t Espere un momento..."
	sleep 1

	while [ 1 ]
	do
		clear
		echo -e "\t Aplicacion para asignar valores a GPIOS v2.0 (NOV 2020)"
		echo -e "\t IPN - ESCOM - VHGO "
		echo -e "\t $(date) \n"

		echo -e 	"\t 1. Asignar valores a GPIOS"
		echo -e 	"\t 2. Mostrar GPIOS"
		echo -e 	"\t 3. Borrar GPIOS"
		echo -e 	"\t 4. Salir"

		echo -n -e 	"\n \t Selecciona la opcion: "
		read opcion

		case $opcion in
			1)
				asignaValGPIOS
			;;
			2)
				clear
				obtenerValorGPIOS
				echo -n -e "\n \t Presiona cualquier tecla para continuar... "
				read
			;;
			3)
				clear
				borrarGPIOS
				obtenerValorGPIOS
				echo -n -e "\n \t Presiona cualquier tecla para continuar... "
				read
			;;
			4)
				deshabilitaGPIOS
				echo -e "\n \t Aplicacion terminada\n"
				exit 0
			;;
			*)
				echo -e "\n \t Error!!, la opcion: $opcion no es valida "
				echo -e -n "\t Espere un momento..."
				sleep 2
			;;
		esac
	done
}

aplicacion

