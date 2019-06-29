gcloud compute instances create reddit-test \
--boot-disk-size=10GB \
--zone europe-west2-b \
--image-family reddit-full \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \

