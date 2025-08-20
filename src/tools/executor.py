from adktools import adk_tool

from ..core.loggers import LoggerSingleton

logger = LoggerSingleton.get_instance()

@adk_tool(
    name="query_executor",
    description="Executes a BigQuery SQL query and returns the results."
)
def query_executor(sql_query: str) -> str:
    """This function takes an sql query and executes it on sql server, finally returns the response"""
    response=""
    try:
        logger.info("\n+-----------------------------------------------------------------------------+")
        logger.info(f"sql_query: \n{sql_query}")
        logger.info("+-----------------------------------------------------------------------------+\n")
        response = bigquery_client.execute_query(sql_query)
    except Exception as e:
        response = f"Encountered following error {e}"
        logger.exception(f"{response}")
    return response