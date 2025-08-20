import json
import logging
from datetime import datetime, timezone

from .config import settings

class StructuredTextFormatter(logging.Formatter):
    def format(self, record):
        log_record = (
            f"[{datetime.fromtimestamp(record.created, tz=timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')}] "
            f"[{record.levelname}] "
            f"[{record.module}] "
            f"{record.funcName}() L{record.lineno} | "
            f"message=[{getattr(record, 'correlation_id', None)}]: {record.getMessage()} "
            f"- taken_time_ms={getattr(record, 'taken_time_ms', None)}"
        )
        return log_record

class LoggerSingleton:
    _instance: logging.Logger = None

    @staticmethod
    def get_instance() -> logging.Logger:
        """
        Return the singleton logger instance.
        """
        if LoggerSingleton._instance is None:
            LoggerSingleton._instance = LoggerSingleton._create_logger()
        return LoggerSingleton._instance

    @staticmethod
    def _create_logger() -> logging.Logger:
        """
        Create and configure the logger with Cloud Logging and console handlers.
        """
        logger = logging.getLogger()
        logger.setLevel(logging.INFO)

        # Define the log format
        formatter = StructuredTextFormatter()

        # Create a console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        return logger