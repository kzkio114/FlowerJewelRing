FROM ruby:3.3.1

# 環境変数の設定
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y ca-certificates curl gnupg build-essential libpq-dev

# アプリケーションディレクトリの作成
RUN mkdir /app
WORKDIR /app

# Gemの依存関係の解決
COPY Gemfile* /app/
RUN gem update --system
RUN gem install bundler && bundle install

# Railsのインストール
RUN gem install rails
RUN which rails
RUN echo $PATH

# Railsのバージョンを確認
RUN /usr/local/bundle/bin/rails --version

# Railsがインストールされている場所をパスに追加
ENV PATH="/usr/local/bundle/bin:${PATH}"

# Bunのインストール
RUN curl -fsSL https://bun.sh/install > bun-install.sh
RUN bash bun-install.sh
RUN mv /root/.bun/bin/bun /usr/local/bin/bun
RUN bun --version

# Bunがインストールされている場所をパスに追加
ENV PATH /root/.bun/bin:$PATH

# アプリケーションのコピー
COPY . /app

# ポート3000を公開
EXPOSE 3000

# Railsサーバーを起動
CMD ["rails", "server", "-b", "0.0.0.0"]