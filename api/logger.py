import logging
import logging.handlers
import os

LOG_PATH = '/var/log/api_http'
os.makedirs(LOG_PATH, exist_ok=True)  # Ensure the directory exists

LOGFILE = LOG_PATH + '/api_http.log'
logformat = '%(asctime)s.%(msecs)03d %(levelname)s: %(message)s'
formatter = logging.Formatter(logformat, datefmt='%d-%b-%y %H:%M:%S')

loggingRotativo = False
DEV = True

# FileHandler for logging to file
if loggingRotativo:
    LOG_HISTORY_DAYS = 3
    handler = logging.handlers.TimedRotatingFileHandler(
        LOGFILE,
        when='midnight',
        backupCount=LOG_HISTORY_DAYS)
else:
    handler = logging.FileHandler(filename=LOGFILE)

handler.setFormatter(formatter)

# Create a StreamHandler to log to the console
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

my_logger = logging.getLogger("api_http")
my_logger.addHandler(handler)
my_logger.addHandler(console_handler)  # Add the console handler

if DEV:
    my_logger.setLevel(logging.DEBUG)
else:
    my_logger.setLevel(logging.INFO)