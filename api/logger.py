# logger.py
import logging
import logging.handlers

LOG_PATH = '/var/log/api_http'
LOGFILE = LOG_PATH + '/api_http.log'
logformat = '%(asctime)s.%(msecs)03d %(levelname)s: %(message)s'
formatter = logging.Formatter(logformat, datefmt='%d-%b-%y %H:%M:%S')

loggingRotativo = False
DEV = True

if loggingRotativo:
    LOG_HISTORY_DAYS = 3
    handler = logging.handlers.TimedRotatingFileHandler(
        LOGFILE,
        when='midnight',
        backupCount=LOG_HISTORY_DAYS)
else:
    handler = logging.FileHandler(filename=LOGFILE)

handler.setFormatter(formatter)
my_logger = logging.getLogger("api_http")
my_logger.addHandler(handler)

if DEV:
    my_logger.setLevel(logging.DEBUG)
else:
    my_logger.setLevel(logging.INFO)