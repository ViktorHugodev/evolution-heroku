FROM atendai/evolution-api:latest
WORKDIR /evolution

COPY entrypoint.sh /evolution/entrypoint.sh
RUN chmod +x /evolution/entrypoint.sh

EXPOSE 8080
VOLUME ["/evolution/instances"]

ENTRYPOINT ["/evolution/entrypoint.sh"]
