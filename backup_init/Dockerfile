FROM busybox:latest
COPY ./init.sh /opt/
RUN chmod +x /opt/init.sh
ENTRYPOINT ["sh", "/opt/init.sh"]