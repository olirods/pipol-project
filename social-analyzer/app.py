import os
from flask import Flask
import requests
import xml.etree.ElementTree as ET
from dotenv import load_dotenv
from openai import OpenAI
import json
from twikit import Client
from collections import Counter

load_dotenv()

HG_API_URL = "https://api-inference.huggingface.co/models/daveni/twitter-xlm-roberta-emotion-es"
hg_api_token = os.environ.get("HG_API_TOKEN")
hg_headers = {"Authorization": f"Bearer {hg_api_token}"}

app = Flask(__name__)
ai_client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
twitter_client = Client('es-ES')
twitter_client.login(
    auth_info_1=os.environ.get("TWITTER_USERNAME") ,
    auth_info_2=os.environ.get("TWITTER_EMAIL"),
    password=os.environ.get("TWITTER_PASSWORD")
)
    
@app.route("/people/<person>/emotions")
def get_emotions(person):
    tweets = map(lambda tweet: tweet.text, twitter_client.search_tweet(person, 'Top'))

    emotions = list(map(lambda tweet: emotion_analysis(tweet)[0][0]['label'], tweets))

    return calculate_proportions(emotions)

def calculate_proportions(arr):
    counter = Counter(arr)
    total_items = len(arr)
    proportions = {key: value/total_items for key, value in counter.items()}
    return proportions

def emotion_analysis(tweet):
    payload = {"inputs": tweet}
    response = requests.post(HG_API_URL, headers=hg_headers, json=payload)
	
    return response.json()
