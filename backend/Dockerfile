FROM ruby:3.3.8-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev libsqlite3-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile ./
RUN bundle install
COPY . .
ENV RAILS_ENV=production
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
