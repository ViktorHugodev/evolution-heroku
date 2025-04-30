FROM atendai/evolution-api:latest

USER root

WORKDIR /evolution

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]