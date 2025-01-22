from redis import Redis
# from dotenv import load_dotenv
from os import getenv

# load_dotenv()

REDIS_HOST=getenv('REDIS_HOST')
REDIS_PASSWORD=getenv('REDIS_PASSWORD')

cache = Redis(
    host=REDIS_HOST,
    port=6379,
    password=REDIS_PASSWORD,
    ssl=True
)