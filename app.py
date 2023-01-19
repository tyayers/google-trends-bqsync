import os
import web
import requests
import json
import time
from datetime import datetime, timedelta
from google.cloud import storage, bigquery
from pytrends.request import TrendReq

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import google.auth

urls = (
    '/trends/(.*)', 'terms_manager',
    '/initial(.*)', 'data_initial_load',
    '/latest(.*)', 'data_latest',
    '/growth_rates(.*)', 'data_growth'
)
app = web.application(urls, globals())

if not firebase_admin._apps:
  cred = credentials.ApplicationDefault()
  firebase_admin.initialize_app(cred, {
    'projectId': cred.project_id,
  })

class terms_manager:
    db = firestore.client()

    def GET(self, topic):

        new_result = {}

        doc_ref = self.db.collection('trends').document(topic)
        doc = doc_ref.get().to_dict()
        
        print(doc)

        new_result = {
            "terms": []
        }

        if doc:
            for term in doc["terms"]:
                new_result["terms"].append(term)

        web.header('Access-Control-Allow-Origin', '*')
        if new_result:
            web.header('Content-Type', 'application/json')
            return json.dumps(new_result)
        else:
            return web.notfound("Not found")        
        
class data_growth:
    def GET(self, site):
        bucketName = os.getenv('BUCKET_NAME')
        table = os.getenv('TABLE_NAME')
        
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucketName)
        
        result = self.load(bucket, table)
        
        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        
        return json.dumps({"result": "Success"})

    def load(self, bucket, table):
        client = bigquery.Client()
        query = "SELECT * FROM `" + table + "` LIMIT 1000"
        
        query_job = client.query(query)  # Make an API request.

        result = []
        for row in query_job:
            # Row values can be accessed by field name or index.
            result.append({
                "name": row["name"],
                "date": str(row["date"]),
                "growth_rate": row["agg_growth"],
                "trends_growth": row["trends_growth"],
                "news_growth": row["news_growth"]
            })

        d = bucket.blob("output/growth_rates.json")
        d.upload_from_string(json.dumps(result))
        
        return result
        
class data_latest:
    def GET(self, site):
        bucketName = os.getenv('BUCKET_NAME')
        topic_singular = web.input().topic_singular
        topic_plural = web.input().topic_plural
        
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucketName)
        
        terms = get_terms(bucket, "terms")
        result = get_news_volume_latest(terms["terms"], topic_singular)

        d = bucket.blob("input/news_volume_update.csv")
        d.upload_from_string(result)

        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({"result": "Success"})

        # web.header('Content-Type', 'text/csv')
        # return result

class data_initial_load:
    def GET(self):
        bucketName = os.getenv('BUCKET_NAME')
        topic_singular = web.input().topic_singular
        topic_plural = web.input().topic_plural

        storage_client = storage.Client()
        bucket = storage_client.bucket(bucketName)
        
        result = self.load(bucket, topic_singular, topic_plural)

        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({"result": "Success"})

        # web.header('Content-Type', 'text/csv')
        # return result
        
    def load(self, bucket, topic_singular, topic_plural): 
        terms = get_terms(bucket, "terms")
        result = get_news_volume(terms["terms"], topic_singular)
        
        d = bucket.blob("input/news_volume_initial.csv")
        d.upload_from_string(result)
        
        return result

class trends_initial_load:
    def GET(self, site):
        bucketName = os.getenv('BUCKET_NAME')
        topic_singular = web.input().topic_singular
        topic_plural = web.input().topic_plural
        
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucketName)
        
        result = self.load(bucket, topic_singular, topic_plural)

        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({"result": "Success"})

    def load(self, bucket, topic_singular, topic_plural):
        terms = get_terms(bucket, "terms")

        result = get_trends_initial(terms["terms"], terms["geos"], topic_singular)

        d = bucket.blob("input/trend_scores_initial.csv")
        d.upload_from_string(result)

        return result

class trends_latest:
    def GET(self, site):
        bucketName = os.getenv('BUCKET_NAME')
        print(bucketName)
        topic_singular = web.input().topic_singular
        topic_plural = web.input().topic_plural
        
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucketName)
        
        terms = get_terms(bucket, "terms")
        result = get_trends_latest(terms["terms"], terms["geos"], topic_singular)

        print("Writing trend updates to disk...")
        f = open("trend_scores_update.csv", "w")
        f.write(result)
        f.close()

        print("Writing trend updates to cloud storage...")
        d = bucket.blob("input/trend_scores_update.csv")
        d.upload_from_string(result)

        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({"result": "Success"})

