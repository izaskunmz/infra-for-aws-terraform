import json
import boto3
import os
from botocore.exceptions import ClientError

# Configurar conexión con AWS DynamoDB en la nube
try:
    dynamodb = boto3.resource('dynamodb', region_name=os.getenv('AWS_REGION', 'us-east-1'))
    table_name = "MovieEntities"
    table = dynamodb.Table(table_name)
    print("✅ Conexión con DynamoDB establecida correctamente.")
except ClientError as e:
    print(f"❌ Error al conectar con DynamoDB: {e}")
    exit(1)

# Campos obligatorios según tipo de registro
GENERAL_METADATA_FIELDS = ["MovieName", "EntityType#EntityName", "ProcessingDate", "Genre", "Director", "TrailerDuration", "EntityCount"]
ENTITY_FIELDS = ["MovieName", "EntityType#EntityName", "Frames"]
ELENCO_FIELDS = ["MovieName", "EntityType#EntityName", "Actors"]
OBJECTS_FIELDS = ["MovieName", "EntityType#EntityName", "Objects"]

def item_exists(table, movie_name, entity_type_entity_name):
    """ Verifica si un ítem ya existe en la tabla. """
    try:
        response = table.get_item(
            Key={
                'MovieName': movie_name,
                'EntityType#EntityName': entity_type_entity_name
            }
        )
        return 'Item' in response
    except ClientError as e:
        print(f"❌ Error al verificar existencia del ítem: {e}")
        return False

def validate_item(item):
    """ Verifica que un ítem tenga los campos correctos según su tipo. """
    entity_type = item.get("EntityType#EntityName", "")

    if entity_type == "General#Metadata":
        required_fields = GENERAL_METADATA_FIELDS
    elif entity_type == "General#Elenco":
        required_fields = ELENCO_FIELDS
    elif entity_type == "General#Objects":
        required_fields = OBJECTS_FIELDS
    else:
        required_fields = ENTITY_FIELDS

    for field in required_fields:
        if field not in item:
            print(f"⚠️ Advertencia: El campo '{field}' falta en el ítem {item}. Se ignorará.")
            return False

    return True

def batch_write_or_update(table, items):
    """ Carga o actualiza datos en lotes de 25 ítems en DynamoDB. """
    with table.batch_writer() as batch:
        for item in items:
            movie_name = item.get('MovieName', "")
            entity_type_entity_name = item.get('EntityType#EntityName', "")

            if item_exists(table, movie_name, entity_type_entity_name):
                print(f"🔄 Actualizando ítem: {movie_name} - {entity_type_entity_name}")
                table.update_item(
                    Key={'MovieName': movie_name, 'EntityType#EntityName': entity_type_entity_name},
                    UpdateExpression="SET " + ", ".join([f"{k} = :{k}" for k in item if k not in ('MovieName', 'EntityType#EntityName')]),
                    ExpressionAttributeValues={f":{k}": v for k, v in item.items() if k not in ('MovieName', 'EntityType#EntityName')}
                )
            else:
                print(f"🆕 Insertando nuevo ítem: {movie_name} - {entity_type_entity_name}")
                batch.put_item(Item=item)
    print(f"✅ {len(items)} ítems procesados correctamente.")

# **Cargar datos desde el JSON generado por el modelo de detección**
json_file_path = "/home/ubuntu/detection-model/data/resultados.json"

if not os.path.exists(json_file_path):
    print(f"❌ Error: No se encontró el archivo '{json_file_path}'.")
    exit(1)

try:
    with open(json_file_path, "r") as json_file:
        movies_data = json.load(json_file)
except json.JSONDecodeError:
    print("❌ Error: El archivo JSON está corrupto o no es válido.")
    exit(1)

# Filtrar datos válidos
valid_items = [item for item in movies_data if validate_item(item)]

# Subir datos en bloques de 25 (inserción o actualización)
batch_size = 25
for i in range(0, len(valid_items), batch_size):
    batch_write_or_update(table, valid_items[i:i+batch_size])

print("🚀 Todos los datos válidos fueron procesados con éxito en DynamoDB AWS.")