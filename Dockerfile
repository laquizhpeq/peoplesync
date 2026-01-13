# Etapa 1: Compilación
FROM ubuntu:22.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

# Argumentos de construcción para Firebase
ARG FIREBASE_API_KEY
ARG FIREBASE_AUTH_DOMAIN
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_STORAGE_BUCKET
ARG FIREBASE_MESSAGING_SENDER_ID
ARG FIREBASE_APP_ID
ARG FIREBASE_MEASUREMENT_ID

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa \
    fonts-droid-fallback python3 sed ca-certificates \
    cmake ninja-build pkg-config libgtk-3-dev \
    build-essential clang \
    chromium-browser \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# --- SOLUCIÓN A ERRORES DE PERMISOS Y SDK ---
RUN git config --global --add safe.directory /usr/local/flutter
RUN flutter config --enable-web
RUN flutter precache --web
RUN flutter devices

WORKDIR /app

# Copiar archivos de dependencias primero
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Limpiar y compilar con flags adicionales de seguridad y variables de entorno
RUN flutter clean
RUN flutter pub get
RUN flutter build web --release --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID --dart-define=FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID

# Etapa 2: Nginx para servir la web
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]