FROM julia:1.10

RUN apt update -y && apt install build-essential -y

RUN mkdir /flexpoints
COPY . /flexpoints
WORKDIR /flexpoints

RUN chmod +x bin/server.sh

RUN julia -t 1 sysimage.jl

EXPOSE 8585

ENV JULIA_DEPOT_PATH "~/.julia"
ENV HOST "0.0.0.0"
ENV PORT "8585"

CMD ["bin/server.sh"]