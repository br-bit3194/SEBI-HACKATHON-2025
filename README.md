# SEBI-HACKATHON-2025
Enhancing Retail Investor Education and Engagement

## Backend setup:
0. Go to SEBI-HACKATHON-2025 dir.
1. make .env file from .env.backup file. Set GEMINI_API_KEY env var.
2. create python virtual environment
```sh
python -m venv env
```
3. activate the environment
For windows
```sh
env\Scripts\activate
```

For Ubuntu
```sh
source env/bin/activate
```

4. Install the packages
```sh
pip install -r requirements.txt
```

5. Start the BE fastapi service
```sh
uvicorn src.main:app
```

## Dockerized setup:

1. Follow same above 0 & 1 steps.

2. Build docker image
```sh
docker build -t sebi-backend .
```

3. Start the docker container:
```sh
docker run -p 8000:8000 --name sebi-container sebi-backend
```
