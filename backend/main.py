from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, FileResponse
import json
import os

app = FastAPI(title="SafeMap API", version="0.1")

DATA_DIR = os.path.dirname(os.path.abspath(__file__))

@app.get("/regions")
def get_regions():
    with open(os.path.join(DATA_DIR, "regions.json"), encoding="utf-8") as f:
        data = json.load(f)
    return data

@app.get("/regions/geojson")
def get_regions_geojson():
    return FileResponse(os.path.join(DATA_DIR, "regions.geojson"), media_type="application/json")

@app.get("/region/{name}")
def get_region(name: str):
    with open(os.path.join(DATA_DIR, "regions.json"), encoding="utf-8") as f:
        data = json.load(f)
    for region in data:
        if region["name"].lower() == name.lower():
            return region
    raise HTTPException(status_code=404, detail="Region not found")