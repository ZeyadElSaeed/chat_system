# Chat System

## Introduction
The Chat System is a scalable and efficient chat application designed to handle multiple chat applications simultaneously. Each chat application is uniquely identified by a token, and messages within each chat are organized and indexed for quick search and retrieval. This system is built to manage high volumes of concurrent requests, ensuring data consistency and reliability.

## About Me
This project marks several new milestones for me:

- **First Time Using Ruby and Rails**: This is my first venture into the Ruby programming language and the Ruby on Rails framework.
  
- **Exploring Elasticsearch**: Implementing Elasticsearch for the first time has been a great learning experience by using searchkick gem.

- **Implementing a Queue System**: This project involves using a queue system for the first time. Using sidekiq gem that utilizes REDIS to set up background job and imporve the server performance.

- **Dockerizing a Rails App**: This is my initial attempt at containerizing a Rails application using Docker. It’s been a rewarding challenge to create Docker images and manage containerized services.

- **Connecting Multiple Services with Docker Compose**: Configuring Docker Compose to orchestrate multiple services—including MySQL, Redis, and Elasticsearch—has been an excellent exercise in understanding containerized microservices architecture.


## Technology Used
- **Ruby on Rails**
- **MySQL**
- **Redis**
- **ElasticSearch**

## Special Gems Used
- **faker**: For generating fake data.
- **searchkick**: For integrating ElasticSearch and handling search functionalities.
- **elasticsearch**: ElasticSearch client for Ruby.
- **sidekiq**: For background job processing.
- **mysql2**: MySQL database adapter for Ruby.


## Characteristics
- **Unique Token Identification**: Each chat application is uniquely identified by a token, *its seed: timestamp, application name, UUID, random number*
- **Sequential Numbering**: Chats within an application are numbered sequentially starting from 1. Messages within each chat also follow a sequential numbering scheme. *`Counter_Cache`* was used to keep track of associated entites (e.g. chats_number inside applications refers to chats associated with that application)
- **ElasticSearch Integration**: Search functionality is provided through ElasticSearch, allowing partial matches and efficient querying of messages using *`word_middle`* and asyn reindexing by providing async job for that and use *`callback: :async`*. 
- **Asynchronous Processing**: Uses Redis and Sidekiq for handling background jobs, such as creating applicatios, chats and messages and editing applications and messages. In addition to a background job to reindex the Message model after craeting and updating.
- **Optimized Performance**: Designed to minimize direct MySQL queries during request handling by using background jobs for async operations and using appropriate indexing for improved performance.
- **Containerized Deployment**: The entire application stack can be deployed using Docker and Docker Compose with a single command: `docker-compose up`.

# Project Setup and Build Instructions

This guide will walk you through the process of building and running the project using Docker. The project includes a Rails application along with MySQL, Redis, and Elasticsearch services. The entry point for the project is configured to run a batch process.

## Prerequisites
Before you begin, ensure that you have the following installed:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Directory Structure
Your project directory should contain:
- `Dockerfile`: Defines the Docker image for the Rails application.
- `docker-compose.yml`: Defines the multi-container setup including MySQL, Redis, Elasticsearch, and the Rails app.

## Build and Run the Project
### 1. Build the Docker Images
Navigate to your project directory and build the Docker images using the following command:
```bash
  docker-compose build
```
### 2. Start the Containers
After building the images, start the containers with:
```bash
  docker-compose up
```
### 3. Access the Application
Rails Application: By default, the Rails application will be available at
```bash
  http://localhost:3000
```

## Applications API

### List Applications
- **Endpoint**: `GET /applications`
- **Description**: Retrieves a list of all applications.
- **Response**:
  - **200 OK**: Returns an array of applications with the following fields:
    - `token`: Unique identifier of the application.
    - `name`: Name of the application.
    - `chats_count`: Number of chats associated with the application.
  - **404 Not Found**: If no applications are found.
- **Example Response**:
  ```json
  [
    {
      "token": "example-token-1",
      "name": "Example Application 1",
      "chats_count": 10
    },
    {
      "token": "example-token-2",
      "name": "Example Application 2",
      "chats_count": 5
    }
  ]

### Create Application
- **Endpoint**: `POST /applications`
- **Description**: Creates a new application with a unique token.
- **Request body**:
    - `name`: Name of the application.
- **Response**:
  - **200 OK**: Returns the following fields:
    - `token`: Unique identifier of the application.
  - **404 Not Found**: If no applications are found.
- **Example Response**:
  ```json
  [
    {
      "token": "example-token-1",
    }
  ]

### Update Application
- **Endpoint**: `PATCH /applications/:token` or `PUT /applications/:token`
- **Description**: Updates the name of an existing application.
- **Request body**:
    - `name`: Updated Application Name.
- **Response**:
  - **200 OK**: Indicates that the application update is being processed. Returns the token and new name.
    - `token`: Unique identifier of the application.
    - `name`: Edied name of the application.
  - **404 Not Found**: If no applications are found.
- **Example Response**:
  ```json
  [
    {
      "token": "example-token-1",
      "name": "example-name-1",
    }
  ]

### Show Application
- **Endpoint**: `GET /applications/:token`
- **Description**: Retrieves details of a specific application by its token.
- **Response**:
  - **200 OK**: Returns the application details:
    - `token`: Unique identifier of the application.
    - `name`: Name of the application.
    - `chats_count`: Number of chats associated with the application.
  - **404 Not Found**: If no applications are found.
- **Example Response**:
  ```json
  [
   {
      "token": "example-token",
      "name": "Example Application",
      "chats_count": 7
    }
  ]

