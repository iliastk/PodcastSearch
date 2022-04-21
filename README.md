
Open terminal in the repository
Run the rails server (localhost:3000):

rails -s

Open another terminal in the repository
Access the folder of the frontend
cd frontend
Run the frontend server (localhost:8080):

npm run dev

Finally, access your browser and go to http://localhost:8080 & start making your queries.




*HOW IT WORKS*

The frontend in localhost:8080 displays a form where you can introduce the term to search, the period of time where the search take place (date & time) and the interval. Every field must be filled in.

Once the search button is pressed, the inputs from the forms are send to the backend as params.

*Backend:*
A client is created for the elasticsearch and a request is formed (Kibana was used for the formation of the json query request). The request is sent to elasticseach getting a JSON response.

The JSON response is parsed to create an array of objects that are going to be used in the frontend.


[
timestamp=> [{ medium, doc}, { medium, doc}, ..],
timestamp=> [{ medium, doc}, { medium, doc}, ..]
]


& Send it as a response to the frontend

*Frontend:*
The dataset is formed using the data of the response & the chart is created with Chart.js
