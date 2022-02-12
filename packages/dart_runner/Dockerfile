# Use latest stable channel SDK.
FROM dart:stable AS build

# The following commented out code works but leaves the image as the full Dart image

# # Resolve app dependencies.
# WORKDIR /app
# COPY pubspec.* ./
# RUN dart pub get

# # Copy app source code (except anything in .dockerignore).
# COPY . .
# # Start server.
# EXPOSE 8080
# ENTRYPOINT ["/usr/lib/dart/bin/dart", "/app/bin/server.dart"]

WORKDIR /app
COPY pubspec.yaml /app/pubspec.yaml
RUN dart pub get
COPY . .
# RUN dart pub get --offline

FROM scratch
COPY --from=0 /usr/lib/dart/bin/dart /usr/lib/dart/bin/dart
COPY --from=0 /root/.pub-cache /root/.pub-cache
COPY --from=0 /app /app
COPY --from=0 /usr/lib/dart/lib/_internal/vm_platform_strong.dill /usr/lib/dart/lib/_internal/
EXPOSE 8080
ENTRYPOINT ["/usr/lib/dart/bin/dart", "/app/bin/server.dart"]