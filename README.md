# Backend

## Technical details

* Ruby 3.3.3
* Rails 7.1.5.1
* Node 21.7.3

## How to start an app

## Before starting

1. ```cp .env.example .env```

You need to have `ruby-3.3.3` and `postgres` installed on your machine 
* Install the playwright by using `npm init playwright@latest` and related browsers by `npx playwright install`

* First of all you will need to install required gems by running

```
bundle install
```

* After this you will need to create database and migrate it

```
rails db:create
rails db:migrate
rails db:seed
```

As soon as database is ready you can start a server with

```
$ rails s
```

and navigate to `http://localhost:3000`

## Testing

We use RSpec for testing, run

```
$ RAILS_ENV=test bundle exec rspec
```

to run a test suite

## Developer attention

Please use `$ annotate` to document Models and relevant resources

Use `$ rubocop` to lint an app

Use `$ bundler_audit` to audit gems

Use `$ brakeman` for security audit 

Use `$ fasterer` to speed up an app

Docs will be accessible at `http://localhost:3000/api-docs`
