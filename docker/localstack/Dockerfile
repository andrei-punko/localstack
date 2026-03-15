FROM localstack/localstack:4.14

COPY docker/localstack/init/10-create-resources.sh /etc/localstack/init/ready.d/10-create-resources.sh

RUN chmod +x /etc/localstack/init/ready.d/10-create-resources.sh
