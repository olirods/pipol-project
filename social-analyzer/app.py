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
    try:
        tweets = map(lambda tweet: tweet.text, twitter_client.search_tweet(person, 'Top'))
    except Exception as e:
        print(f"Error occurred while fetching tweets: {e}")
        tweets = [
            "No puedo creer lo inspirador que es Elon Musk. ¡Su visión para el futuro es realmente notable! #Inspiración",
            "Elon Musk me frustra a veces. ¿Por qué tiene que tuitear cosas tan controversiales? #Molesto",
            "Me siento tan agradecido por las contribuciones de Elon Musk a la tecnología. ¡SpaceX y Tesla están cambiando el mundo! #Gratitud",
            "Estoy tan enojado por la última decisión de Elon Musk. Siento que no le importan las personas comunes. #Enojado",
            "¡Elon Musk es un genio! No puedo esperar a ver qué se le ocurre a continuación. #Emocionado",
            "Me siento muy confundido por las declaraciones recientes de Elon Musk. ¿Qué está tratando de lograr? #Confundido",
            "Elon Musk me da esperanza para el futuro. Su trabajo en energía renovable es tan importante. #Esperanzado",
            "Estoy realmente preocupado por la influencia de Elon Musk en las redes sociales. A veces parece bastante imprudente. #Preocupado",
            "Me encanta cómo Elon Musk está empujando los límites de lo que es posible. ¡El proyecto Hyperloop es fascinante! #MeEncanta",
            "Decepcionado con Elon Musk hoy. Esperaba más de alguien tan influyente. #Decepcionado"
        ]

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
