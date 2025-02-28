from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(title="Flutter App Backend")

# Sample data store
counters = {"global": 0}

class Counter(BaseModel):
    id: str
    value: int

class CounterUpdate(BaseModel):
    value: int

@app.get("/")
def read_root():
    return {"message": "Welcome to Flutter App Backend"}

@app.get("/counters", response_model=List[Counter])
def get_counters():
    return [{"id": k, "value": v} for k, v in counters.items()]

@app.get("/counters/{counter_id}", response_model=Counter)
def get_counter(counter_id: str):
    if counter_id not in counters:
        counters[counter_id] = 0
    return {"id": counter_id, "value": counters[counter_id]}

@app.post("/counters/{counter_id}", response_model=Counter)
def update_counter(counter_id: str, counter: CounterUpdate):
    counters[counter_id] = counter.value
    return {"id": counter_id, "value": counters[counter_id]}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)