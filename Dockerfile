FROM mongo:latest

RUN apt-get update && apt-get install -y git

COPY backup.sh /workspace/

CMD ["./backup.sh"]