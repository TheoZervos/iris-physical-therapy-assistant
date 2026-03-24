# Source Code
This directory will store all source code sorted into categories:

1. Schemas
2. Services
3. Utils
4. UI

This sorting is to help with separation of concerns, organizing our
code in such a way that wires do not get crossed.

## Schemas
Schemas outline the properties that define a specific peice of data.
The `project_code/schemas` folder is where we will store our pydantic models
(i.e. using BaseModel). Files should be split into the related sections.
For example, in a project accessing a stock market API and a weather API,
our stock market models would go into a file `stock.py`, and 
our weather models should go into a file `weather.py`

## Services
Services are specialized software components or classes designed to do
certain logic, background tasks or functional utilities. This should be sorted
similarly to schemas, sorted by the tasks that are being completed. (i.e a file 
that stores the functions for interacting with the weather API)

## Utils
Utils are similar to services, but they are not specialized and are more generic.
Think of a function that is used to pick between two strings based on a few identifiers.
These kind of function can exist in a file in the `project_code/utils` folder to prevent
muddying up our services. An example includes a `parse_utils.py` file that has
generic functions that can be used to help parse string data.

## UI
The UI folder will contain all code related to front end UI. More explanation can
be found in the `ui` folder that goes into detail about the UI specific to the project.