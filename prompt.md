create an app using this flutter template
app name: MedLab
it is an application designed to store and amnage medical test results such as blood couns, choloesterol levels thyroid functions and more
it allows users to view their test history through interactive charts and visual trends helping tchem track changes overtime

we need an mvp -
 - no loging in, one phone one user everything is tracked on local database
 - user inputs name 
 - main view with ability to see graphs/stats, welcome and the ability to add a new medical result
 - adding medical results is split - "add manually"/"submit photo for ai assisted data fill"
 - add manually - add your results manually step by step
 - ai assisted - open a camera, take photo of results and ai will just ocr it and fill out predefined json (Claude/openai api call)
 - if something fails in ai assist user has to make corrections

ui has to be modern in gogle style android white ui
it has to guide new users and be accesible for elder users

as for the mvp do not add yet a ai assist, make mockup data, leave space for ai integration in future, show prompt for users that this is incoming when they add it