FROM solr:6
ADD amigocore /opt/solr/server/solr/
RUN cat /opt/solr/server/solr/conf/managed-schema
EXPOSE 8983
