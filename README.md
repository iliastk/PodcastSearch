### HOW TO START ES & KIBANA CLUSTER LOCALLY
In this case we have had used Docker to create a container to install ES & Kibana
So in our case we will use `docker-compose up` to start the ES cluster & Kibana

If you got ES already installed, you could just run `elasticsearch`

Open up `http://localhost:9200` to check if ElasticSerch has started

Open up `http://localhost:5601` to check if Kibana has started

### HOW TO CREATE AND INDEX ALL THE CONTENT
*** note: you will have to access the file `IndexingOfElastic` to change the path where you have stored your Spotify dataset ***

*** spotify dataset was not included in this repo due to file size ***

- Open terminal in the repository PodcastSearch
Run the rails console:

`rails c`
 
Run the Job that create and index all the content

`IndexingOfElastic.new.perform`

### HOW TO RUN IT
 - Open terminal in the repository PodcastSearch
Run the rails server (localhost:3000):

`rails s`

- Open another terminal in the repository PodcastSearch
Access the folder of the frontend

`cd frontend-task2`

Run the frontend server (localhost:8080):

`npm run dev`

Finally, access your browser and go to `http://localhost:8080` & start making your queries.

### HOW IT WORKS
The frontend in `localhost:8080` displays a form where you can introduce the term to search, the duration of time of the clip and the type of search. Every field must be filled in.

Once the search button is pressed, the inputs from the forms are send to the backend as `params`.

*Backend:*
A client is created for the elasticsearch and a request is formed (Kibana was used for the formation of the json query request). The request is sent to elasticseach getting a JSON response.

The JSON response is parsed to create an array of objects that are going to be used in the frontend.

*Frontend:*
The Podcasts Cards are created with all the info of the clips retrieved.
