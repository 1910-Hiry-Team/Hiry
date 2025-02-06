<h1 align="center">Hiry Project</h1>

Welcome to the Hiry project! This source code is for a website called Hiry, which aims to connect job seekers with small and medium-sized companies. Our platform leverages AI to facilitate these connections, ensuring that job seekers find the best opportunities and companies find the best talent.

## Main Features
Our platform offers several key features to enhance the user experience:

- **Complete Geocoding**: We provide accurate geocoding to help job seekers find opportunities near their location.
- **Secure Login and Sign Up**: Our platform ensures user data is protected with secure authentication processes.
- **Advanced Search Algorithm**: Utilizing Elasticsearch, our advanced search algorithm helps users find the most relevant job listings quickly and efficiently.

## Setting Up the Environment
To set up the environment for the project, ensure you have the following installed:
- Ruby 3.3.5
- Rails 7.1.5
- PostgreSQL
- Elasticsearch (follow the [installation instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html))

## Running the Project Locally
To run the project locally, follow these steps:
1. Clone the repository to your local machine by running:
  ```sh
  git clone git@github.com:1910-Hiry-Team/Hiry.git
  ```
2. Navigate to the project directory.
3. Install the required gems by running `bundle install`.
4. Launch the Elasticsearch server by running `elasticsearch`.
5. Set up the database by running `rails db:setup`.
6. Start the Rails server by running `rails server`.
7. Visit `http://localhost:3000` in your web browser to see the application in action.

## System Requirements
This project is best run on Unix systems. If you are using Windows, we recommend looking into the Windows Subsystem for Linux (WSL). You can find more information and installation instructions in the [WSL documentation](https://docs.microsoft.com/en-us/windows/wsl/install).

## Credits
This project was built as part of the [Le Wagon](https://www.lewagon.com) web development bootcamp.
