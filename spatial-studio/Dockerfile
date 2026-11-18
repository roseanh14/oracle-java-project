FROM eclipse-temurin:21-jdk

WORKDIR /opt/Oracle_Spatial_Studio

COPY Oracle_Spatial_Studio/ ./

RUN chmod +x ./*.sh

EXPOSE 4040

CMD ["bash", "-lc", "./start.sh && tail -f /dev/null"]