def get_terms(bucket, key):
    terms = []
    geos = ["WORLD"]

    blob = bucket.blob("output/topic_entities.json")
    data = json.loads(blob.download_as_string())

    for term in data[key]:
        name = term["Name"]
        name = name.replace("-", " ")
        name_pieces = name.split(" ")
        name = ""
        for name_piece in name_pieces:
            if len(name_piece) > 2:
              name = name + " " + name_piece.replace(",", "")
            
        # name = name.replace(", ", " ").replace(" or ", "").replace(" in 
        terms.append(name)

    if "geos" in data:
        geos = data["geos"]

    print(terms)

    return {
      "geos": geos,
      "terms": terms
    }

def get_news_volume(terms, topic_singular):
    result = ""
    for term in terms:
        query = ""
        queryWords = term.split(" ")
        for word in queryWords:
            tempWord = word.lower().replace(",", "").replace(".", "").replace(
                " or ", "").replace(" and ", "").replace("-", " ").replace("(", "").replace(")", "").replace("aka", "")

            if len(tempWord) > 2:
                tempWord = tempWord.replace(" ", "%20")
                if (query == ""):
                    query = tempWord
                else:
                    query = query + "%20" + tempWord

        print('Searching GDELT for ', query)

        url = 'https://api.gdeltproject.org/api/v2/doc/doc?query=' + \
            query + \
            '%20' + topic_singular + '&mode=timelinevolraw&format=json'
        vol = requests.get(url)

        volData = vol.json()
        if "timeline" in volData:
        
            print('Found ', len(volData["timeline"][0]["data"]), ' records')
            for day in volData["timeline"][0]["data"]:
                if result != "":
                    result = result + "\n"

                result = result + term.replace(",", "") + "," + day["date"] + "," + \
                    str(day["value"]) + "," + str(day["norm"])

        time.sleep(.3)

    return result

def get_news_volume_latest(terms, topic_singular):
    result = ""
    yesterday_string = datetime.strftime(
        datetime.now() - timedelta(1), '%Y%m%d') + "T000000Z"
    for term in terms:
        query = ""
        queryWords = term.split(" ")
        for word in queryWords:
            tempWord = word.lower().replace(",", "").replace(".", "").replace(
                " or ", "").replace(" and ", "").replace("-", " ").replace("(", "").replace(")", "").replace("aka", "")

            if len(tempWord) > 2:
                tempWord = tempWord.replace(" ", "%20")
                
                if (query == ""):
                    query = tempWord
                else:
                    query = query + "%20" + tempWord

        url = 'https://api.gdeltproject.org/api/v2/doc/doc?query=' + \
            query + \
            '%20' + topic_singular + '&mode=timelinevolraw&format=json&TIMESPAN=1w'
        vol = requests.get(url)

        volData = vol.json()
        if "timeline" in volData and len(volData["timeline"]) > 0:
            for day in volData["timeline"][0]["data"]:

                # Only get yesterday's value...
                if str(day["date"]) == yesterday_string:
                    if result != "":
                        result = result + "\n"

                    result = result + term.replace(",", "") + "," + day["date"] + "," + \
                        str(day["value"]) + "," + str(day["norm"])

        time.sleep(.2)

    return result

def get_trends_initial(terms, geos, topic_singular):
    result = ""
    pytrends = TrendReq(hl='en-US', tz=60, retries=8, timeout=(10,25), backoff_factor=0.8)

    for term in terms:
        kw_list = [term + " " + topic_singular]

        for geo in geos:
            new_geo = ""
            if geo != "WORLD":
                new_geo = geo

            pytrends.build_payload(kw_list, cat=0, timeframe='today 5-y', geo=new_geo, gprop='')
            df = pytrends.interest_over_time()

            for row in df.itertuples():
                if result != "":
                    result = result + "\n"

                new_line = geo + "," + term.replace(",", "") + "," + str(row.Index.date()) + "," + str(row[1])
                result = result + new_line
                print(new_line)

    return result

def get_trends_latest(terms, geos, topic_singular):
    result = ""
    pytrends = TrendReq(hl='en-US', tz=60, retries=8, timeout=(10,25), backoff_factor=0.8)

    for term in terms:
        kw_list = [term + " " + topic_singular]

        for geo in geos:
            new_geo = ""
            if geo != "WORLD":
                new_geo = geo

            pytrends.build_payload(kw_list, cat=0, timeframe='today 1-m', geo=new_geo, gprop='')
            df = pytrends.interest_over_time()

            for row in df.itertuples():
                if result != "":
                    result = result + "\n"

                new_line = geo + "," + term.replace(",", "") + "," + str(row.Index.date()) + "," + str(row[1])
                result = result + new_line
                print(new_line)

    return result
if __name__ == "__main__":
    app.run()