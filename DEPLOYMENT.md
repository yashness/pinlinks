# Pinlinks Deployment Guide

This guide provides instructions for deploying the Pinlinks application, a link management system built with Ruby on Rails.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development Setup](#local-development-setup)
- [Environment Configuration](#environment-configuration)
- [Database Setup](#database-setup)
- [Production Deployment](#production-deployment)
- [Background Jobs](#background-jobs)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying Pinlinks, ensure you have the following installed:

- **Ruby**: Version 1.9.3 or higher (compatible with Rails 3.2.16)
- **Rails**: Version 3.2.16
- **SQLite3**: For database (development/testing)
- **Bundler**: For managing Ruby gem dependencies
- **Git**: For version control

### Additional Requirements for Production

- **PostgreSQL** or **MySQL**: Recommended for production instead of SQLite3
  - SQLite3 is not suitable for production due to:
    - Limited concurrent write operations
    - No network access (file-based only)
    - Scalability limitations for high-traffic applications
    - Locking issues under heavy load
- **Web Server**: Nginx or Apache
- **Application Server**: Passenger, Puma, or Unicorn
- **SSL Certificate**: For HTTPS (recommended)

## Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yashness/pinlinks.git
cd pinlinks
```

### 2. Install Dependencies

```bash
bundle install
```

If you encounter issues with specific gems, try:

```bash
bundle update
bundle install
```

### 3. Configure Environment Variables

Create a `.env` file or set the following environment variables:

```bash
# OAuth Credentials
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Application Settings
SECRET_KEY_BASE=your_secret_key_base
RAILS_ENV=development

# Email Configuration (for Devise)
MAILER_HOST=localhost:3000
```

Generate a secret key base:

```bash
rake secret
```

### 4. Setup Database

```bash
# Create database
rake db:create

# Run migrations
rake db:migrate

# (Optional) Seed initial data
rake db:seed
```

### 5. Start the Development Server

```bash
rails server
```

Visit `http://localhost:3000` in your browser.

### 6. Start Background Job Workers

Pinlinks uses Delayed Job for background processing:

```bash
rake jobs:work
```

Or run it as a daemon in production:

```bash
RAILS_ENV=production script/delayed_job start
```

## Environment Configuration

### OAuth Setup

#### Facebook OAuth

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use an existing one
3. Add "Facebook Login" product
4. Set OAuth redirect URI: `http://yourdomain.com/users/auth/facebook/callback`
5. Copy App ID and App Secret to your environment variables

#### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Set authorized redirect URI: `http://yourdomain.com/users/auth/google_oauth2/callback`
6. Copy Client ID and Client Secret to your environment variables

### Email Configuration

Configure ActionMailer in `config/environments/production.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'yourdomain.com' }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'yourdomain.com',
  user_name:            ENV['SMTP_USERNAME'],
  password:             ENV['SMTP_PASSWORD'],  # Use App-Specific Password for Gmail
  authentication:       'plain',
  enable_starttls_auto: true
}
```

**Note for Gmail users**: Gmail requires an [App-Specific Password](https://support.google.com/accounts/answer/185833) for SMTP access. Regular account passwords will not work. Alternatively, consider using a service like SendGrid or Mailgun for production email.

## Database Setup

### Development/Testing

SQLite3 is used by default. No additional configuration needed.

### Production

For production, it's recommended to use PostgreSQL or MySQL.

#### PostgreSQL

1. Install PostgreSQL
2. Create a database and user:

```sql
CREATE USER pinlinks_user WITH PASSWORD 'your_password';
CREATE DATABASE pinlinks_production OWNER pinlinks_user;
```

3. Update `config/database.yml`:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: pinlinks_production
  pool: 5
  username: pinlinks_user
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: localhost
```

4. Add PostgreSQL gem to Gemfile:

```ruby
gem 'pg'
```

5. Run migrations:

```bash
RAILS_ENV=production rake db:migrate
```

## Production Deployment

### Option 1: Deploy to Heroku

1. Install Heroku CLI
2. Login to Heroku:

```bash
heroku login
```

3. Create a new Heroku app:

```bash
heroku create your-app-name
```

4. Add PostgreSQL:

```bash
heroku addons:create heroku-postgresql:hobby-dev
```

5. Set environment variables:

First, generate a secret key:

```bash
rake secret
```

Copy the generated secret, then set your environment variables:

```bash
heroku config:set FACEBOOK_APP_ID=your_facebook_app_id
heroku config:set FACEBOOK_APP_SECRET=your_facebook_app_secret
heroku config:set GOOGLE_CLIENT_ID=your_google_client_id
heroku config:set GOOGLE_CLIENT_SECRET=your_google_client_secret
heroku config:set SECRET_KEY_BASE=paste_generated_secret_here
```

6. Deploy:

```bash
git push heroku main
```

7. Run migrations:

```bash
heroku run rake db:migrate
```

8. Open your app:

```bash
heroku open
```

### Option 2: Deploy to VPS (Ubuntu/Debian)

#### 1. Install Dependencies

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade

# Install Ruby (using rbenv or rvm)
# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Install Nginx
sudo apt-get install nginx

# Install Node.js (for asset compilation)
sudo apt-get install nodejs
```

#### 2. Setup Application

```bash
# Clone repository
cd /var/www
sudo git clone https://github.com/yashness/pinlinks.git
cd pinlinks

# Install dependencies
bundle install --deployment --without development test

# Setup database
RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate

# Precompile assets
RAILS_ENV=production rake assets:precompile

# Setup secrets
RAILS_ENV=production rake secret
```

#### 3. Configure Web Server (Nginx + Passenger)

Install Passenger:

```bash
sudo apt-get install -y passenger
```

Create Nginx configuration (`/etc/nginx/sites-available/pinlinks`):

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/pinlinks/public;

    passenger_enabled on;
    # IMPORTANT: Verify and update this Ruby path for your environment
    # Find it with: which ruby
    # Common paths:
    #   System Ruby (Ubuntu/Debian): /usr/bin/ruby
    #   rbenv: /home/deploy/.rbenv/shims/ruby
    #   rvm: /usr/local/rvm/rubies/ruby-2.0.0/bin/ruby
    passenger_ruby /usr/bin/ruby;  # VERIFY THIS PATH WITH 'which ruby'

    location ~ ^/(assets)/ {
        expires max;
        add_header Cache-Control public;
    }
}
```

Enable site:

```bash
sudo ln -s /etc/nginx/sites-available/pinlinks /etc/nginx/sites-enabled/
sudo nginx -t
sudo service nginx restart
```

#### 4. Setup Delayed Job Worker

Create a systemd service (`/etc/systemd/system/delayed_job.service`):

```ini
[Unit]
Description=Delayed Job Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/pinlinks
Environment=RAILS_ENV=production
# IMPORTANT: Replace /path/to/bundle with your actual bundle path
# Find it with: which bundle
# Common paths:
#   System Ruby: /usr/bin/bundle
#   rbenv: /home/username/.rbenv/shims/bundle
#   rvm: /home/username/.rvm/wrappers/ruby-2.0.0/bundle
ExecStart=/path/to/bundle exec script/delayed_job run
Restart=always

[Install]
WantedBy=multi-user.target
```

**Note**: Replace `/path/to/bundle` in the ExecStart line with your actual bundle location found via `which bundle`.

Start the service:

```bash
sudo systemctl enable delayed_job
sudo systemctl start delayed_job
```

## Background Jobs

Pinlinks uses Delayed Job for background processing. To manage workers:

### Development

```bash
rake jobs:work
```

### Production

```bash
# Start
RAILS_ENV=production script/delayed_job start

# Stop
RAILS_ENV=production script/delayed_job stop

# Restart
RAILS_ENV=production script/delayed_job restart

# Check status
RAILS_ENV=production script/delayed_job status
```

## Troubleshooting

### Common Issues

#### 1. Bundle Install Fails

```bash
# Try updating bundler
gem install bundler
bundle update --bundler
```

#### 2. Database Migration Errors

```bash
# Drop and recreate database (development only!)
rake db:drop
rake db:create
rake db:migrate
```

#### 3. Asset Precompilation Fails

```bash
# Clear existing assets
rake assets:clobber
# Precompile again
RAILS_ENV=production rake assets:precompile
```

#### 4. OAuth Authentication Issues

- Verify callback URLs match exactly in OAuth provider settings
- Ensure environment variables are set correctly
- Check that your domain is authorized in OAuth app settings

#### 5. Delayed Job Not Processing

```bash
# Check if worker is running
ps aux | grep delayed_job

# Check logs
tail -f log/delayed_job.log
```

#### 6. Permission Issues

```bash
# Set correct permissions
sudo chown -R www-data:www-data /var/www/pinlinks
sudo chmod -R 755 /var/www/pinlinks
```

### Logs

Check application logs for errors:

```bash
# Development
tail -f log/development.log

# Production
tail -f log/production.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## Maintenance

### Backing Up Database

```bash
# SQLite
cp db/production.sqlite3 db/backups/production-$(date +%Y%m%d).sqlite3

# PostgreSQL
pg_dump pinlinks_production > backup-$(date +%Y%m%d).sql
```

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Install new dependencies
bundle install

# Run migrations
RAILS_ENV=production rake db:migrate

# Precompile assets
RAILS_ENV=production rake assets:precompile

# Restart application
sudo service nginx restart
sudo systemctl restart delayed_job
```

## Security Considerations

1. **Never commit secrets** to version control
2. Use **strong passwords** for database users
3. Enable **HTTPS** in production
4. Keep **gems updated** regularly: `bundle update`
5. Use **environment variables** for sensitive data
6. Set appropriate **file permissions** on the server
7. Regularly **backup your database**
8. Monitor **application logs** for suspicious activity

## Support

For issues or questions:
- Check the [GitHub Issues](https://github.com/yashness/pinlinks/issues)
- Review application logs
- Consult Rails 3.2 documentation

## License

Refer to the project's LICENSE file for licensing information.
