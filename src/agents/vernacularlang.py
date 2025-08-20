from fastapi import FastAPI, Query
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
from googletrans import Translator

app = FastAPI(title="Vernacular Finance API",
              description="Fetches latest SEBI/NISM/Stock Exchange updates and translates them into user-provided regional language",
              version="1.0.0")


class UpdatesResponse(BaseModel):
    language: str
    updates: list[str]


def fetch_latest_info():
    """
    Scrapes latest updates from SEBI's website (extendable to NISM, NSE, BSE).
    """
    url = "https://www.sebi.gov.in/"
    response = requests.get(url)
    if response.status_code != 200:
        return []

    soup = BeautifulSoup(response.text, "html.parser")

    # Example: Get latest 5 news/circulars
    latest_news = []
    for item in soup.select(".news-list li a")[:5]:  # CSS selector may vary
        latest_news.append(item.get_text(strip=True))

    return latest_news


def translate_text(text_list, target_language):
    """
    Translate list of strings into given target language
    """
    translator = Translator()
    translated_list = []

    for text in text_list:
        translated = translator.translate(text, dest=target_language)
        translated_list.append(translated.text)

    return translated_list


@app.get("/updates", response_model=UpdatesResponse)
def get_updates(language: str = Query("en", description="Target language code (hi/mr/gu/ta/te/en)")):
    """
    Get latest SEBI/NISM/Stock Exchange updates in the specified language.
    Example: /updates?language=hi
    """
    latest_updates = fetch_latest_info()

    if not latest_updates:
        return {"language": language, "updates": ["No updates available right now."]}

    if language != "en":
        translated_updates = translate_text(latest_updates, language)
        return {"language": language, "updates": translated_updates}
    else:
        return {"language": "en", "updates": latest_updates}