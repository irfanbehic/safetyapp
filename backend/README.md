# SafeMap Backend (FastAPI)

## Kurulum

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Çalıştırma

```bash
uvicorn main:app --reload
```

## Endpointler
- `/regions` : Tüm bölgeler ve haberler (JSON)
- `/regions/geojson` : GeoJSON poligonları
- `/region/{name}` : Tekil bölge detayı