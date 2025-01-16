from redis import Redis
from dotenv import load_dotenv
from os import getenv

load_dotenv()

REDIS_PASSWORD=getenv('REDIS_PASSWORD')

r = Redis(
    host='hot-dove-50927.upstash.io',
    port=6379,
    password=REDIS_PASSWORD,
    ssl=True
)