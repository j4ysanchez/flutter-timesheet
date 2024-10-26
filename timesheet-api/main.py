from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from sqlalchemy import create_engine, Column, Integer, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

app = FastAPI()

DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Timestamp(Base):
    __tablename__ = "timestamps"
    id = Column(Integer, primary_key=True, index=True)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)
    start_latitude = Column(Float, nullable=False)
    start_longitude = Column(Float, nullable=False)
    end_latitude = Column(Float, nullable=True)
    end_longitude = Column(Float, nullable=True)

Base.metadata.create_all(bind=engine)

class TimestampCreate(BaseModel):
    start_time: datetime
    end_time: datetime = None
    start_latitude: float
    start_longitude: float
    end_latitude: float = None
    end_longitude: float = None

class TimestampResponse(TimestampCreate):
    id: int

    class Config:
        orm_mode = True

@app.post("/timestamps/", response_model=TimestampResponse)
def create_timestamp(timestamp: TimestampCreate):
    db = SessionLocal()
    db_timestamp = Timestamp(**timestamp.dict())
    db.add(db_timestamp)
    db.commit()
    db.refresh(db_timestamp)
    db.close()
    return db_timestamp

@app.get("/timestamps/", response_model=List[TimestampResponse])
def read_timestamps(skip: int = 0, limit: int = 10):
    db = SessionLocal()
    timestamps = db.query(Timestamp).offset(skip).limit(limit).all()
    db.close()
    return timestamps