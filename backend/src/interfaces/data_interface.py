# src/my_app/data/data_interface.py
from abc import ABC, abstractmethod
from typing import List, Dict, Optional

class DataInterface(ABC):
    """
    Abstract interface for data access operations.  This defines the contract
    that all concrete data access implementations (e.g., BigQuery, OpenAI, etc.)
    must adhere to.
    """

    @abstractmethod
    def execute_query(self, query: str) -> List[Dict]:
        """
        Executes a query against the underlying data source.

        Args:
            query: The query string (e.g., SQL for BigQuery).

        Returns:
            A list of dictionaries, where each dictionary represents a row
            in the result set.  The keys of the dictionaries are the column
            names.  Returns an empty list if the query returns no results.

        Raises:
            Exception: If an error occurs during query execution.
        """
        pass