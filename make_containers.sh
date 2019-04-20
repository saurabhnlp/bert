#!/usr/bin/env bash

##Following commands to execute in Google Console

# Create Tensorflow Serving Container and host on Dockerhub
IMAGE_NAME=tf_serving_bert_agnews
VER=1555310285_v2
MODEL_NAME=bert
DOCKER_USER=saurabh9934
cd ~
docker run -d --name $IMAGE_NAME tensorflow/serving
mkdir ~/models
gsutil cp -r  gs://idev-analytics/CLEAN_ALL/export/COMPETENCY/1555310285 ~/models
docker cp ~/models/1555310285/ $IMAGE_NAME:/models/$MODEL_NAME
docker commit --change "ENV MODEL_NAME $MODEL_NAME" $IMAGE_NAME $USER/$IMAGE_NAME
docker tag $USER/$IMAGE_NAME $DOCKER_USER/$IMAGE_NAME:$VER
docker push $DOCKER_USER/$IMAGE_NAME:$VER

# Create client to call Bert Model
git clone https://github.com/saurabhnlp/bert.git
cd ~/bert

CLIENT_IMAGE_NAME=bert_agnews_client
CLIENT_VER=v3
DOCKER_USER=saurabh9934
mkdir asset
gsutil cp gs://cloud-tpu-checkpoints/bert/uncased_L-12_H-768_A-12/vocab.txt asset/
docker build -t $USER/$CLIENT_IMAGE_NAME .
docker tag $USER/$CLIENT_IMAGE_NAME $DOCKER_USER/$CLIENT_IMAGE_NAME:$CLIENT_VER
docker push $DOCKER_USER/$CLIENT_IMAGE_NAME:$CLIENT_VER


# run locally install gcloud and kompose
gcloud container clusters create bert-cluster
gcloud config set container/cluster bert-cluster
gcloud container clusters get-credentials bert-cluster --zone us-east1-b --project orbital-kit-235904
kompose convert --stdout | kubectl apply -f -
kubectl get service # get service IPs

wget http://34.73.232.214:8501/v1/models/bert
wget http://host:port/v1/models/${MODEL_NAME}[/versions/${MODEL_VERSION}]

# to run container
docker run -p 8500:8500 -p 8501:8501 -it saurabh9934/tf_serving_bert_agnews:1555310285_v2 -- sh
