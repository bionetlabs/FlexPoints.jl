FROM julia:latest

# app
RUN mkdir /flexpoints
COPY . /flexpoints
WORKDIR /flexpoints

RUN chmod +x bin/server.sh

# USER flexpoints

RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

# ports
EXPOSE 8000
EXPOSE 5050

ENV JULIA_DEPOT_PATH "~/.julia"
ENV GENIE_ENV "dev"
ENV HOST "0.0.0.0"
ENV PORT "8585"

CMD ["bin/server.sh"]
