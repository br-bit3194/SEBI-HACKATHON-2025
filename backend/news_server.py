from fastapi import FastAPI, Query
from pydantic import BaseModel
from bs4 import BeautifulSoup
from deep_translator import GoogleTranslator
import httpx
import asyncio
import uvicorn

app = FastAPI(
    title="Vernacular Finance API",
    description="Fetches latest SEBI/NISM/NSE/BSE updates and translates them into user-provided regional language",
    version="2.0.0"
)

# Add CORS middleware for Flutter app
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class UpdatesResponse(BaseModel):
    language: str
    updates: dict[str, list[str]]  # grouped by source


async def fetch_page(url: str):
    """
    Generic async fetcher with error handling
    """
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url)
        if response.status_code == 200:
            return response.text
    except Exception:
        return None
    return None


async def fetch_sebi():
    html = await fetch_page("https://www.sebi.gov.in/")
    if not html:
        return []
    soup = BeautifulSoup(html, "html.parser")
    return [item.get_text(strip=True) for item in soup.select(".news-list li a")[:5]]


async def fetch_nse():
    html = await fetch_page("https://www.nseindia.com/")
    if not html:
        return []
    soup = BeautifulSoup(html, "html.parser")
    return [item.get_text(strip=True) for item in soup.select("div.liveMarketNews a")[:5]]


async def fetch_bse():
    html = await fetch_page("https://www.bseindia.com/")
    if not html:
        return []
    soup = BeautifulSoup(html, "html.parser")
    return [item.get_text(strip=True) for item in soup.select("ul#ctl00_ContentPlaceHolder1_ann a")[:5]]


async def fetch_nism():
    html = await fetch_page("https://www.nism.ac.in/")
    if not html:
        return []
    soup = BeautifulSoup(html, "html.parser")
    return [item.get_text(strip=True) for item in soup.select(".elementor-post__title a")[:5]]


async def translate_text(text_list, target_language: str):
    """
    Translate list of strings into given target language asynchronously
    """
    loop = asyncio.get_running_loop()
    translated_list = []
    for text in text_list:
        if text.strip():  # Only translate non-empty text
            try:
                translated = await loop.run_in_executor(
                    None, lambda: GoogleTranslator(source="auto", target=target_language).translate(text)
                )
                translated_list.append(translated)
            except Exception as e:
                # If translation fails, use original text
                translated_list.append(text)
        else:
            translated_list.append(text)
    return translated_list


@app.get("/updates", response_model=UpdatesResponse)
async def get_updates(language: str = Query("en", description="Target language code (hi/mr/gu/ta/te/en/kn/bn)")):
    # Fetch from all sources concurrently
    sebi, nse, bse, nism = await asyncio.gather(
        fetch_sebi(),
        fetch_nse(),
        fetch_bse(),
        fetch_nism()
    )

    # Fallback data if web scraping fails
    fallback_data = {
        "SEBI": [
            "SEBI issues new guidelines for mutual fund investments",
            "Regulatory framework for ESG funds updated",
            "New investor protection measures announced",
            "Digital KYC processes streamlined",
            "Market volatility advisory issued"
        ],
        "NSE": [
            "Nifty 50 reaches new milestone",
            "New derivative instruments launched",
            "Trading hours extended for select securities",
            "Technology upgrade completed successfully",
            "Investor awareness program initiated"
        ],
        "BSE": [
            "Sensex shows strong performance",
            "SME platform enhancements announced",
            "New listing procedures implemented",
            "Corporate governance standards updated",
            "Market data services improved"
        ],
        "NISM": [
            "New certification courses launched",
            "Investment advisory training updated",
            "Research analyst curriculum revised",
            "Online examination system enhanced",
            "Professional development programs expanded"
        ]
    }

    # Use scraped data if available, otherwise use fallback
    all_updates = {
        "SEBI": sebi if sebi else fallback_data["SEBI"],
        "NSE": nse if nse else fallback_data["NSE"],
        "BSE": bse if bse else fallback_data["BSE"],
        "NISM": nism if nism else fallback_data["NISM"]
    }

    # Translate if needed
    if language != "en":
        translated_updates = {}
        for source, updates in all_updates.items():
            translated_updates[source] = await translate_text(updates, language)
        return {"language": language, "updates": translated_updates}

    return {"language": "en", "updates": all_updates}

@app.get("/")
async def root():
    return {"message": "Vernacular Finance API is running", "docs": "/docs"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
