from pymongo import MongoClient
from django.conf import settings

class MongoDBConnection:
    _db = None

    @staticmethod
    def get_client():
        return MongoClient(settings.MONGO_DB_URI)
       
    @staticmethod
    def get_db():
        if MongoDBConnection._db is None:
            client = MongoDBConnection.get_client()
            MongoDBConnection._db = client[settings.MONGO_DB_NAME]
        return MongoDBConnection._db

    @staticmethod
    def get_entregas_collection():
        db = MongoDBConnection.get_db()
        return db["archivos_entregas"]

    @staticmethod
    def get_anuncios_collection():
        db = MongoDBConnection.get_db()
        return db["archivos_anuncio"]
    
