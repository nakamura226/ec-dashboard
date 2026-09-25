# syntax=docker/dockerfile:1

# Development image for EC Multi-Channel Dashboard.
# (For a production image, see the Dockerfile.production multi-stage build.)
ARG RUBY_VERSION=3.3.5
FROM ruby:${RUBY_VERSION}-slim

# Install packages needed to run and build the app
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    default-mysql-client \
    git \
    libvips \
    libyaml-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Node.js is only needed to fetch the DaisyUI Tailwind plugin into node_modules;
# the tailwindcss-rails standalone binary does the actual CSS build.
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

WORKDIR /rails

# Install gems first so this layer is cached unless the Gemfile changes
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install DaisyUI (a Tailwind CSS plugin resolved via node_modules) separately
# so this layer is cached unless package.json changes
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the application
COPY . .

RUN chmod +x bin/docker-entrypoint

ENTRYPOINT ["bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
