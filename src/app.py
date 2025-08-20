from fastapi import APIRouter, status, Request, UploadFile, File
from fastapi.responses import JSONResponse
import json

from .core.utils import error_object
from .core.loggers import LoggerSingleton
from pydantic import BaseModel

# Route to handle file upload and trigger analysis pipeline
from .agents.chat import get_chat_agent
 
# get the logger
logger = LoggerSingleton.get_instance()

# init api router
api_router = APIRouter()

class SearchRequst(BaseModel):
    question: str

@api_router.get("/")
def healthcheck():
    return JSONResponse(content={"status": "Success"}, status_code=status.HTTP_200_OK)


@api_router.post("/upload_docs")
async def upload_docs(request: Request, file: UploadFile = File(...)):
    request_id = request.state.request_id
    try:
        response = {
            "status": "Success",
            "message": "File uploaded successfully."
        }
        return JSONResponse(content=response, status_code=status.HTTP_200_OK)
    
    except Exception as e:
        err_obj = error_object(request_id=request_id,
                                message=f"{str(e)}", 
                                code=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return JSONResponse(content=err_obj, status_code=err_obj["error"]["code"])

@api_router.post("/search")
async def process_search(request: Request, search_request: SearchRequst):
    request_id = request.state.request_id
    try:
        agent_executor = get_chat_agent(request_id)
        agent_response = agent_executor.invoke({'input':search_request.question})
        api_response = {}
        try:
            api_response = json.loads(agent_response['output'])
        except Exception as e:
            api_response['answer'] = agent_response['output']
            print(e)
            # return api_response
        return JSONResponse(content=api_response, status_code=status.HTTP_200_OK)
    except Exception as e:
        import traceback
        err_obj = error_object(request_id=request_id,
                                message=f"{traceback.print_exc()}", 
                                code=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return JSONResponse(content=err_obj, status_code=err_obj["error"]["code"])