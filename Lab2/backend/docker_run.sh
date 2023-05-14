sudo docker run --rm -p 4013:4013 --network host -e DB_ADDRESS=127.0.0.1 -e DB_PORT=3306 backend_docker
# --network localhost?