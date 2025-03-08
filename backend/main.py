from fastapi import FastAPI, Depends, HTTPException, status, Body
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import uvicorn
from uuid import uuid4

# Security settings
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 scheme
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Models
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserBase(BaseModel):
    username: str
    email: Optional[str] = None

class UserCreate(UserBase):
    password: str
    full_name: Optional[str] = None

class User(UserBase):
    id: str
    disabled: Optional[bool] = None

    class Config:
        from_attributes = True  # Updated from orm_mode

class CounterBase(BaseModel):
    title: str
    count: int

class CounterUpdate(BaseModel):
    count: int

class Counter(CounterBase):
    id: str
    owner_id: str

    class Config:
        from_attributes = True  # Updated from orm_mode

# Fake DB
fake_users_db = {}
fake_counters_db = {}

# Helper functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return User(**user_dict)
    return None

def authenticate_user(db, username: str, password: str):
    user = get_user(db, username)
    if not user:
        return False
    if not verify_password(password, db[username]["password"]):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# FastAPI app
app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# API Routes
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/register", response_model=User)
async def register_user(user: UserCreate):
    if user.username in fake_users_db:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    user_id = str(uuid4())
    hashed_password = get_password_hash(user.password)
    fake_users_db[user.username] = {
        "id": user_id,
        "username": user.username,
        "email": user.email,
        "password": hashed_password,
        "disabled": False
    }
    return get_user(fake_users_db, user.username)

# Updated to accept any JSON
@app.post("/auth/register", status_code=status.HTTP_201_CREATED)
async def auth_register(user_data: Dict[str, Any] = Body(...)):
    # Check for required fields
    if "username" not in user_data or "password" not in user_data:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Username and password are required"
        )

    username = user_data.get("username")
    password = user_data.get("password")
    email = user_data.get("email", "")
    full_name = user_data.get("full_name", "")

    if username in fake_users_db:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )

    user_id = str(uuid4())
    hashed_password = get_password_hash(password)

    user_record = {
        "id": user_id,
        "username": username,
        "email": email,
        "password": hashed_password,
        "full_name": full_name,
        "disabled": False
    }

    fake_users_db[username] = user_record

    # Generate token for immediate login
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": username}, expires_delta=access_token_expires
    )

    return {
        "id": user_id,
        "username": username,
        "email": email,
        "full_name": full_name,
        "disabled": False,
        "access_token": access_token,
        "token_type": "bearer"
    }

@app.post("/auth/login")
async def auth_login(user_data: Dict[str, Any] = Body(...)):
    if "username" not in user_data or "password" not in user_data:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Username and password are required"
        )

    username = user_data.get("username")
    password = user_data.get("password")

    user = get_user(fake_users_db, username)
    if not user or not verify_password(password, fake_users_db[username]["password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password"
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": username}, expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": fake_users_db[username]["id"],
            "username": username,
            "email": fake_users_db[username]["email"],
            "disabled": fake_users_db[username]["disabled"]
        }
    }

# Debug endpoint to see what data is being sent
@app.post("/debug")
async def debug_endpoint(data: Dict[str, Any] = Body(...)):
    return {"received": data}

@app.get("/users/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@app.get("/")
def read_root():
    return {"message": "Welcome to StudyHub Backend"}

@app.get("/counters", response_model=List[Counter])
def get_counters(current_user: User = Depends(get_current_active_user)):
    user_counters = []
    for counter_id, counter in fake_counters_db.items():
        if counter["owner_id"] == current_user.id:
            user_counters.append(Counter(**counter))
    return user_counters

@app.get("/counters/{counter_id}", response_model=Counter)
def get_counter(counter_id: str, current_user: User = Depends(get_current_active_user)):
    if counter_id not in fake_counters_db:
        raise HTTPException(status_code=404, detail="Counter not found")
    counter = fake_counters_db[counter_id]
    if counter["owner_id"] != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to access this counter")
    return Counter(**counter)

@app.post("/counters/{counter_id}", response_model=Counter)
def update_counter(counter_id: str, counter: CounterUpdate, current_user: User = Depends(get_current_active_user)):
    if counter_id not in fake_counters_db:
        raise HTTPException(status_code=404, detail="Counter not found")
    counter_data = fake_counters_db[counter_id]
    if counter_data["owner_id"] != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this counter")
    counter_data["count"] = counter.count
    return Counter(**counter_data)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)