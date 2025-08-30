import os
import json
import faiss
import numpy as np
import google.generativeai as genai
from adktools import adk_tool

from ..core.config import settings

# Configure Gemini
genai.configure(api_key=settings.GEMINI_API_KEY)

def load_faiss_index(index_dir_path=settings.FAISS_INDEX_DIR_PATH):
    """Load FAISS index and docs.pkl correctly."""
    import pickle
    index = faiss.read_index(os.path.join(index_dir_path, settings.FAISS_INDEX_FILENAME))
    with open(os.path.join(index_dir_path, settings.FAISS_CORRESPONDING_DOCS_FILENAME), "rb") as f:
        docs = pickle.load(f)  # use pickle.load, NOT readlines
    return index, docs


def embed_text(text: str) -> list[float]:
    """Use Gemini to create embeddings for a query."""
    response = genai.embed_content(
        model=settings.GOOGLE_GENAI_EMBEDDINGS_MODEL,
        content=text,
        task_type="retrieval_query"
    )
    return response['embedding']

@adk_tool(
  name="retrieve_context",
  description="Fetches relevant table schema/docs using FAISS."
)
def get_table_information(concised_question: str, top_k: int = 5) -> str:
    """Retrieve relevant table chunks using Gemini + FAISS."""
    index, docs = load_faiss_index()
    question_embedding = embed_text(concised_question)

    # Search top_k similar docs
    D, I = index.search(np.array([question_embedding]).astype('float32'), top_k)

    results = []
    for i in I[0]:
        if i < len(docs):
            results.append(json.dumps(docs[i]).strip())

    if not results:
        return "No relevant documents found."

    table_information = "Following are the relevant docs I found:\n\n"
    table_information += "\n\n---\n\n".join(results)
    return table_information