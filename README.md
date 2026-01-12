# peoplesync

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

docker build -t peoplesync-web .
docker run -d -p 8080:80 --name peoplesync-app peoplesync-web
# produccion
```bash 
docker-compose up --build -d
```
# desarrollo
```bash
docker compose -f docker-compose-dev.yml attach up  --build -d 
```
# remover docker huerfanos
```bash
docker compose -f docker-compose-dev.yml down --remove-orphans
``` 
docker attach peoplesync-dev

docker-compose attach peoplesync-dev

# comando para utilizar hot reload en docker 
```bash
docker-compose -f docker-compose-dev.yml attach peoplesync-dev
```