# Infraestructura para AWS con Terraform

Este proyecto forma parte de un reto que consiste en crear un entorno automatizado para detectar actores y actrices en videos o fragmentos de películas. La infraestructura está diseñada para desplegarse en AWS utilizando Terraform, y está compuesta por varios módulos que trabajan en conjunto para procesar videos, almacenar resultados, y exponerlos a través de una API, todo pensado para ejecutarlo en un entorno Cloud.

> **Nota**: Como parte de este reto/proyecto, algunas medidas de seguridad fueron intencionalmente relajadas debido a las restricciones del entorno de laboratorio. Por ejemplo, se permitió acceso SSH desde cualquier IP y se abrieron todos los puertos necesarios para garantizar la funcionalidad. Estas configuraciones no son recomendadas para entornos de producción.

> **Nota adicional**: La estructura de este Terraform fue desarrollada en tan solo 3 días, ya que era una parte opcional de una auditoría. La prueba final consistía en desplegar todo el proyecto, y sin esta automatización probablemente no habría sido posible realizar todo desde la interfaz de AWS en el tiempo disponible. Por esta razón, se optó por utilizar Terraform para agilizar el despliegue.

## Estructura del Proyecto

El proyecto está organizado en los siguientes módulos y componentes:

### 1. **Módulo de S3**
Este módulo crea dos buckets de S3:
- **Bucket de datos en bruto (`raw_data`)**: Almacena los videos subidos para ser procesados.
- **Bucket de datos procesados (`processed_data`)**: Almacena los resultados generados por el modelo de detección, así como los logs.

Además, se crean carpetas específicas dentro de los buckets:
- `/videos/` en el bucket de datos en bruto.
- `/results/` y `/logs/` en el bucket de datos procesados.

### 2. **Módulo de Seguridad**
Este módulo configura un Security Group para la instancia EC2, permitiendo acceso SSH (puerto 22) desde cualquier IP y tráfico saliente sin restricciones.

### 3. **Módulo de EC2**
Este módulo despliega una instancia EC2 que actúa como servidor de procesamiento. La instancia está configurada para:
- Descargar y configurar dependencias necesarias para el modelo de detección.
- Clonar el repositorio del modelo de detección desde GitLab.
- Ejecutar scripts para procesar videos y subir resultados a S3.
- Configurar un crontab para ejecutar el script principal al reiniciar.

### 4. **Módulo de DynamoDB**
Este módulo crea una tabla DynamoDB llamada `MovieEntities` para almacenar información sobre las películas y sus entidades detectadas. La tabla incluye índices secundarios globales para facilitar consultas por género, director, fecha de procesamiento, y tipo de entidad.

### 5. **Módulo de Lambdas**
Este módulo incluye tres funciones Lambda:
- **Lambda para subir videos a S3 (`lambda_upload_s3`)**: Permite subir videos al bucket de datos en bruto mediante una API.
- **Lambda para obtener resultados desde S3 (`lambda_results_s3_to_api`)**: Devuelve el archivo más reciente de resultados desde el bucket de datos procesados.
- **Lambda para encender la instancia EC2 (`lambda_encendido_ec2`)**: Permite encender la instancia EC2 desde una API.

### 6. **Módulo de API Gateway**
Este módulo configura un API Gateway con dos rutas:
- **GET `/get-video`**: Obtiene los resultados desde S3 utilizando la Lambda `lambda_results_s3_to_api`.
- **PUT `/bucket/folder/filename`**: Genera una URL prefirmada para subir videos al bucket de datos en bruto utilizando la Lambda `lambda_upload_s3`.

### 7. **Módulo de Key Pair**
Este módulo genera un par de claves SSH para acceder a la instancia EC2. La clave privada se guarda localmente y se utiliza para conectarse a la instancia.

### 8. **Scripts**
El proyecto incluye varios scripts:
- **`script.sh`**: Descarga videos desde S3, ejecuta el modelo de detección, y sube los resultados a S3.
- **`script_master.sh`**: Ejecuta el script principal y sube los logs generados a S3.
- **`subida_a_dynamo.py`**: Procesa los resultados y los sube a DynamoDB.

### 9. **Archivo Principal de Terraform**
El archivo `main.tf` integra todos los módulos mencionados anteriormente, definiendo las dependencias entre ellos.

### 10. **Otros Archivos**
- **`variables.tf`**: Define las variables globales utilizadas en el proyecto.
- **`outputs.tf`**: Expone los valores importantes generados por la infraestructura, como la IP pública de la EC2 y los nombres de los buckets.
- **`deploy.sh`**: Script para desplegar la infraestructura y subir los scripts necesarios a la instancia EC2.

## Flujo del Proyecto

1. **Subida de Videos**: Los videos se suben al bucket de datos en bruto mediante la API Gateway.
2. **Procesamiento**: La instancia EC2 ejecuta el modelo de detección facial para identificar actores y actrices en los videos.
3. **Resultados**: Los resultados se almacenan en el bucket de datos procesados y en DynamoDB.
4. **Consulta de Resultados**: Los resultados pueden ser consultados mediante la API Gateway.

## Requisitos

- **Terraform**: Para desplegar la infraestructura.
- **AWS CLI**: Para interactuar con los servicios de AWS.
- **Python 3.9**: Para ejecutar los scripts y el modelo de detección.
- **Credenciales de AWS**: Configuradas en el entorno local.

## Despliegue

1. Clonar este repositorio.
2. Ejecutar el script `deploy.sh` para desplegar la infraestructura y subir los scripts necesarios a la instancia EC2.
3. Utilizar las rutas del API Gateway para subir videos y consultar resultados.

## Propósito del Proyecto

Este proyecto fue desarrollado como parte de un reto para automatizar el procesamiento de videos y la detección de actores y actrices. La infraestructura está diseñada para ser escalable y modular, permitiendo adaptaciones futuras para otros casos de uso relacionados con el procesamiento de datos multimedia.