# SimpleBankAPI

SimpleBankAPI is a server-side Swift web application built using the Vapor framework. It provides a simple banking API with user management, balance handling, and transaction support.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Prerequisites

- Swift 5.3 or later
- Vapor 4
- PostgreSQL

### Steps

1. Clone the repository:

    ```bash
    git clone https://github.com/yvesoliveira23/SimpleBankAPI
    cd SimpleBankAPI
    ```

2. Install dependencies:

    ```bash
    swift package update
    ```

3. Set up the database:

    ```bash
    psql -c 'CREATE DATABASE simplebankapi;'
    ```

## Usage

### Running the Application

1. Build the project:

    ```bash
    swift build
    ```

2. Run the project:

    ```bash
    swift run
    ```

3. The application will be available at `http://localhost:8080`.

## Configuration

### Environment Variables

- `DATABASE_PORT`: The port for the database connection (default: 5432)
- `DATABASE_HOSTNAME`: The hostname for the database connection (default: `localhost`)
- `DATABASE_USERNAME`: The username for the database connection (default: `vapor_username`)
- `DATABASE_PASSWORD`: The password for the database connection (default: `""`)
- `ENABLE_LEAF`: Enable Leaf templating engine (default: `false`)

### Example `.env` file

```env
DATABASE_PORT=5432
DATABASE_HOSTNAME=localhost
DATABASE_USERNAME=vapor_username
DATABASE_PASSWORD=yourpassword
ENABLE_LEAF=true
```

## Testing

Run the test suite using:

```bash
swift test
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
