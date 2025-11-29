FROM ruby:3.3.3

ENV APP_PATH /var/app
ENV BUNDLE_VERSION 2.5.19
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Update package list and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  build-essential \
  git \
  libgit2-dev \
  cmake \
  postgresql-client \
  libpq-dev \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  yarn \
  imagemagick \
  tzdata \
  less \
  npm \
  libstdc++6 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  libxcb1 \
  libxshmfence1 \
  libnss3 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcups2 \
  libgbm1 \
  libxfixes3 \
  libxcursor1 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libasound2 \
  libxrender1 \
  libwayland-client0 \
  libwayland-server0 \
  libxkbcommon0 \
  fonts-liberation \
  libfreetype6 \
  libharfbuzz-icu0 \
  libfontconfig1 \
  ca-certificates \
  curl \
  unzip \
  libvips-dev \
  && rm -rf /var/lib/apt/lists/*


# Copy entrypoint scripts and grant execution permissions
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Remove any Alpine-based gems and install Bundler cleanly
RUN rm -rf /usr/local/bundle /usr/lib/ruby/gems/* /usr/local/lib/ruby/gems/* && \
  gem install bundler --version "$BUNDLE_VERSION"

# Navigate to app directory
WORKDIR $APP_PATH

# Copy and install dependencies
COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle update net-pop
RUN bundle install --force

COPY . ./

EXPOSE $RAILS_PORT

ENTRYPOINT [ "bundle", "exec" ]
