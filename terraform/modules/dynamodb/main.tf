resource "aws_dynamodb_table" "movie_entities" {
  name         = "MovieEntities"
  billing_mode = "PROVISIONED"

  read_capacity  = 10
  write_capacity = 10

  hash_key  = "MovieName"
  range_key = "EntityType#EntityName"

  attribute {
    name = "MovieName"
    type = "S"
  }

  attribute {
    name = "EntityType#EntityName"
    type = "S"
  }

  attribute {
    name = "Genre"
    type = "S"
  }

  attribute {
    name = "Director"
    type = "S"
  }

  attribute {
    name = "ProcessingDate"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI_Entity"
    hash_key        = "EntityType#EntityName"
    range_key       = "MovieName"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  global_secondary_index {
    name            = "GSI_Genre"
    hash_key        = "Genre"
    range_key       = "MovieName"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  global_secondary_index {
    name            = "GSI_ProcessingDate"
    hash_key        = "ProcessingDate"
    range_key       = "MovieName"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  global_secondary_index {
    name            = "GSI_Director"
    hash_key        = "Director"
    range_key       = "MovieName"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }
}