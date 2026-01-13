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
# Producction
```bash 
docker-compose up --build -d
```
# Development build
```bash 
docker-compose -f docker-compose-dev.yml up --build -d
```
# Development
```bash
docker-compose -f docker-compose-dev.yml attach peoplesync-dev
```
# Remove obsolet docker 
```bash
docker compose -f docker-compose-dev.yml down --remove-orphans
```
# Flutter analize code Command 
```bash
flutter analyze
```