## Chats API
### List Chats
- **Endpoint**: `GET /applications/:application_token/chats`
- **Description**: Retrieves a list of chats for a specific application by its token.
- **Response**:
  - **200 OK**: Returns a list of chats.
    - **Example Response**:
      ```json
      [
        {
          "number": 1,
          "messages_count": 12
        },
        {
          "number": 2,
          "messages_count": 14
        }
      ]
      ```
  - **404 Not Found**: If no chats are found for the given application token.
    - **Example Response**:
      ```json
      {
        "error": "No chats found for application token: <application_token>"
      }
      ```

### Show Chat
- **Endpoint**: `GET /applications/:application_token/chats/:chat_number`
- **Description**: Retrieves a specific chat by application token and chat number.
- **Response**:
  - **200 OK**: Returns the details of the chat.
    - **Example Response**:
      ```json
      {
        "id": 1,
        "number": 1,
        "messages_count": 16
      }
      ```
  - **404 Not Found**: If no chat is found for the given application token and chat number.
    - **Example Response**:
      ```json
      {
        "error": "No chat found for application token: <application_token> and number: <chat_number>"
      }
      ```

### Create Chat
- **Endpoint**: `POST /applications/:application_token/chats`
- **Description**: Creates a new chat for a specific application.
- **Response**:
  - **201 Created**: Returns the new chat number.
    - **Example Response**:
      ```json
      {
        "chat_number": 2
      }
      ```
  - **404 Not Found**: If the application with the specified token is not found.
    - **Example Response**:
      ```json
      {
        "error": "Application not found"
      }
      ```

## Message API

### List Messages
- **Endpoint**: `GET /applications/:application_token/chats/:chat_number/messages`
- **Description**: Retrieves a list of messages for a specific chat within an application.
- **Response**:
  - **200 OK**: Returns a list of messages.
    - **Example Response**:
      ```json
      [
        {
          "number": 1,
          "body": "Hello world",
        },
        {
          "number": 2,
          "body": "Another message",
        }
      ]
      ```
  - **404 Not Found**: If no messages are found for the given application token and chat number.
    - **Example Response**:
      ```json
      {
        "error": "No messages found for application token: <application_token> and chat_number: <chat_number>"
      }
      ```

### Show Message
- **Endpoint**: `GET /applications/:application_token/chats/:chat_number/messages/:message_number`
- **Description**: Retrieves a specific message by application token, chat number, and message number.
- **Response**:
  - **200 OK**: Returns the details of the message.
    - **Example Response**:
      ```json
      {
        "number": 1,
        "body": "Hello world",
      }
      ```
  - **404 Not Found**: If no message is found for the given application token, chat number, and message number.
    - **Example Response**:
      ```json
      {
        "error": "No message found for application token: <application_token>, chat: <chat_number>, and message: <message_number>"
      }
      ```

### Create Message
- **Endpoint**: `POST /applications/:application_token/chats/:chat_number/messages`
- **Description**: Creates a new message within a specific chat.
- **Request**:
    - **Body**:
      - `body`: Content of the message (String).
- **Response**:
  - **201 Created**: Returns the newly created message details including its number.
    - **Example Response**:
      ```json
      {
        "number": 2,
        "body": "New message content"
      }
      ```
  - **422 Unprocessable Entity**: If required parameters are missing or validation fails.
    - **Example Response**:
      ```json
      {
        "error": "Message parameters (body) are missing"
      }
      ```
  - **404 Not Found**: If the chat with the specified token and number is not found.
    - **Example Response**:
      ```json
      {
        "error": "Chat not found with number <chat_number>"
      }
      ```

### Update Message
- **Endpoint**: `PATCH-PUT /applications/:application_token/chats/:chat_number/messages/:message_number`
- **Description**: Updates an existing message within a specific chat.
- **Request**:
    - **Body**:
      - `body`: Updated content of the message (String).
- **Response**:
  - **200 OK**: Returns the updated message details.
    - **Example Response**:
      ```json
      {
        "number": 1,
        "body": "Updated message content"
      }
      ```
  - **404 Not Found**: If the message with the specified number in the given chat is not found.
    - **Example Response**:
      ```json
      {
        "error": "Message not found with number <message_number> in chat <chat_number>"
      }
      ```

### Search Messages
- **Endpoint**: `GET /applications/:application_token/chats/:chat_number/messages/search?query=(term)`
- **Description**: Searches for messages within a specific chat using a query string.
- **Request param**:
    - `query`: Search query string (String).
- **Response**:
  - **200 OK**: Returns a list of messages matching the search query.
    - **Example Response**:
      ```json
      [
        {
          "number": 1,
          "body": "Search result"
        },
        {
          "number": 2,
          "body": "Another search result"
        }
      ]
      ```
  - **404 Not Found**: If no messages match the search query within the given chat.
    - **Example Response**:
      ```json
      {
        "error": "No results found"
      }
      ```
      
### Error Handling
- **Not Found**
  - `GET /404`
  - Controller: `errors#not_found`
- **Internal Server Error**
  - `GET /500`
  - Controller: `errors#internal_server_error`
- **Unmatched Routes**
  - `GET /*unmatched`
  - Controller: `errors#not_found`
