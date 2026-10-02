FROM ruby:3.4-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git libyaml-dev \
  && rm -rf /var/lib/apt/lists/* \
  && git config --global --add safe.directory /app

WORKDIR /app

# The gemspec needs the version file and `git ls-files`; install gems before copying the rest
# so editing code doesn't bust the bundle cache.
COPY Gemfile scrapin.gemspec ./
COPY lib/scrapin/version.rb lib/scrapin/version.rb
RUN bundle install

COPY . .

CMD ["bash"]
