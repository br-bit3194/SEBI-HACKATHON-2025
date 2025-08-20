
import os
import google.generativeai as genai
from google.adk.agents import Agent
from google.generativeai.types import GenerationConfig

from ..tools.retriever import get_table_information
from ..tools.executor import query_executor
from ..core.config import settings
from ..prompts import SYSTEM_PROMPT
from ..core.loggers import LoggerSingleton

genai.configure(api_key=settings.GEMINI_API_KEY)

logger = LoggerSingleton.get_instance()

def get_chat_agent(session_id=None):
    return Agent(
            name="table_sql_agent",
            model=settings.GEMINI_MODEL_NAME,
            description="Helps users query tables via SQL using FAISS context and BigQuery.",
            instruction=SYSTEM_PROMPT,
            tools=[get_table_information, query_executor],
            output_key="final_answer",  # optional state saving
            # output_schema=Response,
            generate_content_config=GenerationConfig(temperature=settings.GEMINI_MODEL_TEMPERATURE)
        )
