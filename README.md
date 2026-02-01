# Pinlinks

A web application for organizing and managing your favorite links in repositories.

## Features

- Create repositories to organize links
- Add, edit, and delete links
- Tag links for easy searching
- Private and public repositories
- OAuth authentication (Facebook and Google)
- Fork repositories from other users
- User profiles

## Quick Start

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)

### Basic Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Setup database:
   ```bash
   rake db:create
   rake db:migrate
   ```

3. Start the server:
   ```bash
   rails server
   ```

4. Visit `http://localhost:3000`

## Documentation

- [Deployment Guide](DEPLOYMENT.md) - Complete deployment instructions for development and production

## Technology Stack

- Ruby on Rails 3.2.16
- SQLite3 (development)
- Devise (authentication)
- OAuth (Facebook & Google)
- Delayed Job (background processing)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See LICENSE file for details.
