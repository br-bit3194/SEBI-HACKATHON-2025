import os
from dataclasses import dataclass
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    
    GOOGLE_GENAI_EMBEDDINGS_MODEL: str
    GEMINI_MODEL_NAME: str
    GEMINI_MODEL_TEMPERATURE: float
    GEMINI_RESPONSE_MIMETYPE: str
    GEMINI_API_KEY: str
    CONVERSATION_BUFFER_WINDOW_MEMORY: int
    DOC_RETRIEVAL_TOP_K: int
    FAISS_INDEX_DIR_PATH: str
    FAISS_INDEX_FILENAME: str
    FAISS_CORRESPONDING_DOCS_FILENAME: str
    CONTEXT_INPUT_DIR: str
    AGENT_DIR: str

    class Config:
        env_file = ".env"
        extra = "ignore"
    
# Create an instance of Settings to load environment variables
settings = Settings()