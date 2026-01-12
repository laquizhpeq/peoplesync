# Etapa 1: Compilación
FROM ubuntu:22.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

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

# Limpiar y compilar con flags adicionales de seguridad
RUN flutter clean
RUN flutter pub get
RUN flutter build web --release

# Etapa 2: Nginx para servir la web
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]