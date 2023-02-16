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
    '/trends/(.*)/refresh', 'refresh_manager',
    '/trends/(.*)/initial', 'initial_manager',
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

class refresh_manager:
    db = firestore.client()
    bq = client = bigquery.Client()
    
    def POST(self, topic):
        # Start refresh...
        doc_ref = self.db.collection('trends').document(topic)
        doc = doc_ref.get().to_dict()
        
        print("starting refresh")

        get_trends_latest(doc["terms"], doc["geos"], topic)
        
        print("finished refresh")
        self.db.collection('trends').document(topic).set(doc)
        
        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps(doc)
    
    def insertToBigQuery(self, terms):
        rows_to_insert = []

        for term in terms:
            for rec in term["data"]:
                rows_to_insert.append(rec)

        errors = self.bq.insert_rows_json(os.environ.get('TRENDS_TABLE'), rows_to_insert)
        if errors == []:
            print("New rows have been added.")
        else:
            print("Encountered errors while inserting rows: {}".format(errors))
        
class initial_manager:
    db = firestore.client()
    bq = client = bigquery.Client()
    
    def POST(self, topic):
        data = None
        if web.data():
            data = json.loads(web.data())

        terms = []
        geos = []

        if data:
            print("found data in post body")
            terms = data["terms"]
            geos = data["geos"]
        else:
            # Start refresh...
            doc_ref = self.db.collection('trends').document(topic)
            doc = doc_ref.get().to_dict()
            terms = doc["terms"]
            geos = doc["geos"]
        
        print("starting initial")

        get_trends_all(terms, geos)
        
        print("finished initial, writing output file")
        f = open("trends_output.json", "w")
        f.write(json.dumps(terms))
        f.close()        
        
        self.insertToBigQuery(terms)

        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({
            "result": "Ok"
        })
    
    def insertToBigQuery(self, terms):
        
        for term in terms:
            rows_to_insert = []

            for rec in term["data"]:
                rows_to_insert.append(rec)

            if len(rows_to_insert) > 0:
                errors = self.bq.insert_rows_json(os.environ.get('TRENDS_TABLE'), rows_to_insert)
                if errors == []:
                    print("Added rows to " + os.environ.get('TRENDS_TABLE') + " for term " + term["name"])
                else:
                    print("Encountered errors while inserting rows: {}".format(errors))
            else:
                print("No rows to add for term " + term["name"])

class terms_manager:
    db = firestore.client()

    def GET(self, topic):

        new_result = {}

        doc_ref = self.db.collection('trends').document(topic)
        doc = doc_ref.get().to_dict()
        
        print(doc)

        if "geos" not in doc:
            doc["geos"] = []
            
        if "terms" not in doc:
            doc["terms"] = []

        web.header('Access-Control-Allow-Origin', '*')
        if doc:
            web.header('Content-Type', 'application/json')
            return json.dumps(doc)
        else:
            return web.notfound("Not found")

    def POST(self, topic):

        data = json.loads(web.data())
        
        doc_ref = self.db.collection('trends').document(topic)
        doc = doc_ref.get().to_dict()
        
        doc["terms"] = data["terms"]
        self.db.collection('trends').document(topic).set(doc)
        
        web.header('Access-Control-Allow-Origin', '*')
        web.header('Content-Type', 'application/json')
        return json.dumps({"result": "OK"})
        
def get_trends_latest(terms, geos, topic_singular):
    result = ""
    pytrends = TrendReq(hl='en-US', tz=60, retries=8, timeout=(10,25), backoff_factor=0.8)

    for term in terms:
        kw_list = [term["name"]]
        term["data"] = []
        
        for geo in geos:
            new_geo = ""
            if geo != "WORLD":
                new_geo = geo

            pytrends.build_payload(kw_list, cat=0, timeframe='now 7-d', geo=new_geo, gprop='')
            df = pytrends.interest_over_time()

            row = {}
            for row in df.itertuples():
                row = {
                    "geo": geo,                    
                    "name": term["name"],
                    "date": str(row.Index.date()),                    
                    "score": row[1]
                }
        
            print(row)
                        
            if row != {}:
                term["data"].append(row)

    return result

def get_trends_all(terms, geos):
    result = ""
    pytrends = TrendReq(hl='en-US', tz=60, retries=8, timeout=(10,25), backoff_factor=0.8)

    for term in terms:
        kw_list = [term["name"]]
        term["data"] = []
        
        for geo in geos:
            new_geo = ""
            if geo != "WORLD":
                new_geo = geo

            pytrends.build_payload(kw_list, cat=0, timeframe='today 5-y', geo=new_geo, gprop='')
            df = pytrends.interest_over_time()

            row = {}
            for row in df.itertuples():

                print("adding row " + geo + " " + term["name"] + " " + str(row.Index.date()))

                row = {
                    "geo": geo,                    
                    "name": term["name"],
                    "date": str(row.Index.date()),                    
                    "score": row[1]
                }

                term["data"].append(row)

    return result

if __name__ == "__main__":
    app.run()