import os
from flask import Flask
import requests
import xml.etree.ElementTree as ET
from names_dataset import NameDataset
from pytrends.request import TrendReq
from dotenv import load_dotenv
from openai import OpenAI
import json

load_dotenv()

app = Flask(__name__)
ai_client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

@app.route("/people/ranking")
def get_people_ranking():
    url = "https://trends.google.es/trends/trendingsearches/daily/rss?geo=ES"

    response = requests.get(url)

    if response.status_code == 200:
        root = ET.fromstring(response.content)

        namespace = {"atom": "http://www.w3.org/2005/Atom", "ht": "https://trends.google.es/trends/trendingsearches/daily"}

        topics = root.findall(".//channel/item", namespace)

        topics_info = []
        for topic in topics:
            title_element = topic.find("title", namespace)
            if title_element is not None:
                person_name = title_element.text
                news_item = topic.find(".//ht:news_item", namespace)
                if news_item is not None:
                    news_title = news_item.find("ht:news_item_title", namespace).text
                    news_snippet = news_item.find("ht:news_item_snippet", namespace).text
                    topics_info.append({"name": person_name, "news_title": news_title, "news_snippet": news_snippet})

        return filter_and_summarize(topics_info)
    else:
        return "Failed to retrieve info!!!!"
    
def filter_and_summarize(topics_info):
    completion1 = ai_client.chat.completions.create(
        model="gpt-3.5-turbo-0125",
        response_format={ "type": "json_object" },
        messages=[
            {"role": "system", "content": 'El usuario te va a pasar un array de términos que son tendencia ahora mismo en España, cada término será un objeto JSON que tiene name (término), news_snippet y news_title (información de noticias de por qué es tendencia). Necesito que me devuelvas la lista quitando aquellos términos que no correspondan a personas o famosos (ejemplo: "name": “Juana Pérez alcaldesa”, "name": "Antonio", "name": "Mourinho" o "name": “Morat" sí, pero "name": “Real Madrid” o "name": "Eurovisión" no), basándote en el término en sí pero también el contexto que te da la información de noticias. El formato tiene que ser algo así: {"result": [“Aitana”, "Zapatero presidente", "Morat", "Juan Rodríguez"]}'},
            {"role": "user", "content": json.dumps(topics_info)}
        ]
    )

    response1 = json.loads(completion1.choices[0].message.content)

    people = response1['result']

    people_info = list(filter(lambda x: x['name'] in people, topics_info))

    completion2 = ai_client.chat.completions.create(
        model="gpt-3.5-turbo-0125",
        response_format={ "type": "json_object" },
        messages=[
            {"role": "system", "content": 'El usuario te va a pasar un array de personas o famosos que son tendencia ahora mismo en España, cada elemento de la lista será un objeto JSON que tiene name, news_snippet y news_title (información de noticias de por qué es tendencia). Necesito que me generes un objeto JSON con el nombre y un texto que explique por qué esa persona está en tendencia ahora mismo, basándote en la información que te provee news_snippet y news_title, y tu sentido común. El formato tiene que ser algo así: {"result": [{“name”: “Aitana”, “why”: “Se la ha visto recientemente con su expareja, el cantante Sebastián Yatra, meses después de su ruptura. Ella no ha hecho declaraciones. Además, saca una nueva canción en las próximas semanas, Este single es la primera muestra de que sería su tercer trabajo discográfico”}, {“name”: "Zapatero presidente", “why”: “Ha anunciado recientemente que se va a presentar a las primarias del PSOE para ser el candidato del partido a las elecciones generales, con intención de convertirse de nuevo en presidente del gobierno. Está recibiendo mucho apoyo de los militantes y está el primero en las encuestas.”}]}'},
            {"role": "user", "content": json.dumps(people_info)}
        ]
    )

    response2 = json.loads(completion2.choices[0].message.content)

    return response2['result']


    
@app.route("/people/<person>/history")
def get_person_history(person):
    pytrends = TrendReq(hl="es")
    pytrends.build_payload([person], cat=0, timeframe="today 5-y", geo="ES")

    return pytrends.interest_over_time()[person].to_json()