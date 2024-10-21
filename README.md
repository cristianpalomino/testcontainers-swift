# Testcontainers for Swift

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=833769655&machine=standardLinux32gb&devcontainer_path=.devcontainer%2Fdevcontainer.json&location=EastUs)

# Overview

Testcontainers for Swift is a library designed to bring official Testcontainers support to Swift projects. It provides simple ways to manage Docker containers during your tests, making integration tests easier and more reliable.

We welcome contributions to this exciting and fun open-source project 🫵.

## Features

- Create new Generic Docker containers.
- Start Generic Docker containers.
- Remove existing Generic Docker containers.

----

### Starting a Generic Container

Easy way to start a new Generic Container ready for use.

Using Async/Await.

```swift 
do {
    ...

    let container = try GenericContainer(name: "redis", port: 6379, logger: logger)

    // Start the container
    let response = try await container.start().get()
    logger.info("Container Name: \(response.Name)")
    
    ...
} catch {
    // Handle error
    print(error)
}
```


Using Completion Handlers.

```swift
...

let container = try GenericContainer(name: "redis", port: 6379, logger: logger)

// Start the container
container.start().whenComplete { result in
    switch result {
    case let .success(response):
        self.logger.info("Container Name: \(response.Name)")
    case let .failure(error):
        // Handle error
        print(error)
    }
}

...
``` 

Behind the scenes, the library handles the following steps:

- Pulls Docker Image.
- Creates a new Docker Container.
- Starts the Docker Container.
- Inspects the Docker Container.

----

### Removing a Generic Container

The library also allows you to remove a container once you're done with it.

Using Async/Await

```swift 
do {
    ...

    let container = try GenericContainer(name: "redis", port: 6379, logger: logger)
    let response = try await container.start().get()
    logger.info("Container Name: \(response.Name)")
    
    ...
    // Perform operations with the running container
    ...
    
    // Remove the container
    try await container.remove().get()
    
    ...
} catch {
    // Handle error
    print(error)
}
```


Using Completion Handlers.

```swift
...

let container = try GenericContainer(name: "redis", port: 6379, logger: logger)
container.start().whenComplete { result in
    switch result {
    case let .success(response):
        self.logger.info("Container Name: \(response.Name)")

        ...
        // Perform operations with the running container
        ...

        // Remove the container
        container.remove().whenComplete { result in
            switch result {
            case let .success:
                self.logger.info("Container Removed")
            case let .failure(error):
                // Handle error
                print(error)
            }
        }
    case let .failure(error):
        // Handle error
        print(error)
    }
}

...
``` 

Behind the scenes, the library performs the following steps:

- Stops the Docker Container.
- Removes the Docker Container.

----

## Contributing

See [contributors](https://github.com/cristianpalomino/testcontainers-swift/graphs/contributors) for all contributors.

----

Join our [Slack workspace](https://slack.testcontainers.org/) | [Slack channel](https://testcontainers.slack.com/archives/C07KC68PBQC)
