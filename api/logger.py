import logging
import logging.handlers
import os

# Define log path and ensure the directory exists
LOG_PATH = '/var/log/api_http'
os.makedirs(LOG_PATH, exist_ok=True)  # Ensure the directory exists

# Define the log file
LOGFILE = os.path.join(LOG_PATH, 'api_http.log')  # Using os.path.join for better path handling
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

# Set the formatter for the file handler
handler.setFormatter(formatter)

# Create a StreamHandler to log to the console
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)

# Create logger and set basic configuration
my_logger = logging.getLogger("api_http")
my_logger.setLevel(logging.DEBUG if DEV else logging.INFO)

# Avoid duplicate logs if handlers are re-added
if not my_logger.hasHandlers():
    my_logger.addHandler(handler)
    my_logger.addHandler(console_handler)  # Add the console handler

# Example logging messages for testing
my_logger.debug("This is a debug message.")
my_logger.info("This is an info message.")
my_logger.warning("This is a warning message.")
my_logger.error("This is an error message.")
my_logger.critical("This is a critical message.")